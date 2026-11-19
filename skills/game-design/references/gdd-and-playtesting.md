# Game design document and playtesting

## Writing a GDD

Write it section by section, not in one pass. Each section lists the sections it depends on, and a
change to one triggers a review of its dependants. Keep it a living document; a GDD nobody updates
is worse than none.

Suggested sections, in dependency order:

1. **Pillars and target experience.** Three to five pillars; target feelings; target audience and
   their main motivations.
2. **Core loop.** What the player does every 30 seconds, every 5 minutes, every session. Win and
   fail conditions. Depends on 1.
3. **Mechanics.** Each mechanic: rules, inputs, feedback, which pillar it serves. Depends on 1 and 2.
4. **Progression and difficulty.** Curve, progression types, gates. Depends on 2 and 3.
5. **Economy.** Resources, sources, sinks, rates. Depends on 3 and 4.
6. **Content plan.** Levels, modes, enemies or cards for the first release, with counts. Depends
   on 2 to 5.
7. **Onboarding.** Order mechanics are introduced and where. Depends on 3 and 6.
8. **UI and HUD.** What is shown, where, when. Depends on 3 and 5.
9. **Technical constraints.** Platforms, input methods, frame rate target, save system (local, cloud
   or both), localisation. Decide the save system early; it is the hardest thing to retrofit.
10. **Open questions and risks.**

For each mechanic, write the smallest test that would show it is fun, and run it before the section
is marked done.

## Planning a playtest

- **Goal**: one or two questions this test answers ("do players find the dash?").
- **Players**: people who match the audience and have not seen the game. Friends and the team
  count only for bug hunting.
- **Script**: what you will say before (as little as possible) and the task you set.
- **Observe in silence.** Do not help. Note where they get stuck, what they try first, what they
  misread, where they smile or sigh.
- **After**: short open questions ("what was the hardest part?", "what would you tell a friend this
  game is?"). Ask what happened, not whether they liked it.
- **Instrument**: log deaths, retries, time per section and quit points. Behaviour data and
  observation disagree more often than you expect; both are evidence.

## Reading the results

- Count, do not anecdote. "4 of 6 players missed the dash prompt" is a finding; one loud complaint
  is not.
- Separate what players **did** from what they **said**. Weight behaviour higher.
- Players are good at locating a problem and poor at prescribing the fix. Take the location, design
  the fix yourself.
- Rerun the same test after a change, with new players, to confirm the fix worked.
