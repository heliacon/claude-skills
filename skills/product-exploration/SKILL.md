---
name: product-exploration
description: Use when a new product, major capability or new market is proposed and nothing is built yet, or on /craft:product-exploration with the idea as argument. Phrases like "new idea", "should we build", "is this worth doing", "validate this idea". Ends in PURSUE, PARK or KILL. Not for features of an existing product; use `product-management`.
license: MIT
---

# Product exploration

Idea under exploration: $ARGUMENTS

(If that line is blank or literal, take the idea from the conversation. If there is none, ask for it in one sentence and stop.)

This process ends in a decision, not a pile of documents: **PURSUE, PARK or KILL**, with the evidence for it. In venture mode, no build starts on an idea without a recorded PURSUE.

## The rules that matter most

1. **Write the kill condition before any research.** Once research starts, every finding gets read as support. A kill condition written first is the only defence.
2. **Interest is not demand.** Sign-ups, likes and "I'd use that" cost the speaker nothing. Count behaviour: money paid, workarounds built, time spent, anger when something breaks.
3. **The status quo is the real competitor.** People already solve the problem somehow (a spreadsheet, a manual step, a person, nothing). If the honest answer is "nothing", the pain is probably too small to act on.
4. **Every claim carries a source. Every number is checked in its original context.** A statistic from an adjacent market, year or population is not evidence for this one. A hypothesis is labelled as a hypothesis.
5. **A clean KILL is a success.** For example, finding before the build that the headline market claim is false is the process working. Do not soften a verdict to be kind.
6. **The decision owner makes the PURSUE call.** This process prepares it. It does not grant it.

Write everything into `EXPLORE-<idea-slug>-<YYYY-MM-DD>.md` in the project or ideas directory as you go. Each stage appends to it. If the project defines its own exploration process (in its CLAUDE.md or a project skill), that process wins where it conflicts with this one.

## When not to use

- A hobby or learning build where the person just wants to make the thing. Building is the point; do not gate it. Offer the forcing questions only if asked.
- A feature inside a product that already has users. Use the `product-management` skill (discovery, opportunity tree, review checklist).
- Writing stories for something already decided. Use the `requirements` skill.

## Posture during exploration

- Take a position on every answer and say what evidence would change it. "That could work" is not a position.
- Push past the first answer. The first answer is the rehearsed one. Ask again for a name, a number or an example.
- Name failure patterns out loud when you see them: a solution looking for a problem, hypothetical users, a platform that must be finished before anyone gets value, a growth statistic offered as a strategy.
- Praise only specifics, and follow praise with the next hard question.
- If the person asks to skip the questions, ask the two that matter most for their stage, then move on. Do not ask a third time.

## Stage 1: Intake (before any research)

Write the one-pager at the top of the EXPLORE file:

- The idea in two sentences.
- Who it is for: a specific person with a role and a consequence, not a segment.
- The problem, in the user's words, not the pitch.
- Why now: what changed that makes this possible or needed today.
- **Kill condition**: what finding would make this a bad idea.
- Mode: **venture** (needs paying users or a business case) or **builder** (internal tool, open source, side project). Builder mode may skip Stage 5 and the unit economics lane.

### Forcing questions

Ask one at a time and wait. Skip any that earlier answers already settled. Pick by stage:

| Stage of the idea | Ask |
|---|---|
| No product yet | demand, status quo, specific person |
| Has users | status quo, smallest paid version, observation |
| Has paying customers | smallest paid version, observation, future fit |
| Pure infrastructure | status quo, smallest paid version |

- **Demand**: what is the strongest evidence that someone would be upset if this vanished tomorrow?
- **Status quo**: what do they do today, even badly, and what does that cost them in hours or money?
- **Specific person**: name the person who needs this most. What do they risk if it stays unsolved?
- **Smallest paid version**: what is the least someone would pay for this week, not after the platform exists?
- **Observation**: have you watched someone use it (or the workaround) without helping? What surprised you?
- **Future fit**: if their world changes a lot in three years, does this become more necessary or less?

For an internal project, "pay" becomes "the sponsor funds it", and future fit becomes "does it survive the champion leaving".

### Premise check

Before research, list the premises the idea rests on (3 to 6 lines, each one sentence). Mark each as **verified**, **believed** or **unknown**. Then write at least two alternatives to building it, one of which is "do nothing and use the existing workaround". Research must be able to compare against these.

## Stage 2: Research fan-out

Run parallel research agents, one lane each. Give each the one-pager, the premise list and the rule that every claim needs a source URL or a named document. Each returns findings, not page dumps.

