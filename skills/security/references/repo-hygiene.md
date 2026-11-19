# Repository hygiene for secrets

Read when creating a repository, writing `.gitignore` or installing a pre-commit hook. The `git`
skill covers commit practice. This file covers what must never be committed and how to block it.

## Contents
- Baseline `.gitignore`
- `.env.example` format
- Pre-commit hook: block sensitive files
- Content scanning
- After a leak

## Baseline `.gitignore`

Commit `.gitignore` before any other file, so nothing sensitive is ever tracked by accident.

```gitignore
# Databases
*.db
*.db-shm
*.db-wal
*.sqlite

# Keys and certificates
*.key
*.pem
*.p12
id_rsa*
secrets/
# Add your project's own key, salt and export file names here

# Secrets
.env
.env.*
!.env.example

# Logs and backups
logs/
*.log
backups/

# Build artefacts and tooling
__pycache__/
*.pyc
.venv/
node_modules/
.DS_Store
```

Add project-specific files that hold personal data (exports, local config) here AND to the hook
patterns below. One list is not enough: `.gitignore` does not stop `git add -f`.

Commit safe stand-ins instead: `.env.example`, `config/*.example.yaml` with structure only, and
`tests/fixtures/` with fake data shaped like the real data.

## `.env.example` format

```bash
# Payments provider. Required only if PAYMENTS_ENABLED=true.
# Get a key at: https://<provider>/dashboard/keys
PAYMENTS_API_KEY=your_key_here

# Feature flags. All off by default.
PAYMENTS_ENABLED=false
```

Every key the app reads appears here with a comment saying when it is required. The app fails at
start-up, with the key's name in the message, when a required one is missing.

## Pre-commit hook: block sensitive files

Save as `scripts/pre-commit-check.sh` and install with
`cp scripts/pre-commit-check.sh .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit`.
`.git/hooks` is not versioned, so a fresh clone has no hook. Either document the install step in the
README or point git at a versioned folder with `git config core.hooksPath scripts/hooks`. If the
project uses the `pre-commit` framework (see the `ci-cd` skill), add this as a local hook there.

```bash
#!/usr/bin/env bash
# Blocks commits that stage sensitive files. Extended regex, matched per path.
# (^|/) anchors each pattern at the start of any path segment, so nested .env files are caught.
set -euo pipefail

BLOCKED=(
  '(^|/)\.env($|\.)'
  '\.db(-shm|-wal)?$'
  '\.sqlite$'
  '\.key$'
  '\.pem$'
  '\.p12$'
  '(^|/)id_rsa'
  '(^|/)secrets/'
  # add your project's own key and export file patterns
)
ALLOWED='(^|/)\.env\.example$'

fail=0
while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  [[ "$path" =~ $ALLOWED ]] && continue
  for pattern in "${BLOCKED[@]}"; do
    if [[ "$path" =~ $pattern ]]; then
      echo "BLOCKED: sensitive file staged: $path"
      fail=1
    fi
  done
done < <(git diff --cached --name-only --diff-filter=ACMR)

if [[ $fail -eq 1 ]]; then
  echo "Commit blocked. Unstage the files above (git restore --staged <path>)."
  exit 1
fi
```

Prove it works before trusting it: stage a dummy `.env` and a dummy `nested/dir/.env` and confirm
both are blocked, then stage `.env.example` and confirm it is allowed.

## Content scanning

A filename hook misses a key pasted into source. Add a content scanner:
- Once, over the whole history: `gitleaks git .` (older gitleaks: `gitleaks detect --source .`), or
  `trufflehog git file://.`. Use `gitleaks dir <path>` for files outside git.
- On each commit: gitleaks as a pre-commit hook, and again in CI so a bypassed local hook is caught.
- Expect false positives in test fixtures. Allow-list them by path and rule, never by turning the rule
  off.

## After a leak

1. Revoke or rotate the secret at the provider. This is the only step that removes the risk.
2. Check the provider's access logs for use of the secret since the commit date.
3. Remove it from history with `git filter-repo` (not `filter-branch`), then force-push and have every
   clone re-clone. Forks and caches may still hold it, which is why step 1 comes first.
4. Add the pattern that would have caught it to the hook and the scanner config.
