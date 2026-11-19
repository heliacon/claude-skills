---
name: marketing
description: Use when positioning a product, building a messaging hierarchy, choosing a go-to-market motion, planning a launch or campaign, picking channels or judging CAC, payback or attribution. Not for writing page copy (use `copywriter`), search mechanics (use `seo-aeo-geo`) or a full financial model (use `financial-modelling`).
license: MIT
---

# Marketing

Positioning comes before messaging, and messaging comes before tactics. Work in that order every
time. A tactic built on no positioning drifts, and no amount of spend fixes it.

The rules that matter most:

1. **Read the context doc first.** Every marketing task starts from one shared document about the
   customer (below). If none exists, write it before anything else.
2. **Never invent evidence.** No made-up metric, customer, quote, logo or case study, even as a
   placeholder. A placeholder ships. Mark the gap as `[PROOF NEEDED]` instead.
3. **Proof is load-bearing.** A claim with no proof under it is a liability. For a technical or
   sceptical audience, prefer verifiable proof (a demo, a benchmark, a published audit) to asserting
   the benefit. For consumers, real attributable reviews and testimonials are legitimate proof.
4. **One primary motion, one wedge.** A small team running every motion at once gets none of them
   to work.
5. **Report economics, not reach.** A number that cannot change a decision is vanity.

The defaults in this skill assume a small team with a limited budget. A larger team can run more
motions and channels in parallel; adapt them to your situation.

## When not to use

- Writing or editing the words on a page, email or button: the `copywriter` skill.
- Crawl, index, schema or answer-engine mechanics: the `seo-aeo-geo` skill.
- Pricing and packaging as product decisions (value metric, tiers, gating): the
  `product-management` skill. The money behind them: the `financial-modelling` skill.
- Whether to build the product at all: the `product-exploration` skill.

## The context doc

Keep one file (for example `docs/marketing-context.md`) that every marketing task reads before it
starts and updates when it learns something. It holds the facts that otherwise get re-guessed in
every conversation: who buys, why now, what they use today, what stops them, the words they use and
the proof you hold. Without it each campaign invents a slightly different customer.

Read `references/context-doc.md` when the doc does not exist yet or is missing a section. It has
the template and the interview questions that fill it.

## 1. Positioning

Work the components in this order (April Dunford, *Obviously Awesome*):

1. **Competitive alternatives.** What the customer would do if you did not exist. Usually a
   spreadsheet, a manual process, an agency or nothing, not a named rival.
2. **Unique attributes.** What only you have. Plain list, no adjectives.
3. **Value.** Map each attribute to the benefit it delivers. An attribute with no value is noise.
4. **Target segment.** The customers who care most about that value. Not the easiest to reach.
5. **Market category.** The frame that makes the value obvious and sets the comparison.
6. **Relevant trend** (optional). Why now. Use it lightly or it takes over the message.

Write the result as a short internal statement, not a tagline. Test it with real prospects
("does this describe you? what would you call this?") before deriving any messaging from it.

## 2. ICP and the message hierarchy

An ideal customer profile names four things: the segment, the trigger that starts their search,
the alternative they use today and why your attributes matter to them in particular. Firmographics
alone (size, industry) are not an ICP. Name the **anti-persona** too: who looks like a fit but churns
or costs more than they pay. Saying no to them sharpens every message.

Message against the job the customer hires you for, not the feature list (jobs to be done; the
`ux-research` skill has interview depth). Build the hierarchy top down and never invert it:

- **Value proposition.** One sentence. The single outcome that matters most to the ICP.
- **Pillars.** Three or four reasons to believe the value proposition.
- **Proof.** Under each pillar: a benchmark, a demo, a customer result, real numbers.

Every line of copy at every altitude traces to a pillar. A line that does not trace gets cut.

## 3. Category entry or category design

- **Entry**: adopt a term buyers already search for. Demand already exists to capture. You compete
  inside someone else's comparison set.
- **Design**: name and teach a new category. You set the criteria. You also fund the education of
  the whole market, and nobody searches for a term you invented last week.

Default for a small team: **enter a known category for discovery, then layer your new term on top
as a point of view** once you have attention. Creating a category you cannot afford to teach is the
most expensive mistake in this skill.

## 4. Go-to-market motion and the wedge

| Motion | Fits when | Main channel | Risk |
|---|---|---|---|
| Product-led | Fast time to value, self-serve trial | The product | Needs a real first success in minutes |
| Sales-led | High contract value, few buyers, complex deals | Outbound, demos | Slow, does not compound |
| Community-led | Practitioner audience, credibility matters | Content, repos, forums | Slow start, cannot be faked |

