---
name: ux-research
description: Use when planning or synthesising user research (interviews, usability tests, surveys), mapping a journey or job to be done, specifying an interaction's states, or running a heuristic review of a flow. Not for menus, labels, taxonomy or site structure; use `information-architecture`. Not for visual polish; use `designer`.
license: MIT
---

# UX research

How people try to get a job done with the product, where they fail, and what the
interface must do at every step. The evidence comes first. A flow designed from opinion
is a guess with a diagram attached.

Boundary: this skill owns people, tasks, flows and interaction states. The
`information-architecture` skill owns how content is organised, labelled and found. The
`designer` skill owns how a screen looks and reads.

## The rules that matter most

1. **Write the research question before choosing a method.** "Why do trial users not
   invite a colleague?" picks the method. "Let's do some interviews" picks nothing.
2. **Behaviour beats opinion.** What people did last time is evidence. What they say they
   would do is a forecast, and a poor one. Ask about past events, watch real tasks.
3. **Every finding carries its count and its source.** "4 of 6 participants missed the
   save button (sessions 2, 3, 5, 6)" is a finding. "Users found saving confusing" is not.
4. **Separate observation, interpretation and recommendation.** Write them in three
   columns. Mixing them hides which part is evidence and which part is you.
5. **Five participants per distinct user group finds most usability problems** in a
   qualitative test. It does not measure anything. Never quote a percentage from n=5.
6. **Every interaction spec covers all states**, not only the happy path (see below).
7. **Say what the research cannot tell you.** Every synthesis ends with its limits and
   the open questions for the next round.

## When not to use

- The question is "where should this content live" or "what should this menu say":
  use `information-architecture`.
- The question is "does this look considered": use `designer` or `visual-design`.
- You need a metric with a confidence interval: that is quantitative analysis, use
  `data-analysis`. Qualitative research finds the problems; it does not size them.
- Acceptance by the business owner: use `uat`.

## Method choice (one default per question)

| Question | Default method | Notes |
|---|---|---|
| What problem do they have, and how do they solve it today? | Interviews about the last real occurrence | 5 to 8 per segment; stop when new sessions stop adding themes |
| Can they complete this task with this design? | Moderated usability test, think-aloud | 5 per user group; real tasks, no hints |
| Where in the flow do people drop out? | Funnel analytics, then usability test the worst step | The data says where; only watching says why |
| Which of these features matter? | Kano questionnaire or top-task survey | Needs a sample large enough to count, not 5 |
| What do they call things / how do they group them? | Card sort | Hand over to `information-architecture` |
| Is the new version better than the old? | Same tasks, same metrics, both versions | Decide the metric before the test |

Combine one qualitative and one quantitative source when the decision is costly.
When they disagree, the disagreement is the finding: investigate it, do not average it.

## Interviews

- Recruit people who had the problem recently. A screener question about the last time
  it happened filters out people who only think they have it.
- Ask about one specific past event: "Tell me about the last time you..." then follow the
  story. Questions about the future ("Would you use...?") get polite fiction.
- No leading questions. "How did you decide?" not "Was the price the main factor?"
- Do not pitch, demo or defend the product during an interview. The moment you sell, the
  participant starts to please you.
- Silence is a tool. Wait three seconds after an answer before the next question.
- Take verbatim notes or record with consent. Quotes are evidence; paraphrase is not.

## Usability tests

Write the plan before recruiting:

```
Goal:          the decision this test informs
Participants:  who, how many, screener criteria
Tasks:         3 to 6, each a realistic goal in the user's words, never the UI's label
               ("You want to send last month's invoice to your accountant",
                not "Use the Export button")
Success:       what counts as done for each task, decided now
Measures:      completion, errors, time, assists, post-task ease rating
Script:        intro, consent, warm-up, tasks, debrief questions
```

- A task that names the button tests reading, not usability.
- Note where the participant hesitates, backtracks or says "I expected...". Those are the
  problems, even when the task completes.
- Rate each problem by severity: blocks the task, causes a major delay or error, minor
  annoyance, cosmetic. Fix in that order.

