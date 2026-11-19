---
name: security
description: Use when implementing or planning password reset, login, sign-up, magic links, sessions, auth tokens, JWTs, cookies, API keys, secrets or .env files, and for CORS, webhooks, encryption, personal data or user input that reaches a query, shell, path or URL. Load it before designing any token or auth flow. Not for reviewing or threat-modelling an existing system; use `security-audit`.
license: MIT
---

# Security (secure coding)

This skill is for the person writing the code. It sets the defaults that keep a change safe as it is
built. Auditing a system, threat modelling and writing findings belong to the `security-audit` skill.

## The rules that matter most

1. **Secrets never enter the repository.** Not in code, config, tests, fixtures, Dockerfiles or CI
   YAML. Load them from the environment or a secrets manager and fail at start-up if a required one is
   missing. A secret that reached git history is compromised: rotate it first, rewrite history second
   (deleting the file changes nothing, the old commit still holds it).
2. **Authorise the object, not only the user.** Every handler that takes an id must check that the
   caller may act on THAT record. "Is logged in" is authentication. "Owns order 1234" is authorisation.
   Missing object-level checks (IDOR) are the most common serious web flaw.
3. **Untrusted input never builds code.** No string-built SQL, shell commands, file paths, URLs,
   templates or regexes. Use bound parameters, argument arrays (never `shell=True` with input), an
   allow-listed base directory with a resolved-path check and an allow-list of hosts for outbound
   requests.
4. **Validate on the server.** Client checks are UX. An attacker calls the API directly.
5. **Treat model output as untrusted input.** Text from an LLM is attacker-influenced whenever any
   input to it was. Never render it as raw HTML, run it in a shell or pass it to a tool with more power
   than the user who caused it.
6. **Fail closed and prove the control.** A check written as "not open" passes when the system is
   merely broken. State it as the evidence you expect (`401`, `403`, a rejected signature) and treat
   everything else, including "cannot tell", as a failure.

## Three tiers of action

Use this split for anything security-relevant you do while coding.

| Tier | Examples |
|---|---|
| **Do without asking** | Parameterise a query. Add an ownership check. Move a literal secret to an env var. Add a missing `.gitignore` entry. Pin a dependency. |
| **Ask first** | Change auth flow, session lifetime or token storage. Add a new dependency with network or native code. Widen CORS. Change encryption, key derivation or a data format at rest. Add telemetry or a new third party that receives user data. Rewrite git history. |
| **Never** | Commit a secret, even "temporarily". Disable TLS verification outside a throwaway local test. Log tokens, passwords or full request bodies with personal data. Bypass a hook with `--no-verify`. Roll your own crypto primitive. |

A rule that must hold every time belongs in a hook or CI check, not in prose. The pre-commit file
blocker and a secret scanner are the minimum. Read `references/repo-hygiene.md` when setting up a
repository or a pre-commit hook.

## Defaults by area

**Secrets.** `.env` gitignored, `.env.example` committed with placeholders and a comment per key.
Production secrets come from a secrets manager at runtime, not baked into images. Rotation procedure
is in the `devops` skill.

**Passwords.** Argon2id (OWASP minimum: 19 MiB memory, 2 iterations, parallelism 1), else scrypt, else
bcrypt. Never a fast hash (MD5, SHA-*), never reversible encryption. Compare hashes with the library's
verify function.

**Tokens in the browser.** Session and refresh tokens in `HttpOnly; Secure` cookies with
`SameSite=Lax` (use `Strict` when no cross-site navigation needs the session, since `Strict` breaks
sign-in redirects back from an identity provider). Cookies need CSRF protection for state-changing
requests. Short-lived access tokens may live in memory. Never in `localStorage`: any script on the
page can read it.

**Password reset and one-time tokens.** Generate at least 32 random bytes from a CSPRNG and store
only a hash of the token, so a database leak does not hand out working links. Single use, short expiry
(minutes, not days), invalidated when used and when the password changes. Respond the same way whether
or not the account exists. After a reset, revoke the user's other sessions and refresh tokens. Put the
token in the link path or fragment over HTTPS, and keep it out of logs and analytics.

**JWTs.** Pin the accepted algorithm per key server-side and reject `none`. Never let a token header
choose the key (`jku`, `x5u`, unchecked `kid` paths). Verify signature, `exp`, `iss` and `aud` on every
request. Keep the payload free of secrets: it is encoded, not encrypted. Refresh tokens rotate on use
and can be revoked.

**CORS.** An explicit origin list. Never reflect the request `Origin`, never allow `null`, never `*`
with credentials. Development origins live in development config only. `*` is fine only for a truly
public, cookie-less endpoint.

**Webhooks.** Verify the provider's HMAC over the raw body before parsing, with a constant-time
compare, and reject stale timestamps to stop replays.

**Errors.** Return a generic message and an opaque error id. Log the detail on the server. Stack
traces, SQL fragments, file paths and versions in a response are a map for the attacker.