Pick one as primary. Secondary motions support it; they do not get equal effort.

**The wedge** is one narrow use case you win decisively: the job where the alternative is visibly
weak and your attribute is visibly strong. Land it, then expand. "The whole platform" is not a wedge.

## 5. Funnel and demand

Use the funnel (awareness, consideration, decision) to place each asset, and AARRR (acquisition,
activation, retention, referral, revenue) to instrument the whole lifecycle. Activation and
retention usually decide the outcome. Acquisition spend into a leaking activation step buys churn.

- **Capture demand** first: people already searching. Comparison pages, docs, search. Cheaper, and
  capped by existing search volume.
- **Create demand** once capture works: people who do not yet know they have the problem. Point of
  view content, talks, original research. Slower and uncapped.

## 6. Channels and content

Sort every channel into one of three kinds before you commit effort:

- **Owned**: site, email list, docs, repo, community you run. Compounds and you control it.
- **Rented**: social platforms, marketplaces, someone else's feed. Reach that the landlord can
  withdraw. Use it to move people onto owned channels.
- **Borrowed**: other people's audiences. Guest posts, podcasts, partner newsletters, conference
  talks. High trust per touch, needs relationships.

Build on owned, amplify with rented and borrowed. Pick two or three channels and do them well.

A strong content method, especially for technical products: **publish the by-product of real
work.** Do the engineering, the research or the benchmark anyway, then write it up honestly,
including what did not work. It cannot be faked and it
compounds. Go deep on one narrow topic until you are the reference for it. A small audience that
cares, cites and refers beats a large one that scrolls past.

## 7. Launch

A single launch day spikes then goes quiet, and the team concludes the launch failed. What failed
was treating it as one event. Run it as a sequence: before (early access, build in public, seed the
content), the moment, after (follow-up proof, case write-ups, the next feature). One asset can carry
several touches across the sequence.

Read `references/launch-and-campaigns.md` before a launch or a paid campaign. It holds the launch
readiness gate and the campaign brief template.

## 8. Pricing as a marketing input

Pick a first price you can learn from, not the perfect one. A price that is easy to change, tested
on real buyers and watched closely beats months of debate. Charge from the start where you can: free
users tell you what they like, paying users tell you what they value. The value metric and tiers
belong to the `product-management` skill; the margin and payback belong to `financial-modelling`.

## 9. Metrics

| Metric | Definition | Watch for |
|---|---|---|
| CAC | Fully loaded cost to win one paying customer | Leaving out content, tools or founder time understates it |
| LTV | Gross margin per customer over their lifetime | Optimistic retention inflates it |
| LTV:CAC | Ratio; around 3:1 is a common rule of thumb | A rule of thumb, not a target to game |
| Payback | Months to earn back CAC from gross margin | Long payback strains cash at small scale |

**Attribution is directional, not truth.** Last touch over-credits the channels that close (branded
search, direct) and starves the ones that created the demand. Triangulate three sources: the
attribution model, a "how did you hear about us?" field with free text and judgement. Never kill a
channel on last-touch data alone.

## Gotchas

| Mistake | Correction |
|---|---|
| Tactics first, positioning later | Do the positioning statement, then derive the tactic |
| Feature lists | Map each feature to a value and the job it serves |
| Superlatives to an expert audience | Every unsupported claim costs trust. Show a benchmark or audit |
| Placeholder stats or quotes "to fill later" | `[PROOF NEEDED]`; placeholders reach production |
| Segment chosen by ease of reach | Choose by who values the unique attributes most |
| Launching once | Launch as a sequence with follow-up proof |
| Running every motion and channel | One primary motion, two or three channels |
| Reporting impressions and followers | Report activation, retention, revenue, CAC and payback |
| Inventing a category with no budget | Enter the known category, add the new term as a point of view |
| Vague, unattributed testimonials as main proof | Use real, attributable quotes; for a technical buyer, lead with verifiable evidence |
| Customer language paraphrased into jargon | Use their words verbatim from interviews and reviews |

## Verification

Before a page, campaign or launch ships, show evidence for each line, not a tick:

- [ ] Context doc exists and this work cites it (segment, alternative, proof)
- [ ] Positioning statement names the five core components (the trend is optional)
- [ ] Value proposition is one outcome-led sentence; pillars trace to it
- [ ] Every claim has proof attached, or is marked `[PROOF NEEDED]` and held back
- [ ] No invented metric, customer, quote or case study (search the draft for numbers and names,
      and trace each one to a source)
- [ ] One primary motion and the wedge use case are named
- [ ] Each channel is labelled owned, rented or borrowed
- [ ] Success metric and kill criteria are set before launch, tied to the economics
