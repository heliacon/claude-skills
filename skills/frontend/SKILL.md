---
name: frontend
description: Use when building, reviewing or fixing browser UI, such as pages, components, forms, client state, charts, print or PDF views, accessibility or web performance (Core Web Vitals, bundle size, slow renders). Not for visual direction, layout critique or brand (use `designer` or `visual-design`). Not for native or React Native apps (use `mobile`).
license: MIT
---

# Frontend

Standards for browser UI that real people use with keyboards, screen readers, slow phones and printers.
The rules below are the ones that get skipped when UI "looks done".

## Rules that matter most

1. **Use the element that means the thing.** `<button>` for actions, `<a href>` for navigation, `<label>`
   for every field, `<table>` for tabular data. A `<div>` with a click handler is not focusable, has no role
   and is invisible to assistive technology. ARIA only fills gaps a native element cannot.
2. **Every async view has four states:** loading, error, empty and data. Write all four before calling
   the view done. A blank region is a bug.
3. **Never fabricate data.** A missing period is a gap or a "No data" label, never zero and never an
   interpolated line. Forecasts are always visibly distinct from actuals.
4. **Never signal by colour alone.** Every colour-coded status also carries text or an icon with an
   accessible name. Greyscale print and colour-blind readers get nothing otherwise.
5. **Shareable state lives in the URL.** Filters, tabs, search terms, selected ids. Back, refresh and
   share must keep it. Ephemeral state (hover, an open tooltip) does not go in the URL.
6. **A value derived from several pieces of state gets one function, called whenever any of them
   changes.** Never compute it inside the callback that belongs to one of them. Example: a download link
   built from a cutoff and a group filter was only rebuilt in the cutoff's fetch callback, so after a
   filter change the export silently pointed at the whole list.
7. **Reflow from 320 CSS px up.** No horizontal page scroll, no clipped content, text resizable to 200%.
   Test at a phone width as well as the desktop width you designed for.
8. **Match tooling to the need.** In an existing repo, follow the framework and build already there. For
   a small new page or internal tool, consider plain HTML, CSS and a little JavaScript before adding a
   build pipeline; reach for a framework when the state genuinely demands it.

## When not to use

- Choosing a visual direction, typography or palette: the `designer` and `visual-design` skills.
- Native iOS, Android or React Native: the `mobile` skill (and `swift` for Swift code).
- API shape and server endpoints: the `api-design` and `backend-patterns` skills.
- Test technique in depth: the `tdd` and `testing-strategy` skills.

## Where state lives

Decide before writing component state. Start local and escalate only for a stated reason.

| State | Home | Example |
|---|---|---|
| Local UI | Component state | Modal open, input draft, hover |
| Shared by siblings | Nearest common parent | Active tab read by two panels |
| Server data | A server-cache library (TanStack Query, SWR) or the framework's loader | API responses, pagination, refetch |
| App-wide client state | A small store, only if needed | Signed-in user, notification queue |
| Shareable view state | URL query or route | Filters, search, selected id |
| Survives reload, per device | `localStorage` | Preferences, unsent drafts |

Escalate only when: two non-related components need the same state (lift it, or use the server cache);
state must survive reload (URL or storage); the data comes from a server (server cache, not a global
store). Server data copied into a global store goes stale and duplicates loading and error logic.

## Charts, print and simplified views

- Charts: one colour map shared by front and back end, an explicit empty state, honest gaps, an HTML
  legend. Read `references/charts.md` before building or changing a chart.
- Print or PDF: read `references/print.md` before building a printable view. Canvases do not print
  reliably without the capture step it describes.
- Simplified or read-only views for non-technical readers: no edit controls, generous text and target
  sizes, status as colour and words, plain-language summaries computed from the data, few screens, and
  headline numbers with short sentences instead of raw tables.

## Performance

Fix in order of impact: request waterfalls first, then JavaScript shipped, then server response time,
then main-thread work during interaction and micro-optimisation last. Targets: LCP 2.5s or less, INP
200ms or less, CLS 0.1 or less at the 75th percentile of real visits. Read `references/performance.md`
when a page is slow, before adding a heavy dependency or before a launch with performance targets.

## Accessibility

Read `references/accessibility.md` before an accessibility review or before signing off a new page.
It holds the review method (reflow, keyboard path, focus, scroll regions, target size, motion, skip
links, names of repeated controls) and how to tell a tool's false positive from a real failure.