**Rate limits.** Login, password reset, OTP, signup and token endpoints are throttled per account and
per IP, with backoff.

**Outbound requests (SSRF).** If a user supplies a URL or host: allow-list schemes and hosts. Resolve
the name and reject private, loopback and link-local ranges (including the cloud metadata address
`169.254.169.254`). Re-check after every redirect, or disable redirects.

**Paths and destructive operations.** Any delete, overwrite or `rm -rf` on a path built from input or
from a variable that could be empty must resolve the path and check it is inside the intended
directory first. An empty variable turns `rm -rf "$DIR/"` into `rm -rf /`.

**Encryption at rest.** Use a vetted library and an AEAD mode (AES-256-GCM or ChaCha20-Poly1305).
Derive keys from a passphrase with Argon2id and a random salt. Hold keys in memory or the platform key store. Read
`references/encryption-and-privacy.md` before designing encryption, backups, sync or a privacy policy.

**Personal data.** Collect the minimum. Do not add analytics, crash reporting or a third party that
receives user data without asking. Send an external service only what the feature needs. Personal
data never goes into logs, prompts or error messages unless the feature needs it there.

**Dependencies.** Run the audit tool for the language before a release and in CI, failing on critical
and high:

| Ecosystem | Command |
|---|---|
| Python | `pip-audit` |
| JS/TS | `npm audit --audit-level=high` (or `pnpm audit`) |
| Rust | `cargo audit` |
| Go | `govulncheck ./...` |
| Containers | `trivy image <image>` or `grype <image>` |
| Swift | No first-party tool. Use GitHub Dependabot alerts or OSV. |

Medium findings need a written exception with a date. Transitive dependencies count.

## Gotchas

- **Deleting the leaked file.** Removing `.env` in a new commit leaves the secret in history and in
  every clone and fork. Rotate, then rewrite with `git filter-repo`, then force every clone to re-sync.
- **A filename blocker is not a secret scanner.** Blocking `.env` does not catch a key pasted into
  `config.py`. Run a content scanner (gitleaks or trufflehog) as well, over history once and on each
  commit after.
- **`^\.env` only matches the repository root.** A hook pattern must use `(^|/)\.env` to catch
  `services/api/.env`.
- **AES-GCM nonce reuse.** Reusing a nonce with the same key breaks both confidentiality and
  integrity. Use a fresh random 96-bit nonce per message and rotate the key well before 2^32 messages.
- **Hashing with a secret is not encryption, and encryption is not hashing.** Passwords are hashed.
  Data you must read back is encrypted. A reversible password store is a breach waiting to happen.
- **Allow-listing a hostname then fetching it.** DNS can change between check and fetch, and a redirect
  can leave the allowed host. Pin the resolved IP for the request or re-validate each hop.
- **Escaping instead of parameterising.** Manual escaping misses an encoding or a context every time.
- **Prompt "sanitising".** No filter makes untrusted text safe inside a prompt. Limit what the model
  can do with the result instead: least-privilege tools and a human confirmation for consequential
  actions.
- **Security indicators that compute the wrong thing.** A status flag that reports "encrypted" while
  writes go out in plaintext is worse than no flag. Test the indicator against the failing state, and
  read compiler and linter warnings such as "comparison always true": they often name exactly this.

## Rationalisations

| Thought | Reality |
|---|---|
| "It's only a test key." | Test keys get promoted, reused and scraped from public repos within minutes. |
| "It's internal, behind the VPN." | Internal networks get breached. Authenticate every call. |
| "The framework handles that." | Check that it does on THIS route. Order and early returns bypass middleware. |
| "Nobody knows the URL." | Obscurity is not access control. URLs leak through logs, referrers and history. |
| "We'll add auth before launch." | The endpoint ships first and the auth never does. Add it now. |
| "It's just a quick script." | Quick scripts become cron jobs with production credentials. |

## Red flags

Stop and fix before continuing if you see: a literal that looks like a key; `shell=True`, `eval`,
`exec` or string-built SQL near input; `verify=False` or disabled certificate checks; a handler that
loads a record by id with no owner check; `allow_origins=["*"]` beside credentials; a token in
`localStorage`; a log line that prints headers, bodies or tokens; `--no-verify` anywhere.

## Verification

Evidence, not prose:
- Secret scan over full history returns nothing new: `gitleaks git .` (older gitleaks: `gitleaks detect`),
  or `trufflehog git file://.`.
- `git status --short` shows no sensitive file staged. The pre-commit hook blocks a deliberately staged
  dummy `.env` (prove it can fail).
- For each new endpoint, a test that calls it as a second user with the first user's id and gets `403`
  or `404`, and one with no credentials that gets `401`.
- For each input that reaches a query, shell or path, a test with a hostile value (`' OR 1=1--`,
  `; id`, `../../etc/passwd`) that is rejected or inert.
- The dependency audit command exits zero at the agreed severity.
- For a full review before launch, hand over to the `security-audit` skill.
