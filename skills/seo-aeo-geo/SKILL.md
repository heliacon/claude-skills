---
name: seo-aeo-geo
description: Use when auditing or fixing how a site is crawled, indexed, ranked, quoted by answer engines or mentioned by AI assistants. Covers robots.txt, sitemaps, canonicals, noindex, schema, Core Web Vitals, AI crawlers and llms.txt questions. Not for positioning or content strategy (use `marketing`) or page copy (use `copywriter`).
license: MIT
---

# SEO, AEO and GEO

Three layers of one problem: being found, being quoted, being mentioned.

- **SEO** (classic search): can a crawler reach the page, index it and rank it.
- **AEO** (answer engines): can an engine lift a self-contained passage and cite you.
- **GEO** (generative engines): does your brand appear inside answers written by a language model.

All three stand on one foundation: a crawlable, well-structured site with its main content in the
served HTML. There is no answer-engine shortcut around a broken foundation. Fix the layers in order.

## The rules that matter most

1. **Every finding names its evidence.** A count comes with example URLs and the exact line or
   header that shows it. "37 pages have no canonical" without three checkable examples is not a
   finding.
2. **Your instrument's limit is not a fact about the site.** If your crawler could not discover or
   render a URL, report "not measured", never "not crawlable" or "clean". A search engine has
   other discovery routes (external links, history, sitemaps you did not fetch).
3. **Prove a control exists; do not infer it.** "The bot got a non-200, so the site blocks it" can
   score a broken site as protected. Show the robots.txt rule, the header or the response body that
   implements the block.
4. **Check the right bot for the claim.** Googlebot renders JavaScript; many other crawlers,
   including several AI crawlers, fetch raw HTML only. A page that works for one can be empty for
   another. Name the user agent each claim is about.
5. **Measure outcomes, not proxies.** Qualified traffic, citations and conversions pay. Rank
   position and "visibility scores" are diagnostics. Optimising a proxy directly usually degrades
   the outcome.
6. **Primary sources over folklore.** For robots.txt read RFC 9309 (the standard) first, then each
   crawler's documented deviations; robotstxt.org is useful for history. For search features read the search engine's own documentation.
   Blog consensus is not a source.

## When not to use

- What to say and to whom (positioning, messaging, channels): the `marketing` skill.
- Writing the words on the page: the `copywriter` skill.
- Site navigation and labelling as a findability problem for people: the
  `information-architecture` skill.
- Front-end performance work beyond diagnosing Core Web Vitals: the `frontend` skill.

## Layer 1: SEO

**Access is not indexing.** robots.txt controls whether a compliant crawler fetches a path. It
does not remove a URL from the index: a disallowed URL can still be indexed from external links and
shown with no snippet.

**noindex versus disallow**, the mistake that catches everyone:

- `Disallow` (robots.txt): never fetched, so a `noindex` on the page is never seen and link equity
  into it is trapped.
- `noindex` (meta robots or `X-Robots-Tag`): fetched, outbound links still followed, kept out of the
  index.
- To remove a page from results: `noindex` first, wait until it drops out, then disallow if crawl
  cost matters. NEVER `noindex` and disallow the same URL at once: the crawler cannot obey a
  directive it cannot read.

**robots.txt status codes** (RFC 9309): a 4xx on `/robots.txt` means "no rules, crawl everything";
a 5xx or unreachable file means "assume everything is disallowed" for a period. So a robots.txt that
returns 500 can quietly stop a site being crawled. Check the status of the file itself, not only its
content.

**Canonicals** are a hint, not a directive. Every canonical target must be a 200, indexable,
self-canonical URL that equals the final resolved URL. A canonical that points at a redirect, a 404,
a `noindex` page or another canonical throws away the consolidation silently.

**Main content in served HTML.** If body text appears only after client JavaScript runs, it may not
exist for crawlers that do not render. Check the raw response, not the browser view.

Read `references/technical-seo.md` when auditing status codes, crawl budget, internal linking,
on-page elements, hreflang, structured data or Core Web Vitals. It holds the detail and thresholds.

