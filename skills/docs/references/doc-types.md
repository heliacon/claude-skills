# Document type skeletons

Read the section for the doc you are about to write. If the project already has its own format for that type, use the project's.

## Contents

- README
- ADR
- Changelog
- Runbook
- API reference

## README

```markdown
# <name>

<What it is, in two sentences. The problem it solves.>

Status: <working | beta | experimental>. Licence: <SPDX id>.

## Quick start
<The fewest commands from a clean machine to a visible result. Each one tested.>

## What it does
| Feature | Status | Notes |
|---|---|---|

## Configuration
| Variable | Default | Meaning |
|---|---|---|

## Known issues
- <issue, severity, workaround>

## Contributing / Development
<How to run tests, link to CONTRIBUTING.md.>
```

Rules: the quick start runs on a clean checkout; status reflects the current version, not the next one; no badges or sections that do not help the reader do something.

## ADR

Find the existing convention first: an `adr/` or `docs/decisions/` folder, a numbering scheme, a config file naming the directory. Match it. If none exists, use this:

```markdown
# <NNNN>. <decision in a short phrase>

Date: <YYYY-MM-DD>
Status: proposed | accepted | superseded by <NNNN>

## Context
<The forces at play. What problem, what constraints.>

## Decision
<What we will do, in active voice.>

## Alternatives considered
<Each option and why it lost.>

## Consequences
<What becomes easier, what becomes harder, what we now must do.>
```

Rules: an accepted ADR is never edited to change the decision; write a new one that supersedes it and update the old one's status line. One decision per ADR.

## Changelog

Group by release, newest first, under headings Added, Changed, Deprecated, Removed, Fixed, Security (the Keep a Changelog convention). Keep an Unreleased section at the top. Each line is written for the user of the software: what changed for them, not which file moved. Link each version to its diff.

## Runbook

```markdown
# Runbook: <alert or situation>

Trigger: <the alert name or symptom that sends someone here>
Impact: <who is affected and how>
Severity guide: <when this is critical, when it can wait>

## Check
1. <command or dashboard> → <what normal looks like>

## Mitigate
1. <the fastest safe action that stops the harm, with the exact command>

## Fix
1. <the root-cause steps>

## Verify
<how to confirm recovery, with the command and expected output>

## Escalate
<who, when, how>
```

Rules: every command copy-pasteable and tested in a non-production environment; mitigate comes before fix; the runbook is updated after every incident that used it.

## API reference

- One entry per endpoint or function: signature, parameters with types and defaults, return shape, errors with their conditions, one example request and response.
- Generate it from the source of truth (an OpenAPI spec, typed signatures, docstrings) where you can. Hand-written reference drifts first.
- Examples are valid, runnable and parsed before publishing.
