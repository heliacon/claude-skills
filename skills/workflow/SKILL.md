---
name: workflow
description: Use when starting or resuming a multi-step build, planning a task with 3 or more steps, writing a plan or tasks/todo.md, ending a session or phase, writing HANDOFF.md, recording a lesson after a correction or briefing subagents. Phrases like "plan this", "pick up where we left off", "wrap up". Not for schedules and estimates; use `project-management`.
license: MIT
---

# Workflow

How to plan, build, finish and hand over work across sessions without losing state or repeating mistakes.

What follows is a recommended default for long, multi-session builds. Adapt it to the project: where its own `CLAUDE.md` or contributing guide sets a different process, that wins.

## Rules that matter most

1. **Plan before building anything with 3 or more steps or an architectural choice.** Write the plan to `tasks/todo.md` with checkable items. Surface the unknowns in the plan, before any code.
2. **When it goes sideways, stop and re-plan.** Three failed attempts at the same problem means the design or the diagnosis is wrong. More pushing makes it worse.
3. **Never call a task done without proof.** Run the tests, run the thing, read the output. A green suite is necessary, not sufficient: exercise the behaviour the way a user would. Ask: would a senior engineer approve this diff?
4. **Every correction from the person becomes a lesson.** Write it to `tasks/lessons.md` (or the project's equivalent) as a rule that prevents the repeat, and read it at session start. A correction that is not written down tends to recur in the next session.
5. **Never skip safety checks to get a commit through.** NEVER use `--no-verify` or disable a pre-commit hook: the hook is the check you would otherwise have to remember.
6. **Record a non-trivial bug before fixing it.** File it in the project's tracker (or `tasks/lessons.md` if there is none) with reproduction, expected and actual. A fix without a record leaves the reasoning only in a commit message. A trivial fix can be explained in the commit.
7. **Minimal impact.** Touch only what the task needs. Find root causes; no temporary fixes. Prefer changes that are easy to undo, and commit before a risky step.

## When not to use

- A one-line fix or a question: just answer or fix it.
- Estimates, critical path, risk registers, status updates for stakeholders: the `project-management` skill.
- Declaring a milestone done: the `milestone-gate` skill.

## Session start: the context loop

Before any action in a new or resumed session:

1. Read the project `CLAUDE.md` in full.
2. Read `HANDOFF.md` (what was built, what is next, gotchas). If it does not exist, note that and continue.
3. Read `tasks/lessons.md`. If it does not exist, note that and continue.
4. Run `git log --oneline -10`.
5. Run the project's fast test tier (the full suite if it is quick).
6. Report in one block: phase, last commit, tests passed and failed, lessons loaded, the next task.

Then confirm the next task before writing code, unless the person has already told you to proceed. Once they have, make the reasonable decisions within that scope and record them rather than asking again; stop only for a genuine blocker (see Hard stops).

Skipping the loop is how stale assumptions cause silent regressions.

## Writing a plan

Write for an implementer who is capable but has never seen this codebase and has no taste for this project's conventions. A plan is the set of decisions the implementer cannot make alone.

- **Map the files first.** List each file to create or change and its one responsibility. This is where decomposition gets decided.
- **Slice vertically.** Each task delivers a working, testable path through the system. "Build the backend" then "build the UI" delivers nothing until both land.
- **Size tasks so a reviewer could reject one and approve its neighbour.** Fold setup and scaffolding into the task that needs it.
- **Each task states:** the files, the interfaces it consumes and produces (exact names and types), the test it adds, the command that verifies it and the expected output.
- **Mark dependencies.** Which tasks block which. Independent tasks can run in parallel.
- **Add checkpoints** every few tasks: run the whole suite, and stop for review if the plan has drifted.
- **A follow-up change gets a delta**: what changes against the existing plan or spec, not a rewrite.

Self-review the plan before starting:

- [ ] Every requirement in the spec maps to a task. List any gaps.
- [ ] No line decides nothing ("handle edge cases", "add validation", "TBD"). Replace each with the actual decision.
- [ ] No step pastes the code the signature and test already determine.
- [ ] Names and types are the same in every task that uses them.
- [ ] The failure modes the spec implies but no task tests are listed, and each gets a test.

## Building a phase

Keep a phase small enough to finish and verify in one session. Combined phases are hard to verify and hard to hand over.

Before writing code:

- [ ] Phase definition read from the plan
- [ ] Only the skills this phase needs are loaded
- [ ] Blocking decisions written down (`tasks/decisions.md` or ADRs). Do not build on unstated assumptions.
- [ ] Dependencies identified (packages, infrastructure, migrations)
- [ ] Test strategy decided (what is unit, what needs a real service)
- [ ] Existing code to reuse identified

Build sequence:

1. Write the tests first and watch them fail (see the `tdd` skill).
2. Commit the test skeletons.
3. Implement until they pass. Commit after each passing group.
4. Run the regression suite from earlier phases. It must still pass.

While iterating: fix, rebuild, retest in a tight loop. Never skip a failing test; fix it or explain why it is expected. Write lessons as they happen, not at the end from memory.

When a step needs a decision: if it is internal (status codes, poll intervals, sort orders, names, log levels), make the reasonable choice, record it in `tasks/decisions.md` and continue. If it changes the data model, user-facing behaviour or security, and the answer is in no file you have, that is a **blocking question** (see Hard stops).

Demand elegance for non-trivial changes: before presenting, ask whether there is a simpler, clearer way knowing what you now know. Skip this for obvious fixes; do not over-engineer.

## Ending a phase

Three parts, all mandatory: verify, retrospective, hand-off.

**Verify**
1. Run the full suite: this phase and all earlier ones.
2. Run the type checker on core logic where the language has one.
3. Exercise the feature directly (call the endpoint, run the CLI, load the page) and read the result.
4. Do not continue until all of it is green.

**Retrospective** (the part most often skipped)
5. `tasks/lessons.md`: bugs found by building, patterns found, anything review missed. What happened, why, and the rule.
6. `tasks/decisions.md` or a new ADR for any discovery that is an architectural decision.
7. Project `CLAUDE.md`: phase status, counts, new gotchas. README still matches what exists now, not the future.
8. Test coverage: does every case in the spec have a test? Did the build reveal untested edge cases? Add them now.
9. Cross-references: counts quoted in docs match the actual files; no stale references introduced.
10. Persistent memory, if the environment has it: update project status and newly verified facts. Do not store secrets, anything derivable from the code or one-off task details.

**Hand-off**
11. Write `HANDOFF.md`.
12. Commit with a message that says what the phase delivered.
13. Push, if the project's workflow expects it.

Templates for `todo.md`, `lessons.md`, `decisions.md`, `HANDOFF.md` and the retro checklist are in `references/templates.md`. Read it when creating any of those files.

## Lessons loop

- After any correction, add a lesson before continuing. Write the rule so that following it would have prevented the mistake.
- Make rules about the *class* of mistake, not the instance. "Check every call site of a renamed function" beats "check `parse_date` in `utils.py`".
- When the same correction comes twice, the first rule missed the cause. Rewrite it, do not add a second one.
- A lesson that applies beyond this project goes into persistent memory as well, if there is one.
- Prune: merge duplicates and delete rules the code now enforces (a lint rule, a test, a hook).

## Subagents

Use them to keep the main context clean: research, reading large docs, parallel independent work, long validation runs. One task per subagent. Write the brief as if to a peer who knows nothing:

```
Task: one specific task
Input: exactly what to use
Output: exactly what to return, and in what shape
Owns: the files it may change (no two parallel workers share a file)
Constraints: what not to do or load
Done when: the check that proves it
```

- Summarise results back into the main context. Never paste raw output.
- Review a subagent's work in two passes: first, does it do what the spec asked (nothing missing, nothing extra); then, is it good code. A clean diff that does the wrong thing passes the second check and fails the first.
- If a subagent hits a blocker, surface it. Do not chain another subagent to guess.
- Subagents that change files run in an isolated worktree or clone when another writer shares the tree. A broad `git add` from the parent will stage their half-finished edits otherwise.

## Hard stops

Stop and tell the person when:

1. **The session or usage limit is close.** Finish the current atomic unit (one function or one test, not the whole phase). Update `CLAUDE.md` and `HANDOFF.md`, commit (and push, if the workflow expects it), then say where to resume: the task and phase, the commit hash and the file to read first.
2. **A genuine blocker.** The answer is in no loaded file, and guessing would invent a decision about the data model, user-facing behaviour or security. Stop at once. Write it under "Blocking questions" in `HANDOFF.md`, commit and say so.

Not blockers (decide, record, continue): HTTP status codes, poll intervals, sort orders, naming, log verbosity, any purely internal detail.

## Gotchas

- **"Tests pass" as done.** The suite never reached the new code path, or mocked the part that broke. Run the real behaviour once.
- **A retro written from memory at the end.** Half the lessons are gone. Write them when they happen.
- **A plan that went stale.** The code moved and the plan did not. Update or consolidate the plan when reality diverges; do not keep two versions.
- **README describing the future.** Docs must match the version that exists.
- **Asking again after being told to proceed.** Within the agreed scope, make the reasonable call and record it. Ask only about decisions that change scope, data model, user-facing behaviour or security.
- **Re-planning by adding steps.** When a plan fails, find which assumption was wrong and fix that, rather than appending workarounds.
- **Parallel writers in one tree.** Two agents editing one checkout corrupt each other's work silently.

## Verification

A phase is done when: the full suite is green and you have its output; the feature was exercised directly; `tasks/todo.md` items are ticked with a Review section; lessons and decisions are written; `HANDOFF.md` names the single next task; the work is committed (and pushed, if the workflow expects it).
