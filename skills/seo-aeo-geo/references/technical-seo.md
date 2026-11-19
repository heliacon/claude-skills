# Technical SEO detail

## Contents
1. Status codes
2. Sitemaps and crawl budget
3. Canonicalisation and duplicates
4. Internal linking
5. On-page elements
6. Structured data
7. Core Web Vitals
8. Content quality

## 1. Status codes

| Code | What it means to a search engine |
|---|---|
| 200 | Indexable content. The normal state for a page that should rank |
| 301 / 308 | Permanent redirect. Consolidates signals to the target. Use for moves |
| 302 / 307 | Temporary. Signals stay with the original URL. Wrong for a permanent move |
| 304 | Not modified. Saves crawl effort; no content change |
| 404 | Not found. Drops from the index over time. Fine for pages that are really gone |
| 410 | Gone. A faster removal signal than 404 |
| 429 / 5xx | Overload or error. Repeated, it slows crawling and can cause removal |
| Soft 404 | A 200 on an empty or error page. Wastes crawl effort and confuses indexing |

Check the status of the page the user would land on after all redirects, and the length of the
chain on the way. Each hop adds latency and weakens the signal.

## 2. Sitemaps and crawl budget

A sitemap (sitemaps.org protocol) lists canonical, indexable URLs you want fetched. Leave out
redirects, `noindex` pages, blocked pages and parameter variants. Keep `lastmod` honest: a date
that changes on every build teaches the engine to ignore it.

Crawl budget only matters on large sites (tens of thousands of URLs and up). Crawl waste comes from
faceted filter combinations, session IDs, calendars, sort parameters, soft 404s and redirect chains.
Reduce it with clean internal links, `noindex` on thin variants, consistent parameters and a
disciplined sitemap. On a small site, do not spend effort here.

## 3. Canonicalisation and duplicates

Duplicate sources: `www` and bare host, `http` and `https`, trailing slash, letter case, tracking
parameters, print views, pagination. Pick one host and scheme, 301 the rest and give every page a
self-referencing canonical.

Audit: for each page, resolve the canonical target fully. It must return 200, be indexable, carry a
canonical to itself and match the final URL. Flag loops and chains.

## 4. Internal linking

- Link equity moves through internal links. A hub page that links to and from its cluster pages
  concentrates authority where it matters.
- An orphan page has no internal link in. Crawlers may never find it. Every priority page needs at
  least one editorial link.
- Anchor text is a relevance signal. Describe the target. Do not stuff identical anchors sitewide.
- Prefer a direct link to the final canonical URL over relying on a redirect or a canonical to
  carry equity.
- `rel="sponsored"` for paid links, `rel="ugc"` for user content, `rel="nofollow"` otherwise. Use the
  specific value.

## 5. On-page elements

- **Title**: the strongest on-page relevance signal and a large click-through lever. Unique per page,
  primary subject first.
- **Headings**: one clear `h1` stating the subject. Headings show structure, not styling.
- **Meta description**: not a ranking factor. It writes the snippet. Unique per page.
- **hreflang**: declares language and region variants. Must be reciprocal and self-referencing, and
  each URL must be the canonical of its variant.
- **Images**: descriptive `alt`, sensible file names, modern formats, explicit dimensions (prevents
  layout shift), lazy-load below the fold only.

## 6. Structured data

Use JSON-LD with schema.org types for real entities on the page (Organization, Product, Article,
BreadcrumbList and so on). Mark up only what is visible. It enables rich results and gives machines
an unambiguous fact structure, which helps answer engines bind text to entities.

Validate with the search engine's rich results test and a schema validator. Remember the view
problem: markup inserted by client JavaScript appears only in the rendered DOM. Report which view
each finding came from.

## 7. Core Web Vitals

Field metrics at the 75th percentile of real visits:

| Metric | Measures | Good |
|---|---|---|
| LCP (Largest Contentful Paint) | Loading | 2.5 s or less |
| INP (Interaction to Next Paint) | Responsiveness | 200 ms or less |
| CLS (Cumulative Layout Shift) | Visual stability | 0.1 or less |

TTFB (time to first byte) is upstream of LCP and worth tracking. Use field data (the browser
user experience report or your own real-user monitoring) to judge; use lab runs to debug.

## 8. Content quality

Search engines describe quality through experience, expertise, authoritativeness and trust. Treat it
as a lens, not a dial. Ask: does the page satisfy the intent behind the query, how completely
compared with what already ranks and is there a real, identifiable author or organisation behind
it? Intrusive interstitials and content buried under ads work against it.
