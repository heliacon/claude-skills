---
name: uat
description: "Use when checking a build against business intent and real user goals before sign-off: user acceptance testing, persona missions or journeys, acceptance criteria into acceptance scripts, \"can a user actually do this\" and business sign-off. Not for verifying code correctness (use `tdd` or `testing-strategy`) or test plans and defect process (use `quality-assurance`)."
license: MIT
---

# User acceptance testing

Developer testing asks "does the code do what we built it to do?". UAT asks "can a real user reach their
goal, and is the result what the business intended?". A product can pass every automated check and
still fail UAT: nobody could find the button, the flow assumed knowledge the user lacks or the output
was correct and useless. UAT is the gate that catches this.

## The rules that matter most

1. **The bar is "completed unaided".** No builder beside the user, no inside knowledge, no reading the
   code. A mission that needed a hint is a FAIL for that script, even if it finished.
2. **Write steps as intentions, not clicks.** "Book the same appointment as last time", not "open History, then
   the repeat button". A script that names the button has handed over the answer the user had to discover.
3. **The builder cannot run their own UAT.** They know where everything is. This applies to an agent:
   the agent that wrote the feature has read the code. Run missions with a fresh agent that gets only the
   running product and the persona, or with a person who did not build it.
4. **Record friction, not only pass or fail.** Hesitation, wrong turns and workarounds are findings
   even when the mission passes.
5. **Sign-off is a named person**, accepting the build against written exit criteria. "The tests are
   green" is not sign-off. If the exit list is incomplete the status is BLOCKED.

## Where UAT sits

unit, integration, end-to-end, QA sign-off, **UAT**, release. UAT runs on a candidate QA has passed. If
QA is red, UAT does not start.

| UAT is | UAT is not |
|---|---|
| Acceptance against business intent | Verifying code correctness (that is QA) |
| Judged from the user's side | Judged from the implementer's side |
| Real goals, real personas, production-shaped data | Synthetic fixtures and mocked boundaries |
| A pass or fail sign-off decision | A bug hunt (that is exploratory QA) |

## Persona-mission scripts

Pick a real persona, give them a mission they genuinely hold, describe the journey as intentions and
judge whether they finish it unaided.

- The persona comes from user research or real segments. Never "a user" in the abstract and never the
  builder imagining themselves.
