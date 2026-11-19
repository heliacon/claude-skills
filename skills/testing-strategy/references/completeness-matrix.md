# Completeness matrix

Read this when auditing a component. Find its type, check each category is present. A missing MUST
category makes the area PARTIAL.

## Contents
- Backend (API and service layer)
- Frontend (UI components)
- Database (migrations, queries, constraints)
- Domain and pure functions
- Accessibility checklist (WCAG 2.2 AA, code-review level)

## Backend (API and service layer)

| Category | Required | Example |
|---|---|---|
| Happy path | MUST | `POST /orders` with a valid payload returns 201 and the order is persisted |
| Error paths | MUST | Invalid input 422, auth failure 401, database error 500 with no partial write |
| Auth and permissions | MUST | Unauthenticated 401; wrong role 403; another tenant's id 404 or 403 |
| Boundary values | MUST | Empty body, maximum-length string, 0 and negative numbers |
| Resilience (external calls) | MUST | Timeout handled; dependency down gives a fallback or a clear error |

## Frontend (UI components)

| Category | Required | Example |
|---|---|---|
| Interaction | MUST | Click, form submit, keyboard navigation |
| Empty and loading states | MUST | No data shows an empty-state message, not a blank area |
| Error state | MUST | API failure renders an error message, not a blank screen |
| Accessibility | MUST | The checklist below |
| Responsive layout | SHOULD | Renders correctly at a phone-width breakpoint |

## Database (migrations, queries, constraints)

| Category | Required | Example |
|---|---|---|
| Migration up | MUST | Applying it gives the expected schema |
| Migration down | MUST | Rolling back restores the previous schema |
| Constraints | MUST | Duplicate key errors; nullable column accepts null |
| Cascade behaviour | MUST if a foreign key exists | Deleting a parent does what the key definition says to children |
| Index use | SHOULD | The query plan for a hot query uses the intended index |

## Domain and pure functions

| Category | Required | Example |
|---|---|---|
| Happy path | MUST | Correct output for typical input |
| Boundary values | MUST | 0, negative, maximum, empty collection |
| Invalid input | MUST | Wrong type, null or empty string raises with a clear message |
| Determinism | MUST where output could vary | Same input gives the same output every time |
| Edge cases | MUST | Every edge case in the function's spec |

## Accessibility checklist (WCAG 2.2 AA, code-review level)

Check in rendered output or component assertions. Missing items make the area PARTIAL. Do not block on
SHOULD-level advisories. For a full audit use an automated scanner (axe or similar) plus a keyboard and
screen-reader pass.

| Criterion | Check |
|---|---|
| Images | Every `img` has `alt`; decorative images use `alt=""` |
| Form labels | Every input has an associated `label` or `aria-label` |
| Headings | Levels do not skip (h1, h2, h3 in order) |
| Contrast | Body text 4.5:1; large text 3:1 |
| Target size | Interactive targets at least 24 by 24 CSS pixels (AA); 44 by 44 is the comfortable default |
| Focus | Every focusable element has a visible focus style; focus is not hidden behind sticky content |
| Roles | `role` matches the element's meaning; no redundant `role="button"` on a `button` |
| Errors | Validation messages are tied to their input with `aria-describedby` |
