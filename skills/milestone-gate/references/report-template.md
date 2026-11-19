# Gate report template

Read this when creating the gate report. Save as `docs/gates/GATE-<milestone>-<YYYY-MM-DD>.md`.

```markdown
# Gate: [milestone]  ([YYYY-MM-DD])

Milestone source: [named in the request | inferred from roadmap/todo: reason]
Scope statement: [link]
Commit gated: [hash]

## Entry criteria

| Check | Status | Evidence |
|---|---|---|
| All phases passed their phase check | | |
| Suite green on the milestone branch | | |
| No open Critical/High bugs | | |
| Tree clean | | |
| Scope statement exists | | |

## Track A: engineering

| Item | Status | Evidence | Notes |
|---|---|---|---|
| A1 ADRs for this milestone's decisions | | | |
| A1 No new cycles or layering violations | | | |
| ... one row per checklist item ... | | | |

## Track B: product

| Item | Status | Evidence | Notes |
|---|---|---|---|
| B2 Traceability table complete, no orphans | | | |
| B4 Decision owner visual sign-off | | [name, date] | |
| ... | | | |

## Traceability (B2)

| Story | Criterion | Evidence (test or script) | Built in (commit/file) | Status |
|---|---|---|---|---|

## Waivers

| Item | Waiver text | Decision owner | Date |
|---|---|---|---|

## Verdict

**PASSED** | **BLOCKED (items: A2, B3)**

Re-runs: [date, sections re-run, new verdict]
```

Status values: PASS, FAIL, WAIVED, N/A. Evidence is a command plus an output excerpt, a file and line, or
a capture path. An empty Status or Evidence cell is a FAIL.
