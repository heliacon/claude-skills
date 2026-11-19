---
name: product-management
description: "Use when deciding what to build and why for an existing product: discovery, prioritisation, roadmaps, North Star and metrics, MVP or MLP scope, pricing tiers and packaging, PRDs, pre-mortems, saying no. Not for a brand-new idea (use `product-exploration`), story writing (use `requirements`) or schedules (use `project-management`)."
license: MIT
---

# Product management

The one job: the most outcome per unit of output. Requirements detail lives in the `requirements` skill; schedule, risk and delivery live in the `project-management` skill. Do not repeat them here.

## Rules that matter most

1. **No traced problem, no priority.** If you cannot name the user and the need a feature serves, it is not ready to rank. Most bad roadmaps are lists of solutions.
2. **Roadmap outcomes, not dated features.** Now / Next / Later, each item naming the outcome it targets ("cut time to first value"), not the output ("onboarding wizard"). Outputs are hypotheses about outcomes.
3. **Test the riskiest assumption first, not the cheapest.** Teams validate what is easy. Map assumptions by importance against evidence and test the high-importance, low-evidence cell.
4. **Measure the outcome, not the proxy.** Never make the user's experience worse to move a number: no added friction, dark patterns or forced steps to lift a metric. A gamed proxy always corrects later, and the users remember.
5. **Gate on your marginal cost and realised value, never on artificial friction.** See Packaging.
6. **Every experiment and launch names its guardrails**: the metrics that must not get worse while you chase the target.

## When not to use

- A new product or market with no build yet: the `product-exploration` skill runs the full PURSUE / PARK / KILL process.
- Writing user stories, acceptance criteria or NFRs: the `requirements` skill.
- Estimates, critical path, RAID, status reports: the `project-management` skill.

## Discovery

- Discovery is a weekly habit, not a phase. Small decisions with steady user contact beat one big research sprint. Product, design and engineering discover together so build-time surprises shrink.
- Structure it as an **opportunity solution tree**: desired outcome (a metric) → opportunities (needs and pains, from interviews) → solutions → experiments. A solution never exists without a parent opportunity. Compare solutions within one opportunity, not across the whole backlog.
- **Opportunity score** to pick which need to serve: importance + max(importance − satisfaction, 0) (Ulwick), from a survey of real users. `references/frameworks.md` has the scale and cut-offs. High importance with low satisfaction is the gap worth serving.
- Four core risks per idea: **desirability** (do they want it), **viability** (does it work for the business), **feasibility** (can we build it; hand to the `architect` agent for a spike) and **usability** (can they work it; hand to the `ux` agent).

## Prioritisation

No framework decides for you. A framework makes the trade-off explicit and arguable. Default to:

- **MoSCoW** to scope one release, with an enforced Won't list.
- **RICE** to rank within a tier when you have rough data. Never let a score override a strategic must or a hard won't.
- **Cost of Delay / WSJF** when time itself has value (deadlines, market windows).

Read `references/frameworks.md` for the formulas, Kano categories and the watch-outs for each.

How to decide and say no:

- Decide against the outcome, not the loudest request. Which opportunity does this serve, and by how much?
- Reserve explicit roadmap capacity for important but not urgent work. Urgent-versus-important triage quietly optimises for urgent; the strategic bet is never urgent until it is too late.
- Say no with a reason tied to strategy ("not this quarter, it does not serve the activation outcome"), then hand the problem back: "here is where the need sits and what would move it up".
- A short list you will do beats a long backlog you will not. A backlog is a store of deferred decisions.

### Scope mode

Before reviewing a plan, decide which mode you are in and say it, so the review does not drift:

- **Expand**: the plan is too timid for the opportunity. Look for the bigger version.
- **Hold**: the scope is right. Make it rigorous; add nothing.
- **Reduce**: the plan is too big for the evidence. Cut to the smallest thing that tests the riskiest assumption.

### Scope creep signals

Scope is creeping when: "while we are in there" appears in a ticket; a story gains acceptance criteria after estimation; the non-goals list shrinks; the launch date holds while scope grows. Route each through change control (see the `project-management` skill).

## Metrics

- One **North Star**: the measure of value delivered to users that the business compounds on. A leading indicator of revenue, not revenue itself.
- Below it, 3 to 5 **input metrics** the team can move this week, and below those, the team-level levers. Write the tree out: every team metric should trace up to the North Star. A metric that traces to nothing is decoration.
- **Leading** metrics steer (activation rate). **Lagging** metrics confirm (churn, revenue). Steer by leading, report by lagging.
- **Vanity test**: if it only goes up and no decision hangs on it (total sign-ups, cumulative anything, page views), it is vanity. Actionable metrics are rates, are segmentable and change a decision.
- Fix activation and retention before spending on acquisition. A leaky bucket wastes spend.

Read `references/frameworks.md` for HEART and AARRR when designing a metric set from scratch.

