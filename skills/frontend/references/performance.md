# Web performance

Read this when a page is slow, when adding a heavy dependency or before a launch that has performance
targets.

## Contents
1. Order of work
2. Core Web Vitals
3. Fixes by symptom
4. Bundle size and code splitting
5. Render-path cost

## 1. Order of work

Fix in order of impact. Micro-optimising a component while the page waits on three sequential requests is
wasted effort.

1. **Request waterfalls.** Sequential fetches where the second does not need the first. Start independent
   requests together (`Promise.all`, parallel loaders, server-side fetch). Start fetches before the code that
   needs them has loaded.
2. **Bytes shipped.** JavaScript is the expensive byte: it must be parsed and run, not just downloaded.
3. **Server response time.** TTFB, caching headers, CDN.
4. **Main-thread work during interaction.** Long tasks, expensive handlers, large re-renders.
5. **Re-render cost and micro-optimisation.** Last, and only with a profile in hand.

## 2. Core Web Vitals

Thresholds as published by web.dev (INP replaced FID in March 2024). Judge at the 75th percentile of real
visits, mobile and desktop separately.

| Metric | Good | Needs improvement | Poor | Measures |
|---|---|---|---|---|
| LCP (Largest Contentful Paint) | 2.5s or less | up to 4s | over 4s | Loading: when the main content is visible |
| INP (Interaction to Next Paint) | 200ms or less | up to 500ms | over 500ms | Responsiveness to input |
| CLS (Cumulative Layout Shift) | 0.1 or less | up to 0.25 | over 0.25 | Visual stability |

How to measure:
- Development: the browser's Performance panel, with CPU and network throttling on. A fast laptop hides
  most problems.
- CI: Lighthouse CI against a staging URL. Lab numbers catch regressions; they do not prove field quality.
- Production: the `web-vitals` library or real-user monitoring. Field data is the arbiter.

## 3. Fixes by symptom

LCP too slow:
- Hero image discovered late: preload it (`<link rel="preload" as="image">`) or set `fetchpriority="high"`.
  Never lazy-load the LCP image.
- Render-blocking scripts: `defer` or `type="module"`; move non-critical CSS off the critical path.
- Slow server: cache, CDN, stream the HTML.
- Content rendered only after a client fetch: render it on the server.

INP too slow:
- Long tasks: split them. Yield to the main thread between chunks (`scheduler.yield()` where supported,
  otherwise `setTimeout(fn, 0)`).
- Expensive handlers: do the visible update first, defer the rest; debounce text input that triggers work.
- Large re-renders on each keystroke: narrow what re-renders; move heavy derivation out of the render path.

CLS too high:
- Images, video and embeds without dimensions: set `width` and `height` or `aspect-ratio`.
- Web fonts reflowing text: preload the main face; `font-display: swap` with a size-matched fallback.
- Content injected above existing content: reserve the space (`min-height`) or insert below the viewport.

## 4. Bundle size and code splitting

- Before adding a dependency, check its size and whether it tree-shakes (bundlephobia or the bundler's
  own analysis). Prefer a platform API or a ten-line helper over a library for one function.
- Split by route, by heavy feature (rich text editor, map, chart library) and by audience (admin code out of
  the user bundle).

```javascript
const AdminPanel = lazy(() => import("./pages/AdminPanel"));
const RichEditor = lazy(() => import("./components/RichEditor"));
```

- Run the bundle analyser (`vite-bundle-visualizer`, `webpack-bundle-analyzer` or the framework's own) after
  each dependency change. Flag any chunk over about 250KB parsed, and any library pulled in whole for one
  function.
- Barrel files (`index.ts` that re-exports everything) can defeat tree-shaking in some bundlers. Import from
  the module path when a barrel drags in the whole package.

## 5. Render-path cost

A render function (a React component body, a template, a computed getter) runs far more often than its
data changes. Work placed there is paid on every hover, every unrelated state change and every progress
tick.

Example: a dashboard recomputed an aggregate over thousands of rows in its render path. The first symptom
was not a slow chart. An unrelated test of another view became flaky because the main thread was starved.

How to fix:
1. Measure the function alone at realistic sizes (for example 500, 2,000 and 8,000 rows).
2. Remove duplicate work first (three passes over the same rows become one).
3. Then memoise on a cheap key of the upstream inputs, not of the derived rows. A memo keyed on the output
   still pays to build it.
4. Prove the memo matters: disable it and require the measurement to get worse. If it does not, the memo is
   noise.

A test that starts failing intermittently right after a change is evidence about the change. Measure before
re-running it.
