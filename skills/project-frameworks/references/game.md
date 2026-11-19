# Framework: game

For games on any engine or the web.

## Agent roster

| Agent | Phases | Role |
|---|---|---|
| `pm` | 1 | Scope and feature list |
| `designer` | 1-2, 4 | Visual style, HUD, menus |
| `ux` | 1-2, 4 | Tutorial, progression, game feel review |
| `architect` | 2 | Engine and technical architecture |
| `frontend` | 2-4 | Game client implementation |
| `backend` | 5 | Multiplayer, leaderboards, cloud saves (if needed) |
| `security` | 5 | Backend and anti-cheat review (if needed) |
| `devops` | 6 | Build pipeline and platform submission |
| `tester` | every phase | Gate, including play-throughs |

Audio direction is outside this roster. Bring in a specialist or give it to the `designer` with a
written brief.

## Phases

### Phase 1: Game design document
Goal: pillars, core loop, mechanics and scope defined and committed.
Agents: `pm` > `designer` + `ux`
Skills: requirements, game-design, ux-research
Outputs: pillars; core loop (what the player does every 30 seconds); win and fail conditions; scope
for the first release (counts of levels, modes, enemies); art style references described in words;
platform targets; save system decision.
Done when: GDD sections 1 to 3 written; scope agreed.

### Phase 2: Prototype (vertical slice)
Goal: the core mechanic feels good on real hardware; art direction proven.
Agents: `architect` > `frontend` + `designer`
Skills: game-design, visual-design, frontend, code-quality
Done when: the tester plays a complete short loop on target hardware and approves the feel; outside
players have playtested it; frame rate measured.

### Phase 3: Content build
Goal: all planned content implemented with placeholder or final art.
Agents: `frontend`
Skills: game-design, code-quality, tdd
Done when: the tester completes every planned level and mode; tester approves.

### Phase 4: Polish and juice
Goal: excellent feel; tutorial complete; edge cases handled.
Agents: `frontend` + `designer` > `ux` (tutorial review)
Skills: game-design, visual-design, ux-research
Done when: juice pass complete; tutorial passes the no-text test with new players; tester approves.

### Phase 5: Backend (only if multiplayer or persistent)
Goal: leaderboards, save sync or multiplayer working.
Agents: `backend` > `architect` (review) > `security` > `tester`
Skills: api-design, security, code-quality

### Phase 6: Build and ship
Goal: automated builds; submitted to platform stores.
Agents: `devops` > `tester`
Skills: devops, ci-cd
Done when: a pipeline build is the one submitted; store requirements met per platform.

## Non-negotiables

- **Save system** designed in phase 1: local, cloud or both. It is the hardest thing to retrofit.
- **Input** decided in phase 2: controller, keyboard and mouse, touch as appropriate.
- **Frame rate target** (for example 60 fps on the minimum spec) is a requirement. Profile from
  phase 2, not after content lands.
- **Playtesting with real players** in phase 2 and phase 4. The team's intuition is not enough.
- **Localisation**: if more than one language, externalise strings from phase 3.

## Skill loading

| Phase | Skills |
|---|---|
| 1 | requirements, game-design, ux-research |
| 2 | game-design, visual-design, frontend |
| 3-4 | game-design, code-quality, tdd, visual-design |
| 5 | api-design, security |
| 6 | devops, ci-cd |