- **Market and competitors**: who does this now, how well, at what price. Name real products. Include the graveyard: who tried and died, and why.
- **Substitutes**: what people use instead, including spreadsheets, agencies and doing nothing.
- **Users and jobs**: functional, emotional and social jobs (see the `ux-research` skill). Real complaints in forums, reviews and issue trackers beat speculation.
- **Feasibility**: what the build needs, what exists to reuse, honest cost and hardware limits.
- **Moat and data**: what compounds with use. If nothing does, write "nothing".
- **Unit economics** (venture mode, or when money is central): see the `financial-modelling` skill.

Synthesis and judgement stay with you, not the lane agents. Check the numbers each lane returns before they enter the file: open the source and confirm the figure, its unit, its date and its population.

## Stage 3: Personas and journeys

From the research, never from imagination (see the `ux-research` skill):

- Two or three personas grounded in the user evidence, each with the job they hire a product for.
- The current journey without the product, with pain points marked.
- The proposed journey, with the moments where the product wins or loses the user.

## Stage 4: Assumption map and riskiest assumption test

- List assumptions under each risk: **desirability, viability, feasibility, usability**, plus **go-to-market** (can we reach them at a sane cost), **legal and ethical** (may we, should we) and **team** (can these people build and run it). Give each the cheapest honest test.
- Plot importance (would it kill the idea if false?) against evidence (how sure are we?). High importance with low evidence is the riskiest assumption.
- Design the riskiest assumption test before running it. Write down: what to run, the result that **kills** the idea, the result that **funds the next step** and the deadline. Set the bars before seeing data.
- Where a test can run now (a landing page, a concierge trial, a data pull, a throwaway prototype), run it inside this process.
- Every probe has a **disposal plan**: a prototype built to learn is deleted or archived when the test ends. It does not quietly become the product.

## Stage 5: Positioning and honesty about the market

See the `marketing` skill for the method. Write:

- Positioning: competitive alternatives, unique attributes, the value they enable, who cares most, the market frame where those strengths win.
- **The honest paragraph**: what is truly different, what is table stakes dressed up as a feature and what the incumbent does better.
- A naming and trademark sanity check if the idea will need a mark.

## Stage 6: The honest PRD

Write the PRD with the eight parts from the `product-management` skill (problem, who, why now, success metrics, scope, non-goals, risks and assumptions, open questions). Cite the research inline. Add a **Not doing (and why)** list. Draft first user stories with acceptance criteria (see the `requirements` skill) only for the PURSUE case.

## Stage 7: Verdict

Run the Product Review Checklist from the `product-management` skill. Then write one verdict:

- **PURSUE**: the checklist passes and the riskiest assumption survived its test. The idea may enter the roadmap's Now or Next column with its PRD. The build then follows normal phases with milestone gates (see the `milestone-gate` skill).
- **PARK**: promising but blocked on evidence or timing. Write what would unpark it and a revisit date.
- **KILL**: the kill condition fired, or the checklist failed on fundamentals. One paragraph of reasons.

Use the verdict block in `references/explore-file.md`. A PURSUE recommendation is still a recommendation until the decision owner records it.

## Gotchas

- **Searching for support.** Lanes briefed with "find evidence this works" return support. Brief them to find the strongest case against, too.
- **Numbers from the wrong frame.** A market size for the whole category quoted as the market for a niche. A survey of enthusiasts quoted as the general public. Check population, date and unit every time.
- **A thin search is not absence.** "No competitors found" usually means the search was narrow. Search by what the product does, not by what you would call it.
- **Waitlists as demand.** A waitlist is interest. A deposit, a pilot contract or a user who built a workaround is demand.
- **The tested assumption was the easy one.** Teams test what is cheap to test. Check that the test targets the top-right cell of the map.
- **The prototype that never died.** A learning prototype that becomes the codebase carries every shortcut taken to learn fast.
- **A verdict softened in the summary.** If the evidence says KILL, the first line says KILL.

## Record

- The verdict and evidence live in the EXPLORE file.
- Add one line to the ideas ledger (a single file listing every explored idea, its date and verdict) so a killed idea is not re-explored cold.
- If the process itself taught something, add it to `tasks/lessons.md` (see the `workflow` skill).

## Verification

The exploration is done when the EXPLORE file holds: the one-pager with a kill condition dated before the research, sourced findings per lane, the assumption map, the riskiest assumption test with its pre-set bars and result, the PRD, the checklist with each item marked and the verdict block. Anything missing means the verdict is not yet earned.