## Reviewing an existing site

A review of a built site you did not write, with no change to make, needs a different subset of this
skill.

- **Lab Web Vitals, headless.** Run Lighthouse from the command line against each key template, not
  only the home page: `npx lighthouse <url> --only-categories=performance --output=json
  --chrome-flags="--headless=new"`. Read LCP, CLS and Total Blocking Time from the JSON. TBT stands in
  for INP, which needs a real interaction and cannot be taken from a page load. Lab runs use
  simulated throttling, so quote them as lab figures with the date and settings. Field data (a real
  user report) judges; the lab run explains. Run each page three times and quote the median: one run
  is noise.
- **Lazy LCP check.** Find the LCP element (the Lighthouse report names it, or a
  `PerformanceObserver` for `largest-contentful-paint`) and read its markup. `loading="lazy"` on it is
  a defect; a missing `fetchpriority="high"` on a hero image is a likely improvement. Check at phone
  width too: the LCP element often changes with the layout.
- **Build items that do not apply.** The four async states and URL state are build rules. On a static
  site with no client data and no filters there is nothing to force, so do not report their absence.
  Report them only where the site really fetches data or has view state worth sharing.
- **Accessibility** follows `references/accessibility.md`, on every page in scope.

## Gotchas

- **Render paths are hot loops.** A component body or computed getter runs on every hover and every
  unrelated state change. Heavy derivation there starves the main thread, and the first symptom may be a
  flaky test elsewhere. Deduplicate, then memoise on the upstream inputs.
- **An undeclared CSS custom property fails silently.** `var(--mono)` when the token is `--font-mono`
  makes the declaration invalid at computed-value time: the property inherits, with no error. In a
  shorthand (`font: 400 10px/1 var(--mono)`) the size and line-height go too. Give `var()` a fallback or
  check declared tokens against referenced ones over the built stylesheet.
- **A chart's height goes on its wrapper.** A height on the `canvas` fights the library's resize logic
  and the chart grows on every resize.
- **Focus is your job in custom widgets.** Opening a dialog moves focus into it; closing returns focus to
  the trigger; Escape closes. Prefer the native `<dialog>` element. Rebuilding markup with `innerHTML`
  drops focus.
- **`outline: none` with no replacement** removes the only cue keyboard users have. Use `:focus-visible`
  to style it instead.
- **Icon-only buttons need a name** (`aria-label` or visually hidden text).
- **Content that exists only after a client fetch** is slow on weak devices, blank when JavaScript fails
  and weaker for crawlers. Render meaningful content on the server where the stack allows it.
- **Unsized media shifts layout.** Set `width` and `height` (or `aspect-ratio`) on images, video and
  embeds. Never lazy-load the image that is the largest above-the-fold element.
- **Hand-rolled dropdowns, tabs and sliders** need the full keyboard model from the WAI-ARIA Authoring
  Practices. A native element is almost always cheaper.
- **A hand-written fake DOM can make tests inert.** If the fake returns a fresh object per lookup, every
  property written to it (`href`, `disabled`, `value`) is lost and no assertion on it can fail. Revert the
  feature and require the test to fail before trusting it.
- **A pinned CDN version, never an unpinned one.** An unpinned script changes under you without a commit.

## Verification

Prove it with what the project already has (its test runner, linter, type checker, accessibility tooling)
before adding new tools.

- [ ] Tests, lint and type check pass. Any new test was seen to fail with the feature reverted.
- [ ] The page was rendered and looked at, at a phone width and a desktop width. Where possible, give
      reviewers a running preview as well as screenshots.
- [ ] Keyboard only: every control reachable, operable and visibly focused; order matches the visual
      order; no trap.
- [ ] An automated accessibility audit (axe, Lighthouse or the project's tool) has no new violations,
      and the manual checks in `references/accessibility.md` were run.
      Contrast checked with a tool: 4.5:1 body text, 3:1 large text and UI component borders (WCAG AA).
- [ ] Loading, error, empty and data states each shown, by forcing each one.
- [ ] Shareable state survives refresh and back.
- [ ] Console has zero errors and zero warnings on load and during use.
- [ ] Performance budget checked if the change adds a dependency or touches a heavy view (bundle
      analyser, a throttled profile).
- [ ] Print preview checked if the page is printable.

For a review, report findings per file with the rule broken and the fix, worst first.