- One mission per script. A mission is a goal the user holds, not a feature to exercise.
- Name the one trait that matters for this mission ("a first-time user wary of sharing personal data,
  abandons on any confusion").

```markdown
## UAT-[id]: [mission name]

**Persona:** [name or segment + the trait that matters here]
**Goal (their words):** "[what they are trying to achieve]"
**Preconditions:** [account state, data present, entry point]

**Journey (intentions, not clicks):**
1. [intention]
2. [intention]

**Expected outcome:** [what they can now see, do or trust]
**Acceptance criteria covered:** [AC-xx, AC-yy]

**Result:** PASS | FAIL
**Completed unaided:** YES | NO  (NO means FAIL)
**Friction:** [hesitations, wrong turns, doubts, workarounds]
**Defects raised:** [ids]
```

A mission that only completes because the tester already knew the way is logged "completed with prior
knowledge", and the discoverability gap is the defect.

**Review the scripts before running them.** Show the product owner the persona list and the missions
first. A wrong mission run perfectly is wasted work.

## Acceptance criteria into acceptance scripts

Every acceptance criterion becomes at least one script. Gherkin, where used, is written from the user's
side:

```gherkin
Scenario: A returning customer reorders a past item
  Given I have placed two orders in the last month
  When I go to buy the same thing again
  Then I can reorder it without searching the catalogue
  And I can see the price before I confirm
```

- `Given` is the user's world, not database rows.
- `When` is an intention, not a gesture.
- `Then` is what the user can observe or trust. A `Then` that mentions a table, an HTTP status or a
  function belongs in QA.

## Exploratory charters

Scripts cover agreed paths; charters cover what nobody imagined.

```
Charter:  Explore [area] with [approach] to discover [information]
Timebox:  45 or 90 minutes, one tester
Notes:    running log of what was tried and seen
Debrief:  bugs, questions and coverage gaps, split out
```

Tag each observation:
- **Bug:** wrong against intent. Raise a defect.
- **Question:** correctness unclear. Route to the product owner. Blocks sign-off only on a critical path.
- **Coverage note:** something no script covers. Becomes a new mission.

## Keep a UAT log

Keep one file per phase or release, for example `tasks/uat-<phase>.md`, so the run survives across
sessions. It holds the missions, each result with the build it ran on, the friction notes and a **gaps**
list. Write each failure as a gap: mission, step, expected (from the user's side), actual, severity.
Resume from the log; never re-run from memory.

## Entry criteria (all must hold, else do not start)

- [ ] QA has passed the candidate; automated suites green
- [ ] Every story has testable acceptance criteria
- [ ] The environment mirrors production shape (below)
- [ ] Representative data loaded, not developer fixtures
- [ ] Personas and missions agreed with the product owner
- [ ] Known defects carried in are listed, so testers do not chase them

## Environment and data parity

"It worked in staging" is the classic trap. Mirror production in shape:

- **Data:** realistic volume and distribution, messy real edge records (long names, missing optional
  fields, old accounts, non-ASCII). Anonymised production-like data where privacy allows; never live
  personal data.
- **Config:** feature flags, environment variables, third-party timeouts as production sets them.
- **Integrations:** real services or faithful sandboxes, not stubs that always succeed. A mock payment
  gateway is not UAT of payment.

If parity cannot be met, write the gap down. A pass on a non-parity environment is a conditional pass,
and the condition goes in the sign-off.

## Defects in UAT

| Severity | Meaning |
|---|---|
| Critical | Blocks the mission with no workaround, or gives a wrong result the user would trust |
| High | Mission possible only with an awkward workaround |
| Medium | Noticeable friction; goal still reached; trust intact |
| Low | Cosmetic or wording |

The tester proposes severity; the product owner sets priority. Each defect carries the persona and
mission it broke, exact steps, expected and actual from the user's side, environment and a screenshot or
recording where behaviour is visual. File every defect before it is fixed; drop none silently.

**Blocks sign-off:** any open Critical, any open High on a sign-off path, any Medium the product owner escalates.

## Traceability

| Criterion | Scripts | Charters | Executed (build) | Result |
|---|---|---|---|---|
| AC-01 | UAT-03 | CH-01 | yes (build 142) | PASS |
| AC-02 | UAT-04 | | yes (build 142) | FAIL (DEF-12) |
| AC-03 | | | no | UNTRACED |

A criterion with no script is untested acceptance and blocks sign-off. A script with no criterion means a
missing criterion or scope creep. Both are findings. Close the matrix before declaring UAT complete.

## Regression on change mid-UAT

| Change | Re-run |
|---|---|
| Isolated fix, no shared code | The failed script and its direct siblings |
| Shared component touched | Every mission that passes through it |
| Data model, auth or permissions | The full critical-path set |
| Config or environment | Re-establish parity, then the full critical-path set |

Record which scripts ran on which build. Sign-off states what was verified on the final candidate, not on
an earlier one.

## Exit criteria (sign-off)

- [ ] Every acceptance criterion maps to an executed script with a recorded result
- [ ] Every critical mission PASS and completed unaided
- [ ] No open Critical or High defect on a sign-off path
- [ ] Medium and Low defects triaged: accepted or scheduled
- [ ] Questions on critical paths answered by the product owner
- [ ] Charters for changed areas run and debriefed
- [ ] Parity gaps written into the sign-off as conditions
- [ ] Named acceptor recorded, or status BLOCKED with reasons

## Red flags

- Scripts that say "click".
- The builder, or the agent that wrote the code, running the missions.
- "A user" with no persona.
- Only the golden path: no empty state, interrupted flow or bad data.
- Sign-off with untraced criteria or no named acceptor.
- A pass on three fixture rows on a tidy staging box, with no parity note.

## Verification

UAT is done when the log file shows, for the final build: every mission's result and friction notes,
the closed traceability matrix, the defect list with status and the sign-off block with the acceptor's
name and date (or BLOCKED and why).
