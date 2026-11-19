# Pull requests and code review

Read when opening a pull request, reviewing one or choosing how to merge.

## Size

- Aim for 400 changed lines or fewer, excluding generated files, migrations and lock files.
- Over 800: split before review. Large pull requests get skimmed and bugs pass.
- One purpose per pull request: one feature, one fix or one refactor. A refactor mixed with a behaviour
  change hides the behaviour change.
- Application logic and infrastructure changes go in separate pull requests.
- If a large change cannot be split by feature, stack it: a chain of small pull requests, each building
  on the last, each reviewable on its own.

## Description template

```markdown
## What
[One sentence: what this changes.]

## Why
[The problem or requirement. Link the issue.]

## How
[The approach, especially anything non-obvious or any alternative you rejected.]

## Test plan
- [ ] Tests added or updated: [which]
- [ ] Checked by hand: [exact steps or commands, and what you saw]
- [ ] Edge cases: [list, or "none apply" with a reason]

## Risk and rollback
[What could break, and how to undo it.]
```

## Reviewer order

Check in this order and stop to comment on a blocking problem before polishing style:
1. **Correctness:** does it do what the description says, including the edge cases?
2. **Tests:** would they fail if the change were reverted? A test that passes either way checks nothing.
3. **Security:** new input crossing a trust boundary, auth or ownership checks, secrets, logging of
   personal data. Changes to auth, tenancy, privacy or data deletion need a reviewer other than the
   author.
4. **Scope:** does it do more than the description says? Unannounced changes are hidden risk.
5. **Readability:** could someone new understand it in five minutes?
6. **Performance:** N+1 queries, missing indexes, unbounded loops or loads over large data.

## Comment conventions

- **Blocking** (`must:`): correctness, security or data integrity. Do not approve until resolved.
- **Suggestion** (`nit:`): naming, style, small improvements. Approve anyway. The author decides.
- **Question** (`q:`): asking to understand, not requesting a change.

Say why, not only what. "This lets a user read another tenant's invoice because the query has no
tenant filter" gets fixed. "Add a tenant filter" gets argued about.

## Merge strategy

- **Squash (default):** one commit per pull request on the base branch, with the pull request title as
  the message. Clean history, easy revert.
- **Merge commit:** when the branch's individual commits are meaningful checkpoints worth keeping.
- **Rebase and merge:** small solo branches where each commit already stands alone. Never rebase a
  branch someone else has pulled.

Delete the branch after merge.