## Synthesis

1. Put every observation on its own line with participant ID and session.
2. Cluster by pattern, not by screen. Name each cluster as a finding sentence.
3. Count the participants behind each finding. One vivid quote is not a pattern.
4. Turn each finding into an insight (why it happens) and then an opportunity
   ("How might we..."). Keep the chain visible: opportunity, insight, finding, raw notes.
5. Identify segments from the data. If two groups behave differently, report them apart,
   do not blend them into one average user.
6. End with **methodology notes** (who, how many, how recruited, what was not covered) and
   **questions for further research**.

## Jobs to be done

For each user group, name three parts of the job:

- **Functional**: the task ("file my quarterly tax return").
- **Emotional**: how they want to feel ("sure I made no mistake").
- **Social**: how they want to be seen ("organised in front of my accountant").

Design the flow against the job, not the feature list. A job statement written from the
team's assumptions, with no interview behind it, is a hypothesis. Label it so.

## Journey maps

1. State the goal at journey level.
2. Split into phases (for example: discover, decide, start, use, get help).
3. For each phase: actions, thoughts, feelings, touchpoints. Mark which come from research
   and which are assumed.
4. Mark **moments of truth** (where the relationship is won or lost), **pain points** and
   **opportunity gaps**.

A journey map with no research behind it is a team's shared belief. That has value, but
it is not evidence. Say which it is on the map.

## Interaction specification

Every interaction spec covers:

- **Happy path**: the expected flow.
- **Error path**: invalid input, failed request, timeout, permission denied.
- **Empty state**: no data yet. The first empty state is an invitation to the first action.
- **Loading state**: what the user sees while waiting, and after how long it changes.
- **Partial state**: some data loaded, some failed.
- **Edge cases**: very long names, zero, one and many items, slow network, back button,
  double submit, session expiry mid-flow.

Touch and input:

- Touch targets at least 44 by 44 pt (iOS) or 48 by 48 dp (Android). No overlap.
- Never put essential information or actions behind hover on a touch device.
- Every flow completes by keyboard alone. Focus moves into a dialog when it opens and
  back to the trigger when it closes.

Errors:

- Prevent first: constrain input (pickers, selects), validate on blur, name the object in
  a destructive confirmation ("Delete 'March invoice'", not "Delete item").
- Prefer undo to a confirmation dialog for reversible actions.
- An error message says what went wrong, how to fix it, and who to contact if the user
  cannot. "Password must be at least 8 characters" beats "Invalid input".
- A form never clears the user's input on a validation error.

Read `references/review-checklists.md` when running a heuristic review, checking
cognitive load, designing onboarding, or classifying features with the Kano model.

## Gotchas

- **Asking users what they want.** They answer with features they have seen elsewhere.
  Ask what they did and what got in the way; derive the feature yourself.
- **Testing with colleagues.** They know the product's words and model. Their success
  proves nothing about a stranger.
- **Recruiting only happy customers.** People who churned or never activated hold the
  most useful answers. Recruit them on purpose.
- **Counting a finding from n=5 as a rate.** "60% failed" from 3 of 5 implies a precision
  you do not have. Say "3 of 5".
- **A heuristic review presented as user research.** An expert review finds likely
  problems quickly. It is a prediction about users, not an observation of them. Label it.
- **One loud quote driving a roadmap.** Check how many sessions support it before it
  goes into a deck.
- **Designing the happy path only.** The empty, loading and error states are where new
  users spend their first minutes. Spec them first if anything.
- **A flow that works in the spec but not in the build.** Walk the real build with the
  same tasks before calling the research done.

## Verification

Research work is done when:

- [ ] The research question and the decision it informs are written down.
- [ ] Every finding names its participant count and source sessions.
- [ ] Observation, interpretation and recommendation are kept apart.
- [ ] Assumed content (on journey maps, job statements) is labelled as assumed.
- [ ] Limits and open questions are listed.
- [ ] Each interaction spec covers happy, error, empty, loading, partial and edge states.
- [ ] Recommendations are ranked by severity and by how many users they affect.
