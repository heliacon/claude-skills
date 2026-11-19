---
name: data-analysis
description: Use when analysing data to answer a question, explaining why a metric moved, designing metrics or KPIs, reading an A/B test, building cohorts or funnels or checking a number before it is shared. Not for chart styling (use the `frontend` skill's `references/charts.md`) or forecasting money (use `financial-modelling`).
license: MIT
---

# Data Analysis

Start from the decision, not the data. An insight is not a number. It is a "so what" that changes
what someone does, with a confidence level attached.

## The rules that matter most

1. **Decision first.** Write down the decision the analysis informs and who owns it. No decision,
   no analysis.
2. **Check the collection before explaining the line.** A double-firing tag, a broken event, a
   timezone change or a bot surge all look like insight. Confirm the number is real first.
3. **Segment before you conclude.** An aggregate can show the opposite of every segment inside it.
4. **Derive every headline number twice**, by a second route (a different query, a hand count on a
   sample, a reconciliation to another system). Measurement bugs do not throw errors. A green test
   suite will not find them; recomputing will.
5. **An impossible or surprising number indicts the measurement first.** A ratio above 100%, a
   rate that jumps tenfold overnight, a count that matches a round page size: check the instrument
   before you write the story.
6. **State a confidence level on every finding** and never let the wording claim more than it.

## When not to use

- Choosing chart types and colours: the `frontend` skill's `references/charts.md`.
- Forecasts, valuations and runway: the `financial-modelling` skill.
- Writing the tests or harness that collect the data: the `testing-strategy` skill.
- Product metrics strategy (which North Star, which bets): the `product-management` skill, with
  this skill for the measurement.

## 1. The loop

```
Decision > Question > Hypothesis > Data > Analysis > Insight > Action > measure again
```

- **Question.** Turn the decision into one answerable question. "Should we invest in the blog?"
  becomes "does organic blog traffic convert to qualified sign-ups at a better rate than paid?"
- **Hypothesis.** Write what you expect and why before you look. It stops you fishing for a story.
- **Data.** What exists, its coverage, its quality and its gaps.
- **Analysis.** Start simple. A good segment cut beats a model. Add complexity only where it changes
  the conclusion.
- **Insight and action.** The implication, the recommended action and the metric that will show
  whether the action worked.

Pull the actual number before writing a paragraph of speculation about it. Five minutes of querying
beats an hour of theory.

## 2. Metric design

- A **metric** is any measurement. A **KPI** is one of the few you steer by. Twenty metrics on a
  page is not a dashboard.
- **North Star and inputs.** One metric that captures delivered value; a handful of input levers
  that drive it. You act on inputs and watch the North Star. Decompose it as a product of inputs
  where you can.
- **Leading and lagging.** Steer on leading metrics (they move first), confirm with lagging ones.
- **Guardrails.** Name the metrics that must not degrade (revenue, error rate, load time) before
  you start optimising.
- **Rates over counts, with the denominator pinned.** A count rises with traffic and says nothing
  about quality.
- **Vanity test.** "If this doubled, what would I do differently?" No answer means vanity.

Pin every metric before it is used anywhere:

```
Name:        activation rate
Formula:     users completing first key action / new users, same cohort
Numerator:   distinct user_id with event = 'first_report_run' within 7 days of signup
Denominator: distinct user_id with event = 'signup'
Window:      signup cohort; measured 7 days after signup (cohorts younger than 7 days excluded)
Filters:     exclude internal accounts and known bots
Owner, source system, date agreed
```

## 3. Core techniques

- **Segmentation.** Channel, device, region, new or returning, landing template. The mean is where
  the story hides.
- **Cohorts.** Group by a shared start event and track forward. Separates "getting better" from
  "getting bigger". Essential for retention.
- **Funnels.** Define each step exactly. Fix the biggest leak first, not the last step. Recompute
  downstream rates after a change high up, because it changes the mix of everyone below.
- **Time series.** Plot over time before anything else. Compare like with like (week on week, same
  period last year). Know the normal noise band before calling a move a trend.
- **Before and after.** Weak alone, since anything else could have moved. Add a comparison group
  that did not get the change.

Funnel example: of 38,000 people who landed, 12,000 engaged (31.6%) and 1,080 of those converted
(9.0%). The instinct is to tune the 9%. The money is in the two thirds who landed and never engaged.

## 4. Root cause

- **Line up the timeline.** What shipped, what changed in config, tracking, algorithm or campaigns,
  and exactly when did the line move? A move with nothing on the timeline is often a collection or
  definition change.
- **Issue tree.** Split the move into mutually exclusive, collectively exhaustive branches.
  "Sign-ups fell" splits into fewer visits or lower conversion, and each splits again.
- **Five whys** down the branch you find, stopping at the level you can fix.
- **Account for the whole move.** If checkout errors explain 2 points of an 8-point fall, you have
  found a cause, not the cause. Keep going.
- **Weight suspects by size, not count.** Ten small contributors can matter less than one large one.
  Rank candidates by how much of the move each explains.

## 5. Statistics and experiments

Read `references/statistics.md` before making any significance claim, reading or sizing an A/B test,
or comparing groups that chose themselves. It covers sample size, effect size versus significance,
intervals, confounders, Simpson's paradox with a worked example, regression to the mean, multiple
comparisons, power and experiment design.

The short version: report effect size with an interval, not a bare p-value; randomise if you want a
causal claim; size the test before it starts and run it to the planned end.

## 6. Data quality and trust

- **Count the nulls.** Ask what a zero means: a real zero or missing data.
- **One written definition per metric**, reused everywhere. Definition drift is the most common
  reason two people quote different numbers and neither is wrong.
- **Reconcile two sources before trusting either.** Expect analytics and the database to disagree;
  understand why before a figure leaves the room.
- **An API response is a view.** It has page sizes, limits, sampling and retention windows. A count
  that equals 100, 1,000 or 10,000 is probably a limit, not a fact.

Read `references/pitfalls.md` before delivering any analysis that joins tables, compares periods,
compares a treated group with a control or ranks items. It lists the named traps with their checks.

## 7. Communicating the result

- **Answer first.** Conclusion and recommendation in the first sentence, then the support. Do not
  narrate the journey through the data.
- **So what, now what.** Each finding states the implication and the action.
- **One chart, one message**, stated in its title. Give the numbers in a table and the finding in a
  sentence too, so nobody depends on the chart alone.
- **One unit per statement.** "1,200 reports. 4,000 customers received one" reads as 4,000 out of
  1,200.
  Keep each sentence to one population and name it.

| Confidence | When | Wording |
|---|---|---|
| High | Clean data, adequate sample, cause randomised or isolated | "X caused Y" |
| Medium | Reasonable data, plausible cause, some confounders open | "X is associated with Y; likely driver" |
| Low | Thin sample, known gaps, cause not isolated | "Early signal, needs confirming" |

The confidence level is part of the finding, not a footnote.

## 8. Attributing a change

- **Tie a score move to an event and an outcome.** When a composite score moves, find the change
  underneath (a release, a content or config change, an outside event) and then its effect on a
  business outcome. The score is a proxy.
- **Background confounders.** Traffic rides on seasonality, outside events (such as a search engine
  update) and brand demand. Separate your change from the background before taking credit. A recovery
  after a dip may be reversion, not your work.
- **State the attribution model.** Last click flatters the closing channel. Prefer cohort and
  journey views to single-touch credit.

## Gotchas

| Mistake | Correction |
|---|---|
| Trawling the data for a story | Write the decision and hypothesis first |
| Quoting a median for a skewed outcome | Report mean and median; a median can hide a huge tail. Say which and why |
| Comparing a full month with a partial one | Compare complete periods, or the same number of days |
| Outcome not finished for recent rows | Exclude cohorts whose outcome window has not closed (no look-ahead, no censoring) |
| Join multiplied the rows | Check row counts before and after every join; aggregate before joining one-to-many |
| A diff between two runs read as signal | Run the "before" side twice first; if it differs from itself, the noise is the finding |
| Quoting a raw share when chance would give most of it | Compute the null (what random assignment gives) and quote the excess over it |
| Control measured differently from treatment | Both arms must share one instrument, or the comparison controls for nothing |
| Similar totals read as "no difference" | Check per segment; equal aggregates can hide large opposite effects |
| "X crowded out Y" | A claim that one thing displaced another needs a limit that was actually reached. Check it was |
| Ranking by an extreme value | Look at the top items by hand; artefacts and errors sort to the extremes |
| "None found" from your own keyword list | It means none of what you thought of. Search by shape too |

## Verification

Before delivery, run this QA pass and give one verdict: **ready**, **share with caveats** or
**needs revision**.

- [ ] The decision and owner are written down; the question predates the data pull
- [ ] Every metric has a pinned formula, denominator and window
- [ ] Headline numbers derived twice by different routes, and they agree
- [ ] Collection checked: nulls counted, sources reconciled, no limit-shaped counts
- [ ] Join row counts checked; periods complete and comparable
- [ ] Aggregates checked against segments
- [ ] Effect sizes with intervals; causal claims backed by an experiment or labelled provisional
- [ ] Each finding has so what, now what and a confidence level
- [ ] Every chart has a sentence and a table equivalent
- [ ] What fell out of the comparison (excluded rows, unmatched items) is reported
