---
name: game-design
description: "Use when designing or reviewing how a game plays: core loop, mechanics, game feel and juice, difficulty curve, progression, economy and balance, tutorials, HUD and menus or a game design document (GDD) and playtest plan. Not for engine code or rendering (use `frontend`) or for non-game product UX (use `ux-research`)."
license: MIT
---

# Game Design

Design from the experience you want the player to have, then choose mechanics that produce it.
Working the other way (a mechanic you like, then a reason to have it) gives a game that works and
feels of nothing.

## The rules that matter most

1. **Pillars first.** Write three to five design pillars: short statements of the experience the
   game must deliver ("every fight is a puzzle", "you are always one mistake from disaster"). Every
   mechanic, feature and cut is judged against them. A feature that serves no pillar is cut.
2. **Aesthetics drive mechanics** (the MDA framework: Hunicke, LeBlanc and Zubek). Name the target
   feelings first (challenge, discovery, fantasy, fellowship, expression and so on), then design the
   dynamics that produce them, then the rules (mechanics) that produce those dynamics. The player
   meets the game from the feeling end; the designer builds it from the rules end.
3. **The core loop must be fun alone.** What does the player do every 30 seconds? Prototype that
   with grey boxes until it is good. Content and progression multiply a good loop; they do not
   rescue a bad one.
4. **Watch real players before calling anything obvious.** The designer is the one person who cannot
   playtest the tutorial.
5. **No dark patterns.** Forced spending, fake scarcity and pay to win trade long-term trust for a
   short-term number.

## When not to use

- Engine, rendering, physics or networking code: the `frontend` skill (and the `backend-patterns` skill,
  or the backend agent, for servers).
- Visual style, palette and type for menus: the `visual-design` skill.
- Non-game product flows and research methods: the `ux-research` skill.
- Which agents and phases a game project runs through: the `project-frameworks` skill.

## 1. Motivation

Players stay when the game meets three needs (self-determination theory):

- **Competence**: they feel themselves getting better, and the game shows it.
- **Autonomy**: meaningful choices, more than one way through.
- **Relatedness**: connection to other players or to characters.

Players differ in what they want. Bartle's types (achievers, explorers, socialisers, killers) are a
quick vocabulary; Quantic Foundry's motivation model (action, social, mastery, achievement,
immersion, creativity) is based on survey data and is more useful for targeting. Pick the primary
motivations of your audience and design for them, rather than trying to please everyone.

## 2. Game feel

Game feel is the tactile sense of control. It depends on:

- **Responsiveness**: input to visible response under about 100 ms feels instant; over about 200 ms
  feels sluggish. Measure it on target hardware, not in the editor.
- **Feedback**: every meaningful action gets a clear response in animation and sound.
- **Anticipation**: a wind-up telegraphs a big action and gives the opponent a chance to react.
- **Follow-through**: motion carries slightly past its end point to suggest weight.
- **Squash and stretch**: exaggeration that implies mass and elasticity.
- **Forgiveness**: coyote time (a short jump window after leaving a ledge) and input buffering
  (an early press still counts) make controls feel fair. Players notice their absence, not their
  presence.

Juice pass, after the loop works: impact screen shake (with an option to reduce it), particles on
collection and destruction, a sound on every meaningful action, UI that animates in, camera that
eases rather than cuts, a brief hit pause on heavy impacts.

## 3. Difficulty and flow

Keep the player in the flow channel: challenge rises with skill. Too far above, anxiety; too far
below, boredom.

- **Sawtooth, not a ramp.** Raise difficulty, peak, then drop to a recovery valley before the next
  climb. Each new mechanic is introduced in a valley. Without valleys, players burn out.
- **Failure cost matches failure frequency.** Where the player will fail often, make failure cheap
  (instant retry, a checkpoint close by). Expensive failure belongs where failure is rare.
- **Difficulty options** widen the audience. Separate assists (aim help, slower time) from the
  challenge settings, and never shame the player for using them.

## 4. Progression

| Type | Mechanism | Risk |
|---|---|---|
| Skill | The player gets better | Needs a good tutorial and curve |
| Character | Stats and abilities unlock | Can replace skill; reads as pay to win if sold |
| Content | New areas, levels, modes | Players stall at each gate |
| Narrative | The story advances | Players who skip story lose the pull |

Use at least two so a player stalled on one still moves on another.

## 5. Economy and balance

- Map every **source** (how the player gains a resource) and **sink** (how it is spent). If sources
  outrun sinks the currency inflates and rewards stop mattering.
- The player must always understand what things cost relative to how fast they earn.
- **Balance check**: build a table of every option (weapons, units, cards) with its cost, output and
  conditions. Look for outliers above or below the cost-to-power curve, dominant strategies (one
  option best in every situation) and dead options nobody would pick. Simulate or play the extremes.
  If data for a check is missing, mark it **not assessed** rather than calling it balanced.

## 6. Tutorials and onboarding

1. **Do, do not tell.** The player performs the action rather than reads about it.
2. **Just in time.** Show a hint when the mechanic is first needed, not before.
3. **Safe first failure.** The first use of a mechanic has little or no penalty.
4. **One new thing at a time.** Never introduce two mechanics together.
5. **Skippable** for experienced players.
6. **No-text test.** Can a new player get through the opening without reading any text?

The first five minutes decide whether the player stays. Watch them more closely than any other part.

## 7. HUD and menus

- Show only what the player needs now; fade what is not urgent.
- Animate a value when it changes (health drop, ammo pickup) so the change is noticed.
- Critical information (health, timer) stays in one fixed screen position.
- Prefer diegetic displays (ammo on the weapon, damage on the character) where they stay readable.
- Every menu works fully with controller, keyboard and touch where those inputs are supported.
- Menus no more than three levels deep; settings reachable from pause in two presses.
- Destructive actions (delete save, restart) need confirmation, and an undo where possible.
- Never rely on colour alone for critical information; offer subtitles, remappable controls and
  text scaling.

## Gotchas

| Mistake | Correction |
|---|---|
| Building content before the loop is fun | Grey-box the loop and playtest it first |
| Mechanics chosen because they are cool | Trace each to a pillar and a target feeling, or cut it |
| Tuning feel in the editor | Measure input latency and frame rate on target hardware |
| Linear difficulty ramp | Sawtooth with recovery valleys |
| Punishing failure in a hard section | Cheap retries where failure is frequent |
| Helping a playtester who is stuck | Stay silent. Note where they stuck and what they tried first |
| "Balanced" with no data | Report the balance check as not assessed |
| Currency with sources and no sinks | Add sinks or the economy inflates |
| Tutorial as a wall of text | Teach through play; run the no-text test |

## Verification

- [ ] Pillars written; every major feature traced to one
- [ ] Core loop prototype playtested by people outside the team, with notes
- [ ] Input latency and frame rate measured on target hardware
- [ ] Difficulty curve drawn with valleys; failure cost matched to frequency
- [ ] Source and sink table for each resource
- [ ] Balance table with outliers, dominant and dead options listed (or marked not assessed)
- [ ] Tutorial passes the no-text test with a new player
- [ ] Playtest notes cover the first five minutes: where players stuck, what they tried, what they
      misread

Read `references/gdd-and-playtesting.md` when writing a game design document or planning a playtest.
