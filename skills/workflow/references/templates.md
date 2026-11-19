# Workflow file templates

Read this when creating `tasks/todo.md`, `tasks/lessons.md`, `tasks/decisions.md` or `HANDOFF.md`, or when running a phase retro.

## Contents

- The tasks/ directory
- todo.md
- lessons.md
- decisions.md
- HANDOFF.md
- Retro checklist

## The tasks/ directory

```
tasks/
  todo.md       current phase plan, items [ ] and [x]
  lessons.md    rules learned from corrections and bugs
  decisions.md  decisions with rationale, append-only
HANDOFF.md      at the project root, rewritten at each session end
```

## todo.md

```markdown
## Phase N: <name>
Goal: <one sentence: what is true when this phase is done>
Done when: <the check that proves it>

### Tasks
- [ ] Task 1: <deliverable>. Files: <paths>. Verify: `<command>` → <expected>
- [x] Task 2: <deliverable>. Files: <paths>. Verify: `<command>` → <expected>
- [ ] Task 3 (needs Task 1): <deliverable>

### Checkpoints
- [ ] After Task 3: full suite green, plan still matches the code

### Blockers
- None

### Review
<filled in at phase end: what shipped, what changed from the plan, what was learned>
```

## lessons.md

```markdown
## Lessons

### <date>: <short description of the mistake>
What happened: <description>
Root cause: <why it happened>
Rule: <standing instruction that prevents the class of mistake>
Applies to: <all projects | this project>
```

## decisions.md

```markdown
## <date>: <decision title>
Context: <the problem>
Decision: <what was chosen>
Alternatives: <what was rejected, and why>
Consequences: <what this enables or constrains>
```

If the project already keeps ADRs in another format, use theirs (see the `docs` skill).

## HANDOFF.md

```markdown
# Handoff: <date>, phase <N>

## Built this session
- `path/to/file` : <what it does>
- `tests/test_module` : <tests added>

## Working and verified
- Tests passing: <which, and the command>
- Checked by hand: <what was exercised, and the result>
- Type checker: <clean | N errors>

## Next
<one specific task, not a phase summary.
Example: "Write failing tests for the normaliser's empty-input and unicode cases in tests/test_normaliser.py">

## Gotchas and non-obvious decisions
- <what would trip up someone resuming cold>

## Files changed
- created: <file>
- modified: <file>
- deleted: <file>

## Blocking questions
BLOCKING: <the exact question>
Why it cannot be decided without the decision owner: <reason>
```

## Retro checklist

Copy into the phase's Review section and tick:

```
- [ ] lessons.md updated with bugs found by building
- [ ] decisions.md or ADRs updated where a discovery warrants it
- [ ] Plan updated with what changed and the bugs found
- [ ] Project CLAUDE.md current (status, counts, gotchas)
- [ ] README matches what exists now
- [ ] Persistent memory updated, if the environment has one
- [ ] Test coverage reviewed and gaps filled
- [ ] Cross-references consistent (counts match, no stale references)
- [ ] Full suite green, this phase and earlier
- [ ] HANDOFF.md written
```
