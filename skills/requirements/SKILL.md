---
name: requirements
description: "Use when turning a decided feature into a spec: user stories, acceptance criteria, Given/When/Then, non-functional requirements, scope and the won't-have list, definition of ready, experiment design. Also \"write this up as a spec\" from a conversation. Not for whether to build it (use `product-management`) or schedules (use `project-management`)."
license: MIT
---

# Requirements

Work top-down: business goal → user need → feature → story → acceptance criteria. Never write acceptance criteria before you can state the goal they serve.

## Rules that matter most

1. **Every must-have has at least one testable acceptance criterion.** "Works well" and "is fast" are not criteria. A criterion a tester cannot check mechanically is a wish.
2. **Write the Won't list.** Explicitly deferred items stop being re-raised every sprint. The out-of-scope section is the highest-leverage part of a spec.
3. **Cover failure and edge cases, not only the happy path.** For each story ask: empty input, the maximum, a duplicate, no permission, the network fails, two users at once. Missing edge cases are where specs fail.
4. **Ambiguity is a question, not a guess.** Collect open questions in their own section with an owner. Do not resolve them silently in the spec; a silent guess becomes a bug that looks intended.
5. **Specify NFRs with numbers and a way to measure them.** "Scalable" is not a requirement. "p99 under 500ms at twice expected peak, checked by load test" is.
6. **A story that fails the definition of ready goes back.** Defining scope is not the implementer's job mid-build.

## When not to use

- Deciding whether a feature is worth building, or ranking features: the `product-management` skill.
- A brand-new product idea: the `product-exploration` skill.
- Breaking a spec into a build plan with tasks and files: the `workflow` skill.

## Two modes

- **Interview** (default for a new feature): ask the questions the spec needs, one topic at a time, then write it.
- **Synthesis** (when the person says "write up what we discussed" or the conversation already holds the decisions): do not interview. Write the spec from the conversation and the codebase, and list every gap under Open questions.

## User stories

Format: "As a [specific user type], I want [specific capability], so that [measurable outcome]."

- **Specific user**: not "user" or "admin". A first-time visitor, a billing admin, a support agent with read-only access.
- **Specific capability**: verb, noun and scope. Not "manage orders" but "filter orders by status and date".
- **Measurable outcome**: what changes for them. Not "find things faster" but "reach any order in three clicks or fewer".

Check each story against INVEST: Independent, Negotiable, Valuable, Estimable, Small, Testable. A story that fails Small gets split by workflow step, by data variant or by business rule, never by technical layer (a "backend story" and a "frontend story" deliver nothing alone).

## Acceptance criteria

Each criterion is testable, specific (one condition, no "and also"), observable (behaviour a user or tester can see) and scoped. Together they cover success, failure and edge cases.

Use Given / When / Then when the behaviour depends on state:

```
Given a cart with one item that went out of stock after it was added
When the customer opens checkout
Then the item is marked unavailable
And the order total excludes it
And the Pay button stays enabled for the remaining items
```

Write expected values from the business rule, not from what the current code does. A criterion copied from the implementation can never fail.

## Spec template

Use this shape for any spec longer than a single story. Leave out sections that are truly empty; never leave Out of scope or Open questions out.

```markdown
## Problem
The user's problem, from their side.
## Solution
What changes for the user, from their side.
## User stories
Numbered. Cover every actor and every path, including the unhappy ones.
## Acceptance criteria
Per story, Given/When/Then where it helps.
## Non-functional requirements
Table below, with numbers.
## Decisions
Modules touched, interfaces changed, data shape changes, contracts. No file paths or code: they go stale.
## Testing decisions
What a good test looks like here (external behaviour, not internals), which modules get tests, existing tests to model on and the seams to test at.
## Boundaries
Always (the implementer just does it) / Ask first (needs a decision) / Never (out of bounds).
## Out of scope
What this does not include, and why.
## Open questions
Each with an owner and a decide-by date.
```

Agree the testing seams with the person before the spec is final: prefer existing seams, and the highest one that still exercises the behaviour.

## Non-functional requirements

Capture for every project. Leave a row out only by writing "not applicable, because".

| NFR | Requirement | How measured |
|---|---|---|
| Performance | p99 API response under 500ms | Load test at 2× expected peak |
| Availability | 99.9% monthly | Uptime monitor and alert |
| Scalability | 10k concurrent users | Load test |
| Security | Personal data encrypted at rest | Security review |
| Privacy and compliance | Data residency, retention period | Legal or compliance review |
| Accessibility | WCAG 2.2 AA | Automated scan plus manual audit |
| Observability | Every failure path logs a reason | Log review in staging |

## Scope with MoSCoW

- **Must**: without it the release cannot ship.
- **Should**: high value; shipping without it is possible but painful.
- **Could**: cut first under pressure.
- **Won't (this time)**: written down, with the reason.

To rank inside a tier, use RICE from the `product-management` skill. A score never overrides a Must or a Won't.

## Definition of ready

A story moves into build only when all of these hold:

- [ ] Specific user type
- [ ] Acceptance criteria written and testable, including failure cases
- [ ] External dependencies identified and available
- [ ] Designs approved, if it has UI
- [ ] NFRs stated where they apply
- [ ] Sized
- [ ] Its own "does not include" line

## Experiments

When a story is an experiment, its acceptance criteria must include the design. Read `references/experiment-design.md` before writing one: it covers hypothesis, metrics, sample size, stopping rules and analysis.

## Gotchas

- **The generic "user".** It hides two actors with different permissions and needs. Name them.
- **Compound criteria.** "Saves the record and emails the owner" is two criteria; one can pass while the other fails.
- **Criteria written from the code.** They describe what it does, not what it should do, so they cannot catch a bug.
- **Horizontal stories.** "Build the API" then "build the UI" ship nothing usable until both are done. Slice vertically.
- **NFRs left to the end.** Performance and accessibility retrofitted after launch cost several times more.
- **Silent assumptions.** If you had to guess to write a line, that line belongs in Open questions too.
- **The Won't list that nobody agreed.** Out of scope only works when the decision owner signed it.

## Verification

Before handing a spec to architecture or build:

- [ ] Every must-have has at least one acceptance criterion, and at least one failure-case criterion
- [ ] NFRs have numbers and a measurement method
- [ ] Conflicting requirements surfaced and resolved, or listed as open questions
- [ ] External dependencies listed with owners and dates
- [ ] Constraints (regulatory, technical, budget) written down
- [ ] Won't list written and agreed
- [ ] Success metrics defined: how we will know it worked
- [ ] A reader who was not in the conversation can restate the scope correctly (test it with a fresh subagent given only the spec)
