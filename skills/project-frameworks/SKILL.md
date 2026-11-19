---
name: project-frameworks
description: "Use when starting or planning a multi-phase build and deciding which agents run in which phase: a web app, mobile app, game, CLI tool, API service, finance tool or data pipeline. Also when a project mixes two of these. Not for task-level planning inside one phase (use `workflow`) or schedules and risk logs (use `project-management`)."
license: MIT
---

# Project Frameworks

Seven opinionated templates, one per project type. Each gives an agent roster, a phase sequence
(goal, agents, skills, done-when) and the non-negotiables that type gets wrong most often. The
`orchestrator` agent uses them to sequence work; you can also use one directly to plan a build.

## The rules that matter most

1. **Pick one primary type, then borrow.** Choose by the main thing users touch. Add phases or
   non-negotiables from a second framework for the secondary part. Do not run two frameworks side
   by side.
2. **An independent check gates every phase (default).** A phase is done when the `tester` agent,
   or another reviewer who did not build it, has checked its done-when list against evidence (test
   output, a running build, a report), not when the implementing agent says so. The author is the
   worst judge of their own work. A small phase gets a short verdict rather than none; adapt the
   depth to the project.
3. **Decide the hard-to-retrofit things in the first two phases.** Each framework names them (save
   system, offline mode, PII classification, auth, audit trail). Deferring them is the most
   expensive mistake in this skill.
4. **Parallel agents need ownership boundaries.** When two agents run in parallel, write down which
   files or directories each one owns before they start. Two writers on one file corrupt each other's
   work.
5. **Build in vertical slices.** In implementation phases, finish one user journey end to end before
   starting the next, rather than all of one layer then all of the next.

## When not to use

- Breaking one phase into tasks: the `workflow` skill.
- Estimates, critical path, risk and status reporting: the `project-management` skill.
- Deciding whether the product should exist at all: the `product-exploration` skill, before this one.
- Closing a milestone: the `milestone-gate` skill, at the end of the relevant phase.

## Choosing the type

| If the main deliverable is | Use | Read |
|---|---|---|
| A product used in a browser | Web app | `references/webapp.md` |
| An app installed on iOS or Android | Mobile | `references/mobile.md` |
| Something played | Game | `references/game.md` |
| A command run in a terminal | CLI | `references/cli.md` |
| An API other software calls, with no UI of its own | API service | `references/api-service.md` |
| Software that calculates, moves or reports money | Finance tool | `references/finance-tool.md` |
| Data moved and transformed for analysis or downstream systems | Data pipeline | `references/data-pipeline.md` |

Read the reference for the chosen type before writing the plan. Read a second one only for the
phases or non-negotiables you are borrowing.

Common mixes:

- **Web app that handles money**: web app phases, plus the finance tool non-negotiables (decimal
  arithmetic, audit log, reconciliation) and its compliance step in architecture.
- **Mobile app with its own backend**: mobile phases; run API service phases 1 to 2 alongside mobile
  phase 2 so the contract exists before screens depend on it.
- **Game with online features**: the game framework already has an optional backend phase; borrow
  the API service security baseline for it.
- **Dashboard over a warehouse**: data pipeline first; the dashboard is a web app phase 3 to 5 on top.
- **A library**: closest is CLI (interface design, versioning, distribution); drop the CLI UX
  standards.

## What each framework gives

Every reference file has the same parts, so you can scan them quickly:

- **Agent roster**: which agents take part and in which phases.
- **Phases**: for each, the goal, the agents in order (`a > b` is sequence, `a + b` is parallel),
  the skills to load and the done-when list.
- **Non-negotiables**: the type-specific rules that are cheap early and expensive late.
- **Skill loading table**: phase to skills, for quick lookup.

Agents named in the frameworks: `pm`, `analyst`, `ux`, `designer`, `architect`, `database`,
`backend`, `frontend`, `security`, `devops`, `finance`, `tester`. The `orchestrator` sequences them;
`sysadmin`, `marketing`, `seo` and `teacher` join when a project needs them (bare-metal servers,
launch, search visibility, retrospective).

## Running a phase

For each phase, write in the plan:

```
Phase N: <name>
Goal:        one sentence
Agents:      a > b + c        (who owns which files, when parallel)
Skills:      the skills each agent loads
Done when:   checkable items, each with the evidence that proves it
Gate:        tester verdict and where its report is saved
```

Write the done-when list before the phase starts. Adding items after seeing the work is how a gate
turns into a rubber stamp.

## Gotchas

| Mistake | Correction |
|---|---|
| Picking the framework by technology ("it is React, so web app") | Pick by what the user touches and what can go wrong |
| Running the security review only at the end | Each framework puts a security baseline early; keep it there |
| Skipping the tester gate for a "trivial" phase | Every phase gets a verdict; trivial phases get a short one |
| Parallel agents with no file ownership | Write the boundary into the plan before starting |
| A framework phase that does not fit, kept anyway | Drop it and say why in the plan; the templates are defaults, not law |
| Deferring the save system, offline mode or PII classification | Decide in phase 1 or 2, as the framework says |
| Building every backend endpoint, then every screen | Vertical slices: one journey working end to end first |

## Verification

- [ ] The plan names the primary framework and any borrowed parts, with the reason
- [ ] Each phase has goal, agents, skills and a done-when list written before it starts
- [ ] Parallel steps name the files each agent owns
- [ ] The hard-to-retrofit decisions for this type are recorded in phase 1 or 2
- [ ] Each completed phase has a saved tester verdict with evidence
