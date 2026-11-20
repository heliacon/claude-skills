---
name: copywriter
description: Use when writing, rewriting or reviewing words a customer reads, such as landing or marketing pages, headlines, taglines, calls to action, pricing pages, product descriptions, onboarding text, button labels, error messages and empty states. Not for long-form docs or articles; use `docs`. Not for positioning strategy; use `marketing`.
license: MIT
---

# Copywriter

Copy that earns attention and moves one reader to one action. This skill is the craft:
what to lead with, how to structure, what to cut, how to prove a claim. Strategy (who the
product is for, what it is against) comes from the `marketing` skill or the product's
positioning document. Voice comes from the project's style guide if one exists.

## Output contract (read first)

- **Drafts for review (default).** Produce drafts and options for whoever approves the copy.
  Published copy speaks for the product, so do not publish, commit or deploy it as final
  without their sign-off unless they have asked you to.
- **Options on the load-bearing lines.** For the headline, the primary call to action and
  any category label, give 2 or 3 candidates, each with one line on why. The approver
  makes the call.
- **No invented claims.** Every benefit, number and testimonial traces to a source you can
  name (a positioning document, a measured result, a real customer quote with permission).
  If it is not established, it does not go in. Flag the gap instead.

## Diagnose the job first

| Input | Job | Start with |
|---|---|---|
| Blank page | Write | The job sentence (below), then the substance |
| Existing copy to improve | Rewrite | Read it, state what it gets wrong, keep what works |
| Copy to check | Review | The sweeps (below), then the cross-page check; return ranked fixes, not a rewrite |

Do not rewrite when asked to review. Do not review when asked to write.

## The job sentence

Before any copy, write one sentence: **who** reads this, what they must **believe** after
reading, and the **one action** they should take. If you cannot write it, ask.

## Voice

- **The project's documented voice overrides this skill's generic rules.** If its style guide
  deliberately breaks one of the tells below (an in-character claim on a satirical page, a run of
  exclamation marks on a mock price plan, a superlative that is the joke), that is the voice, not
  a defect. Do not report it. Report only where the copy breaks the project's own rules, and quote
  the rule.
- If the project has a voice or style guide, follow it and quote its rules in your check.
- If it has none, read the best existing copy and write down 3 to 5 rules it follows
  (sentence length, person, formality, spelling variant, punctuation habits). Use them, and
  show them to the approver so they can correct them.
- Read the draft aloud. If it does not sound like the product's own people talking, rewrite.

## Principles

1. **Lead with the outcome, not the mechanism.** The reader buys what they get. "Know which
   invoices are late before your client does" beats "automated receivables tracking".
2. **Specific beats clever.** Concrete nouns and real numbers over wordplay. Clever that
   hides the offer is a failure.
3. **One idea per line. Cut a third.** If a line can go without loss, it goes.
4. **Write for the skimmer.** Headline promise, a subhead that qualifies it, proof, then the
   call to action. The headings alone must carry the offer.
5. **Calls to action name what happens.** "Start a free check", "Book a 20-minute demo".
   Never "Submit", "Learn more" or a bare "Get started". The confirmation then uses the
   same verb.
6. **Answer the objection where it arises.** Price, lock-in, privacy, effort, "does it
   actually work": settle each next to the claim that raises it, not in an FAQ.
7. **Proof carries its source.** A number with no base, period or method reads as invented.
8. **Never promise an outcome the product only influences.** Sell what it does. A tool
   that informs a decision does not guarantee the result. Overclaim once and every later
   claim is discounted.
9. **Name what the user controls, not the implementation.** "Notifications", not "webhook
   config". Never show an internal name to a reader.

## Process

1. Job sentence.
2. Gather the substance: the claims, proof, objections and caveats that are true. Copy
   selects and sharpens; it has no licence to invent.
3. Draft the hierarchy (headline, subhead, sections, calls to action).
4. Cut by a third.
5. Options on the load-bearing lines.
6. Run the sweeps.
7. Hand over with the open gaps listed (claims that need proof, facts you could not confirm).

## The sweeps

Read the draft once per question. Each pass catches what the others miss.

1. **Clear?** Could a newcomer say what this is and who it is for after the first screen?
2. **So what?** After each claim, ask "so what?" until the answer is a reader benefit.
3. **Prove it?** Does each claim have evidence next to it, or a reason it needs none?
4. **Specific?** Replace every vague word ("powerful", "fast", "easy") with the fact behind it.
5. **Voice?** Does it match the voice rules, line by line?
6. **Felt?** Does it name the reader's actual frustration in their words?
7. **Safe to act?** What risk stops the reader clicking (cost, commitment, data), and is it
   answered before the button?

## Reviewing a whole site: facts across pages

A sweep of one draft cannot see a contradiction between two pages. When reviewing more than one page,
list every fact that appears on more than one of them and check they agree:

- **Counts and numbers.** The home page says 40 integrations, the pricing page says 35, the docs list
  38. Find the true figure and every place it appears.
- **Names.** The product, plan, feature and company names spelled and capitalised the same way
  everywhere, including page titles, meta descriptions and the footer.
- **One metric, one meaning.** A number reused for different things ("10,000 users" as sign-ups on
  one page, monthly active users on another) is a false claim on at least one page.
- **Promises.** Trial length, refund terms, limits and response times the same on the marketing page,
  the pricing page, the terms and the help pages.

Report each disagreement with every location and which one is right, or that nobody can say yet.

## Tells to cut on sight

unlock, seamless, elevate, empower, supercharge, effortless, revolutionary, game-changing,
cutting-edge, robust, leverage, "in today's world", "the power of", "take it to the next
level", "we are excited to", stacked adjectives, exclamation marks in a row, rhetorical
questions as openers, and dashes used as a rhythm habit. These read as filler, and readers
now recognise them as machine-written. A documented voice that uses one on purpose wins (see
Voice).

## Pricing pages

The job is to help the right buyer choose the right plan without friction.

- Lead each tier with who it is for and the one outcome, then the price, then a call to
  action naming the next step.
- Prices stated plainly. No dressed-up decimals, no hidden meter. If usage is metered, show
  the meter and an example bill.
- Answer leaving: what happens to the customer's data, and whether they can export it.
- Never a bare feature list. Attach each feature to the buyer it matters to.

## Interface copy

Read `references/ui-copy.md` when writing buttons, errors, empty states, confirmations,
notifications or onboarding text, or when copy will be translated.

## Gotchas

- **Writing before the job sentence.** The draft drifts to describing the product instead
  of moving the reader.
- **The feature list as a headline.** Three features joined by commas is not a promise.
- **A number with no base.** "3x faster" than what, measured how? Add the base or drop the
  number.
- **Polishing a claim nobody can support.** Better wording on an unproven claim makes the
  problem worse. Flag it to the approver.
- **One option on the headline.** Gives the approver nothing to choose between and hides your
  reasoning.
- **Rewriting a whole page when asked for a review.** Return ranked findings with fixes.
- **Breaking the flow's vocabulary.** The button says "Publish", the toast says "Posted",
  the list says "Live". Pick one word per action.

## Verification

- [ ] Job sentence written and every section serves it.
- [ ] Every claim traced to a named source, or flagged as unsupported.
- [ ] 2 or 3 options with reasons on each load-bearing line.
- [ ] All seven sweeps run; tells list clean, except where the project's voice rules use one on
      purpose.
- [ ] For a multi-page review: shared facts (counts, names, metrics, promises) agree across pages.
- [ ] Voice rules stated and followed.
- [ ] Draft cut by about a third from the first full version.
- [ ] Handed over as a draft, with open gaps listed.
