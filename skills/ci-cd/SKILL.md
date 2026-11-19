---
name: ci-cd
description: "Use whenever a GitHub Actions workflow, CI pipeline, pre-commit hook, Makefile, quality gate or release process is written, changed, hardened or sped up, and whenever CI is red, flaky, slow or handles secrets (pull_request_target, tokens, permissions). Load it before editing any workflow file. Not for rollouts or incidents (use `devops`) or provisioning (use `infrastructure`)."
license: MIT
---

# CI/CD

This skill covers the pipeline that lives in the repository: what runs on each push, what blocks a
merge and how a release is cut. How a release reaches users safely, and how it is watched afterwards,
is the `devops` skill. The servers and cloud resources underneath are the `infrastructure` skill.

## The rules that matter most

1. **A gate fails closed.** A failing check blocks the merge. No `continue-on-error` on a gate, no
   `|| true` after a test command, no `--no-verify`, no "skip CI" on a change that touches code.
2. **A gate must be able to fail.** A new check that has only ever run against the fixed code proves
   nothing. Break the thing it guards (revert the fix, add the bad pattern), watch the check go red,
   then restore. Calibrate against THIS defect, not a nearby one.
3. **An unrun check is not evidence.** A workflow file that exists is not a check that passed. Before
   believing a change is covered, find the run and read its result.
4. **Red CI is fixed at the cause.** Read the log, reproduce locally, fix the root cause. Never re-run
   until green, mark a test flaky, raise a timeout or loosen a threshold to make a failure go away
   without first knowing why it failed.
5. **Pin what you execute.** Third-party actions by full commit SHA (a tag can be moved to malicious
   code), base images by digest, tools by version. Give `GITHUB_TOKEN` the least `permissions:` it
   needs.
6. **Everything the pipeline does runs locally too.** CI calls the same `make test` (or script) a
   developer runs. A pipeline with logic only in YAML cannot be debugged.

## Pipeline shape

Order jobs so the cheapest, most likely failures stop the run first:

1. Lint, format check and type check (seconds).
2. Unit tests.
3. Build the artefact once. Later stages use that artefact, never a rebuild.
4. Security: dependency audit, secret scan, container scan.
5. Integration tests against real dependencies (service containers), not mocks.
6. Hand the artefact to deployment (see the `devops` skill for staging, rollout and smoke tests).

**Tiered suites.** When the full suite is slow, split it: a fast core on every push, the boundary and
integration tier on every pull request, the full suite nightly and before a release. Write down what
each tier never reaches, because a green core run says nothing about it. A full run regularly finds
defects (and resource limits such as out-of-memory) that the core never touches.

## GitHub Actions defaults

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read            # widen per job only where needed

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true  # a new push cancels the superseded run

defaults:
  run:
    shell: bash             # explicit bash adds -o pipefail

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 15     # a hung job should fail, not burn six hours
    steps:
      - uses: actions/checkout@<full-commit-sha>        # vN.N.N
      - uses: actions/setup-python@<full-commit-sha>    # vN.N.N
        with:
          python-version-file: .python-version
          cache: pip
      - run: make ci        # the same target a developer runs
```

- **Caching.** Key caches on the lock file hash. The setup actions for Python, Node and Go cache
  dependencies themselves. For Rust cache `~/.cargo/registry` and `target/`. For Docker use the build
  action's `cache-from` and `cache-to`. A cache is a speed-up only: the build must pass with it cold.
- **Matrix builds** only for real targets (supported language versions, shipped platforms). A
  single-target project gets one job.
- **Secrets.** Read from the platform secret store, never echoed. Pull requests from forks do not get
  secrets, which is correct.
- **`pull_request_target` and `workflow_run`** run with secrets and write permissions in the context of
  the base repository. Never check out and run the pull request's code in them.
- **Untrusted text in `run:`.** `${{ github.event.pull_request.title }}` inside a shell step is
  script injection. Pass it through `env:` and quote the variable.
- **Keep pins current.** Use Dependabot or Renovate for actions, so SHA pins do not rot.

## Quality gates

Every pipeline enforces, and fails on breach. The thresholds are suggested starting points; set your
own to suit the project:

| Gate | Suggested threshold |
|---|---|
| Tests | 100% pass |
| Lint and format | 0 errors |
| Type check | 0 errors |
| Dependency audit | 0 critical or high |
| Secret scan | 0 findings |
| Coverage | 80% of lines, and no drop on changed lines |
| Frontend bundle | Under 250KB per chunk (gzipped) |

Coverage measures what ran, not what was checked. A suite can execute every line and assert nothing.
Use mutation testing (see the `testing-strategy` skill) where it matters, and treat the coverage
number as a floor.

## Pre-commit hooks

The `pre-commit` framework, with every `rev:` pinned and updated by `pre-commit autoupdate`:

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: vX.Y.Z
    hooks:
      - id: ruff
      - id: ruff-format
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: vX.Y.Z
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-added-large-files
  - repo: https://github.com/gitleaks/gitleaks
    rev: vX.Y.Z
    hooks:
      - id: gitleaks
```

Run the same hooks in CI (`pre-commit run --all-files`), because local hooks are optional and
bypassable. The sensitive-file blocker is in the `security` skill's `references/repo-hygiene.md`.

## Makefile

Read `references/makefile-and-releases.md` when writing a Makefile, cutting a release or setting up a
changelog.

## Working with a red pipeline

When CI fails on your change, or an agent is handed a failing run:
1. Read the failing step's log from the first error, not the last line.
2. Reproduce it locally with the same command and versions. If it will not reproduce, compare
   environments (tool versions, env vars, file system case sensitivity, time zone, parallelism) before
   touching code.
3. Fix the cause and push. If the cause is in the pipeline itself, fix the pipeline in its own commit.
4. If a test is genuinely flaky, find what makes it nondeterministic (time, ordering, shared state,
   network) and fix that. Quarantine only with a tracked issue and a named person to fix it.

On a team, someone owns a red main branch at all times. Nobody merges on top of red.

## Gotchas

- **`|| true` and `set +e`.** A test step that cannot fail is decoration. Search the YAML and scripts for
  both.
- **Pipes hide failures.** `pytest | tee log.txt` returns `tee`'s status. In GitHub Actions the
  default Linux shell runs `bash -e` without `pipefail`. Set `defaults: run: shell: bash` (which adds
  `-o pipefail`) or write `set -o pipefail` in the step.
- **A gate that reads its own threshold.** A check that compares output to a constant from the code
  under test moves with the bug. Assert literal expected values.
- **`paths:` filters that skip the job a change needs.** A change to a shared config or lock file
  should trigger every job that depends on it.
- **A required check that never runs.** A required workflow skipped by a `paths:` filter leaves its
  check pending, so the pull request cannot merge. Filter inside the job, or make the required check a
  small job that always runs. Confirm the check appears on the pull request.
- **Release from a laptop.** Releases are built in CI from a tag, so anyone can trace the artefact to
  its commit.

## Verification

- The pull request shows every required check, each green, on the final commit.
- For each new gate: a link to or log of a run where it went red on a deliberately broken change.
- `make ci` (or the equivalent) passes locally from a clean clone.
- No action is referenced by a moving tag. `grep -nE 'uses: [^@]+@v[0-9]' .github/workflows/*.yml`
  returns nothing.
