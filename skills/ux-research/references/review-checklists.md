# Review checklists

Read the section you need. Each one is a prediction aid, not a substitute for watching users.

- Heuristic review
- Cognitive load
- Onboarding
- Kano feature classification
- Usability anti-patterns

## Heuristic review

Walk each key task with these ten questions (after Nielsen). Record each problem with the
screen, the heuristic, a severity (blocker, major, minor, cosmetic) and a fix.

1. **Status is visible.** Does the user always know what is happening and whether the
   last action worked?
2. **The product speaks the user's language.** Words, order and concepts from the user's
   world, not the database's.
3. **Control and freedom.** Is there a clear way out: undo, back, cancel?
4. **Consistency.** Does the same word or icon mean the same action everywhere? Does it
   follow platform conventions?
5. **Error prevention.** Are likely slips designed out (constraints, defaults, confirmation
   of destructive acts)?
6. **Recognition over recall.** Are options visible, or must the user remember them from
   an earlier screen?
7. **Flexibility.** Can experienced users go faster (shortcuts, bulk actions) without
   confusing new ones?
8. **Minimal design.** Does every element on the screen earn its place?
9. **Error recovery.** Do error messages say what happened and how to fix it, in plain words?
10. **Help.** Is task-oriented help findable when it is needed?

Use three reviewers if you can. Each finds a different subset; one reviewer misses a lot.

## Cognitive load

- Working memory is small (about four chunks for most tasks). Limit how many things a
  user must hold in mind across steps.
- Chunk: twelve flat menu items read worse than four groups of three.
- Progressive disclosure: essential actions by default, secondary actions on demand,
  expert controls available but quiet.

| Overload | Fix |
|---|---|
| A form with 15 or more fields | Split into steps; show only fields that apply |
| A dashboard with 20 equal metrics | Rank them; make two or three primary |
| A confirmation dialog that adds no information | Inline confirmation naming the action ("Delete 3 items") or undo |
| An error that must be parsed before acting | Lead with the action ("Try again"), explain after |

## Onboarding

1. The first session delivers something of value. The user leaves having done one real thing.
2. Reveal complexity as the user needs it.
3. The first empty state points at the first action.
4. A tutorial is offered and can be skipped. Never forced.
5. Show what the product does before asking for sign-up. Registration before value
   raises the drop-off rate.

## Kano feature classification

Ask two questions per feature, in a survey with enough respondents to count:

- "How would you feel if the product had this?"
- "How would you feel if it did not?"

Answer scale: I like it, I expect it, I am neutral, I can tolerate it, I dislike it.

| Category | Absent | Present | What to do |
|---|---|---|---|
| Must-be | Very dissatisfied | Taken for granted | Ship it; it will not win anyone |
| Performance | Dissatisfied in proportion | Satisfied in proportion | Invest in proportion to return |
| Attractive | Neutral | Delighted | Differentiates; hard to copy |
| Indifferent | Neutral | Neutral | Do not build |
| Reverse | Some prefer it absent | Some dislike it | Research the split before building |

Categories drift: today's delighter is next year's must-be. Re-run the survey before a
major planning cycle.

## Usability anti-patterns

| Pattern | Why it fails |
|---|---|
| Manipulative call to action (shame copy, hidden opt-out) | Wins one click, loses trust and retention |
| Registration before any value | Users leave before they see why to stay |
| "Something went wrong" | The user cannot recover alone |
| Many equal options on one screen | Decision takes longer and errors rise |
| Modal on first visit | Interrupts before the user has context |
| Infinite scroll with no position restore | The user loses their place after Back |
| Form that clears on error | Punishes the user for a validation slip |
