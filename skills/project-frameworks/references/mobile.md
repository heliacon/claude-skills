# Framework: mobile application

For apps installed on iOS or Android.

## Agent roster

| Agent | Phases | Role |
|---|---|---|
| `pm` | 1 | Requirements and platform strategy |
| `ux` | 1-2 | Mobile flows and gestures |
| `designer` | 2 | Design aligned to platform conventions |
| `architect` | 2 | State management and API strategy |
| `backend` | 2-3 | Mobile-ready API, if building one |
| `frontend` | 3-4 | App implementation |
| `security` | 4 | Mobile security review |
| `devops` | 4-5 | Build pipeline and store submission |
| `tester` | every phase | Gate |

## Phases

### Phase 1: Discovery and platform strategy
Goal: requirements defined; platform strategy agreed.
Agents: `pm` > `ux`
Skills: requirements, ux-research, mobile
Decide: iOS, Android or both; native, cross-platform or progressive web app; minimum OS version;
offline behaviour.
Done when: decisions recorded with reasons; flows approved.

### Phase 2: Architecture and design
Goal: app architecture settled; design aligned to each platform.
Agents: `architect` + `designer`
Skills: system-design, visual-design, mobile
Note: iOS follows the Human Interface Guidelines and Android follows Material Design. Where they
differ, follow each platform rather than forcing one look on both.
Done when: architecture recorded; deep link scheme defined; design specs per platform; tester
approves.

### Phase 3: Core implementation
Goal: core screens and flows work on device.
Agents: `frontend` + `backend` (if applicable)
Skills: frontend, mobile, code-quality, tdd, api-design
Done when: core flows pass on real devices (not only simulators), including a low-end device;
tester approves.

### Phase 4: Polish, security and compliance
Goal: store ready; security reviewed; permissions and privacy declarations complete.
Agents: `frontend` (polish) > `security` > `tester`
Skills: security, security-audit, mobile
Done when: privacy manifest and data safety form match what the app actually collects; store
assets ready; no open critical or high findings.

### Phase 5: Pipeline and submission
Goal: automated signing and build; app submitted.
Agents: `devops` > `tester`
Skills: devops, ci-cd, mobile
Done when: a pipeline build is what reaches the store; crash reporting live; staged rollout set.

## Non-negotiables

- **Offline mode** decided in phase 1. It shapes the data layer and is hard to retrofit.
- **Deep links** (URL scheme and universal or app links) defined in phase 2.
- **Push notifications** need backend support before the app side is built.
- **Analytics event taxonomy** agreed with `pm` before instrumenting in phase 3.
- **Crash reporting** wired up before the first external test build.

## Skill loading

| Phase | Skills |
|---|---|
| 1 | requirements, ux-research, mobile |
| 2 | system-design, visual-design, mobile |
| 3 | frontend, mobile, code-quality, tdd |
| 4 | security, security-audit, mobile |
| 5 | devops, ci-cd |
