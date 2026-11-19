# Auditing the internal link graph

Read before measuring orphans, click depth or link distribution from a crawl.

## What to measure

- **Click depth**: shortest number of links from the home page to each page. Flag important
  pages deeper than three or four clicks.
- **In-links per page**: how many distinct pages link to it, and from where. Important pages
  with one or two in-links are weakly connected.
- **Orphans**: pages that exist (in the sitemap, the CMS, the database or analytics) but
  have no in-link from any crawled page.
- **Hub coverage**: does each hub link to all its spokes, and does each spoke link back?
- **Anchor text**: list the anchors pointing at each important page. Generic anchors
  ("read more", "here") waste the signal.
- **Crawl waste**: redirect chains, parameter and facet variants, near-duplicate paths.

## How to measure it correctly

- **An in-link is recorded on the linking page.** You find a page's in-links by crawling
  the pages that link to it, not by fetching the page itself. To count in-links, crawl the
  site and invert the edge list.
- **Orphan detection needs two lists.** The crawl gives the reachable set. A second source
  (sitemap, CMS export, analytics landing pages) gives the set that exists. Orphans are the
  difference. A crawl alone cannot find orphans, because by definition it never reaches them.
- **Know what your crawler cannot see.** Links injected by JavaScript, links behind forms
  or logins, and links in navigation that loads on interaction may be invisible to a simple
  HTML crawler. A page your crawler did not reach is "not found by this crawl", not
  "unreachable". Note the crawler's limits in the report.
- **Check the crawl finished.** A crawl capped by page count or time reports depth and
  in-links for a truncated graph. State the cap, and whether it was hit.
- **Count from the full edge list, not from an API view.** Tools that page or limit their
  output return a sample. A count taken from a limited response inherits the limit. If a
  ratio looks impossible, suspect the measurement first.

## Report shape

For each finding: the measure, the count, the threshold, and three to five example URLs so
anyone can check it. One unit per number ("212 pages have a click depth over 4", not a
percentage of an unstated base).
