# Test plan template

Read this when starting a test plan for a phase, feature or release. Save it as
`tasks/test-plan-<phase>.md`. Keep it short: a page is usually enough.

```markdown
# Test plan: [phase or feature]

## In scope
- [what is being tested]

## Out of scope (explicit)
- [what is deliberately not tested this pass, and why]

## Approach
- Risk tier per area (link the risk register)
- Design techniques per area (boundaries, decision tables, state transitions)
- Automated versus exploratory split

## Environments
- [local, staging, CI]; config differences; feature flags

## Test data
- Source and refresh; personal data policy (synthetic or masked, never raw production data)

## Roles
- Who builds, who reviews, who signs off (builder, QA, product owner for UAT)

## Entry criteria
- [what must be true before testing starts]

## Exit criteria
- [what must be true to call it done; severity threshold for open defects]
```
