# Findability testing

Contents

- Choosing a test
- Card sorting
- Tree testing
- First-click testing
- Reporting

## Choosing a test

| Question | Test |
|---|---|
| How do users group and name this content? | Open card sort |
| Does content fit our proposed categories? | Closed card sort |
| Both, cheaply | Hybrid card sort (fixed categories, users may add) |
| Can users find things in this structure? | Tree test |
| Is the first move on this page right? | First-click test |

Order: inventory and audit, then card sort to generate a structure, then tree test to
validate it, then first-click test once wireframes exist.

## Card sorting

Setup:

- 30 to 60 cards. Fewer gives little structure; more tires participants.
- Card text is the content as users know it, not your proposed label. A card that
  contains a category name biases the sort towards that category.
- About 15 participants per user group for an open sort before patterns settle (Nielsen
  Norman Group's recommendation). Unmoderated remote tools make this cheap.

Analysis:

1. **Similarity matrix.** For each pair of cards, the share of participants who put them
   together. As a rough rule of thumb (not a standard), pairs above about 60% belong
   together and pairs below about 20% belong apart.
2. **Dendrogram or cluster view.** Read candidate groups at a few cut levels, not one.
3. **Category names.** Standardise participant group names (merge "Help" and "Support"
   only if the cards inside match), then count the terms. The most common term is a label
   candidate.
4. **Cards with no stable home.** These are the polyhierarchy candidates, or the cards whose
   wording is unclear. Check which before cross-filing.
5. **Segments.** If two user groups sort differently, report both structures. Blending them
   produces a structure that fits neither.

A card sort produces a candidate. It does not validate one.

## Tree testing

Setup:

- The tree is text only: labels and hierarchy, no visual design, no search.
- 8 to 10 tasks per participant. Each task is a realistic goal in the user's words and
  avoids the target label's words ("You want to change where your parcels are delivered",
  not "Find delivery address settings").
- Decide the correct answer node or nodes for each task before the test. More than one can
  be correct if the item is cross-filed.
- Randomise task order. About 50 participants per user group for stable task-level rates (a common
  rule of thumb).

Measures per task:

- **Success**: ended on a correct node.
- **Directness**: reached it without backtracking.
- **Time**.
- **First click**: the top-level choice. A wrong first click predicts failure.

Analysis:

- Set the target before the test. A rough rule of thumb, not a standard, is 70% success or better on
  key tasks.
- For each failing task, read the paths. Where did most wrong paths go? That location is
  either a better home or a label that steals scent.
- High success with low directness means the label is guessable only after a wrong try.
  Treat it as a weak label.
- Change the tree, then retest the failing tasks with new participants. Compare against
  the first round's rates for the same tasks.

## First-click testing

- Show a screen (wireframe or design) and a task. Record where the participant clicks first.
- A correct first click strongly predicts eventual success; a wrong one predicts failure.
- Use it to check that the page's links carry the trigger words, once the tree is validated.

## Reporting

For each task: success, directness, first-click distribution, the main wrong destinations,
and the change made. State participant counts and recruitment. Report rates from small
samples as counts ("7 of 12"), not percentages.