## MVP, RAT and MLP

- **MVP**: the smallest thing that produces validated learning about a risky assumption. An experiment, not a small product.
- **Riskiest assumption test**: often better than an MVP. Test only the assumption that would kill the idea (fake door, concierge, Wizard of Oz, landing page). Set the pass and fail bars before you see data.
- **MLP (minimum lovable product)**: once desirability is proven, the first real release does one job delightfully rather than ten jobs poorly. Depth over breadth.
- Design the loop backwards: what must we learn, so what do we measure, so what is the least we build.

## Positioning and strategy

- **Working backwards**: write the press release and FAQ as if it shipped. If you cannot write a convincing one, the idea is not ready. The hard FAQ questions are the point.
- **Positioning** (April Dunford): competitive alternatives → unique attributes → value → who cares most → market frame. Weak positioning defaults to the obvious category and fights on features. See the `marketing` skill for depth.
- **Beachhead**: win one narrow segment completely before expanding. Early adopters buy vision; the mainstream buys references and complete solutions.

## Packaging and tiers

Packaging is a product decision, not a sales afterthought.

- **Value metric**: charge along a unit that grows as the customer succeeds (seats, usage, outcomes) and that they can predict and control.
- **Gate features** to separate use cases and personas. **Gate volume** to let one use case scale with willingness to pay. Most products need both.
- **Free tier** delivers a real, complete slice of value and a natural reason to upgrade. Budget it as an acquisition cost.
- **A common default for marginal cost**: put features with per-call paid spend (a hosted model call, a paid API) behind a paid tier or at least sign-up, and keep features with negligible marginal cost free. It caps abuse and keeps the free tier's cost predictable; adapt it to your margins and model.
- Anti-patterns: crippleware that degrades the experience to force an upgrade; a basic users expect for free put behind a wall; a value metric that produces surprise bills; tiers too complex to self-select.

## PRD structure

A PRD is a decision record, not a spec dump. Eight parts:

1. **Problem**: the need, with evidence. What is broken today and for whom.
2. **Who**: a specific user or segment.
3. **Why now**: the trigger. No "why now" means defer.
4. **Success metrics**: North Star impact, target input metrics, guardrails.
5. **Scope**: the outcome and the stories in it (link the requirements doc, do not copy it).
6. **Non-goals**: the highest-leverage section against scope creep.
7. **Risks and assumptions**: the four risks and how each is tested.
8. **Open questions**: each with an owner and a decide-by date.

## Pre-mortem

Before committing to a launch or a big bet, imagine it has failed six months out and list why. Sort each reason:

- **Tigers**: real threats you can see. Classify each as launch-blocking, fix soon after launch or track.
- **Paper tigers**: worries that sound serious but you can argue away. Write the argument down so it stops recurring.
- **Elephants**: things nobody is saying out loud. Name them; these are the ones that sink projects.

Every launch-blocking tiger gets an owner, an action and a date before the launch is approved.

## Alignment and disagree-and-commit

- Align on the outcome and the problem first. Agreement on solutions follows more easily.
- Write the trade-offs down. Say what each option costs.
- Disagree and commit has two halves: real dissent aired before the call, full commitment after. Skip the first and you breed resentment; skip the second and you relitigate. Record who decided, what, and the dissent heard.
- Escalate on data and outcome impact, never on volume or seniority.

## Product Review Checklist

Before an item enters the roadmap Now column (the `product-exploration` skill runs this as its verdict gate):

- [ ] Named user and validated problem, traced to an opportunity, not just a request
- [ ] The riskiest assumption is identified and tested cheaply first (or scheduled to be)
- [ ] Target outcome and metric named, not just an output
- [ ] Guardrail metrics named
- [ ] Prioritisation is explicit (which framework, which inputs) and survives challenge
- [ ] Non-goals written down
- [ ] Packaging decided if it touches tiers
- [ ] Hand-offs identified (requirements, architecture, UX, design)
- [ ] "Why now" holds up

## Gotchas

- **Output as success.** Counting features shipped. Attach a metric or do not build it, and revisit shipped items to see whether the outcome moved. Kill the ones that did not.
- **Loudest voice wins.** The highest-paid opinion and the noisiest customer crowd out the important bet.
- **Roadmap as dated promise.** It licenses a feature factory and guarantees missed dates.
- **Solution-first backlog.** Items with no user and no need. Send them back.
- **Kano drift.** Delighters decay into expectations. Re-check what users now treat as basic.
- **A RICE score treated as truth.** It is only as good as its inputs. Write the inputs down so they can be challenged.
- **Free and paid split on pain.** Gate on cost and value, never on friction.

## Verification

A product decision is ready when someone else can read the PRD and the checklist and reach the same call. Check: every Now item has an outcome metric and guardrails; every item traces to an opportunity; non-goals exist; the pre-mortem's launch-blocking tigers all have owners.