## Layer 2: AEO

The unit of value moves from the page to the **passage**. Engines retrieve and quote chunks.

- **Each section stands alone.** It answers one question completely without the rest of the page.
- **Lead with the answer.** "The filing deadline is 31 January." Not "as discussed above, it
  depends". One lifted sentence must be true and complete on its own.
- **Entity clarity.** Name people, products and organisations consistently, define terms once and
  mark entities up with schema.org so the engine binds the text to the right thing.
- **Real Q&A structure** where the content really is questions and answers.
- **Quotable sentences.** Short and declarative beats hedged and context dependent.

## Layer 3: GEO

- **Share of voice is the outcome.** How often your brand appears for the queries that matter, and
  how much of the answer you hold against competitors. Measure by running the real queries against
  the real assistants, several times each, because answers vary run to run. Record date, engine,
  query and full answer.
- **Retrieval friendliness.** Assistants with live retrieval favour the same properties AEO
  rewards: crawlable, server-rendered, chunkable, self-contained.
- **Query fan-out.** An assistant splits one question into many sub-queries. Cover the cluster of
  related sub-questions, not only the head term, so you can be retrieved for each branch.
- **Training data.** Many models train on derivatives of Common Crawl. Its index can be queried by
  URL or domain to check inclusion. Inclusion is neither guaranteed nor sufficient.
- **Crawlers versus agents.** A crawler gathers content for later (search index or training). An
  agent acts for a user in real time (browses, fills a form). Blocking a training crawler is a
  different decision from blocking a user's agent mid-task. Treat them separately in robots rules,
  serving and analytics.

## Gotchas

| Mistake | Correction |
|---|---|
| Reporting "no structured data" from a raw fetch | JSON-LD injected by JavaScript is invisible to a non-rendering fetch. Check the rendered DOM before saying it is missing, and say which view you checked |
| Reporting content as present because the browser shows it | Check the raw HTML too. A non-rendering crawler sees only that |
| Calling a page "uncrawlable" because your crawler missed it | "Not discovered by this crawl". The engine may have other routes |
| Reading a 403 or 503 to a bot as a deliberate block | Find the rule. It may be an outage or a bot-protection false positive |
| Recommending `llms.txt` as a fix | It is a proposal, not an adopted standard, with no evidence major engines use it. Say so, and prefer robots.txt, sitemaps, schema.org and server-rendered content |
| Crawling with a headless browser as if it were a plain fetcher | Skip non-HTTP schemes (`mailto:`, `tel:`) and disable scripts when measuring bytes served; scripts add their own requests |
| Re-crawling for each analysis | Crawl once, persist the dated result, run every analysis off that artefact. It is consistent and polite to the target |
| Optimising meta descriptions for ranking | They are not a ranking factor. They are the snippet. Write them for the click |
| Treating Core Web Vitals as a ranking lever | A tie-breaker for ranking; the bigger effect is on conversion. Fix for users |
| A sitemap full of redirects and noindex pages | List only 200, self-canonical, indexable URLs |
| Weighted "AI visibility" scores quoted as standards | They are a vendor's model, not a measurement. Report the underlying observations |

## Verification

An audit is done when each item below has evidence attached (URL, header or line, date checked):

- [ ] robots.txt fetched; its own status code recorded; no critical CSS or JS disallowed
- [ ] Sitemap lists only 200, self-canonical, indexable URLs and is referenced from robots.txt
- [ ] No URL is both `noindex` and disallowed
- [ ] One host and scheme; duplicates 301 to it; redirect chains are one hop
- [ ] Every canonical target resolves to a 200, indexable, self-canonical URL
- [ ] Priority pages are not orphans
- [ ] Main content present in the raw HTML (checked with JavaScript off)
- [ ] Structured data checked in both raw and rendered views, matching visible content
- [ ] Core Web Vitals taken from field data, not only a lab run
- [ ] Key answers are self-contained, answer-first passages
- [ ] Share of voice measured on named queries, engines and dates, with repeat runs
- [ ] Each count in the report has checkable examples; each gap your tools could not see says
      "not measured"
