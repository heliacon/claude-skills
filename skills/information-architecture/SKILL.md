---
name: information-architecture
description: Use when organising content or features into a structure, such as navigation, menus, taxonomy, categories, labels, sitemaps, URL paths, breadcrumbs, internal linking, card sorts, tree tests, or "users can't find X". Not for task flows, interviews or interaction states; use `ux-research`. Not for page layout; use `designer`.
license: MIT
---

# Information architecture

The structure of a shared information space: how content is modelled, grouped, labelled,
navigated and found. Visual polish cannot rescue a wrong structure, and every later
discipline inherits it.

Boundary: this skill owns content, structure, labels and findability. The `ux-research`
skill owns people's tasks, flows and interaction states (and runs the interviews whose
vocabulary feeds the labels here). The `designer` skill lays out a single page.

## The rules that matter most

1. **Model the content before choosing a structure.** List the content types and their
   attributes first. No content model, no defensible IA.
2. **Label with the user's words.** Harvest terms from search logs, support tickets and
   open card sorts. When user and internal terms differ, the user's term goes on the label
   and the internal one goes in metadata.
3. **Validate the structure on its own, before visual design.** A tree test on a
   text-only hierarchy isolates the structure from styling. Opinion is not validation.
4. **Broad and shallow beats narrow and deep.** Aim for three or four levels from home to
   any leaf. Each level is another decision and another place to get lost.
5. **One concept, one label, everywhere.** Nav, page title, breadcrumb and button use the
   same word. A synonym reads as a different thing.
6. **No orphans.** Every page is reachable by at least one link from a parent and ideally
   a sibling, not only by search or a pasted URL.

## When not to use

- Designing the steps of a checkout or a settings flow: `ux-research`.
- Choosing hierarchy, whitespace and emphasis inside one page: `designer`.
- Search ranking, crawl directives, structured data and canonical tags for search
  engines: `seo-aeo-geo`. This skill shapes the structure those depend on.

## Method

1. **Inventory.** Every URL or screen: title, type, owner, last updated, traffic.
2. **Audit.** Mark each item keep, revise, merge or remove. You cannot organise what you
   have not enumerated, and most restructures are partly deletion.
3. **Content model.** Types, their attributes and their relationships.
4. **Vocabulary.** Collect the user's terms (open card sort, search logs, support tickets).
5. **Candidate structure.** Choose the organisation scheme and draft the tree. Output it
   as an indented text tree so it can be reviewed and tree-tested as is.
6. **Labels and scope notes.** Write them as a system, not one at a time.
7. **Validate.** Tree test the candidate; first-click test key pages once wireframed.
8. **Navigation and URLs.** Global, local, contextual and supplementary systems; URL
   patterns per page type.
9. **Linking plan.** Hubs, spokes and cross-links (see graph-aware IA below).

Deliver content model, taxonomy, labels, navigation and URL scheme as separate
artefacts. Folding them into one sitemap hides decisions.

Read `references/findability-testing.md` before running or analysing a card sort, tree
test or first-click test.

## Classification

| Shape | Fits when | Breaks when |
|---|---|---|
| **Exclusive** (one home per item) | Categories are genuinely disjoint (order status, file type) | Real items straddle categories and users disagree where they live |
| **Faceted** (tagged on independent dimensions) | Items vary on several independent attributes (price, size, brand) | Facets are few or depend on each other |
| **Polyhierarchy** (more than one parent) | An item truly belongs in two places | Used freely: when everything is everywhere, location means nothing |

- Prefer facets to a deep exclusive tree when items have independent attributes.
- Apply the **MECE test** to every menu: collectively exhaustive (nothing homeless) and,
  for exclusive schemes, mutually exclusive (nothing double-homed).
- Write a **scope note** for any category two editors might fill differently: what belongs,
  what does not. If a scope note cannot settle it, rename or split the category.

## Organisation schemes

**Exact** schemes need no judgement and suit known-item lookup: alphabetical (only when
the user knows the exact term), chronological, geographical.

**Ambiguous** schemes organise by meaning and suit exploration: topic, task ("track an
order"), audience ("for teachers", only when audiences are distinct and self-identify), and
metaphor (inbox, cart; only while the metaphor holds).

Structures: a **hierarchy** is the backbone. **Hypertext** cross-links complement it but
never replace it. A **database or faceted** structure suits uniform, attribute-rich
content.

## Navigation

| System | Job | Form |
|---|---|---|
| Global | Reach the major areas from anywhere | Persistent top or side nav |
| Local | Move within the current area | Section sub-nav, sibling list |
| Contextual | Jump to related content | In-body links, "related" |
| Supplementary | Safety net | Search, index, sitemap, footer directory |

- At every node the user can answer: where am I, what is here, where can I go next.
- Global nav stays stable across the whole site. Reordering or relabelling per section
  breaks the map the user is building.
- Highlight the current item in global and local nav.
- About seven top-level items at most (a rule of thumb); beyond that, group.
- **Location breadcrumbs** (the item's fixed place in the tree), not path breadcrumbs
  (session history, which only duplicates Back).

## Labels

- Labels are the surface of the IA. A sound taxonomy with wrong labels still fails,
  because people navigate by words.
- **Same level of specificity** within one set. "Trousers, Footwear, Nike" mixes levels.
- **Predict the destination.** "Resources", "Solutions" and "More" carry almost no scent.
- **Never ship internal names.** Enum values, table names and team names are not labels.
  Name what the user gets on the other side of the click.
- Change one label, then reread its siblings: they must still read as peers.

## Findability and scent

People follow **information scent**: cues that predict whether a path leads to their goal.

- **Trigger words.** Each step on a key path shows the word the user carries in their head
  for the next step.
- **Each click raises confidence.** If the page after a click does not obviously match the
  link, the scent is broken and the user backtracks.
- **Pogo-sticking** (in and straight back out of results) means the list lacks scent. Fix
  the labels and summaries at the list. Adding a filter does not fix it.
- **Provide search and browse.** Browse serves users who cannot name what they want;
  search serves users with a known item and a term for it.
- **Faceted search** with counts shows what exists before the click and avoids dead
  zero-result pages.
- **Zero results is never blank.** Offer spelling suggestions, a relaxed query and the
  browse tree.

## URLs

- Readable, lowercase, hyphenated, mirroring the hierarchy: `/catalogue/boots/chelsea-boots`.
  The path reads as a breadcrumb.
- One canonical URL per resource. Redirect variants to it.
- When structure changes, redirect old paths permanently (301). Changing a URL without a
  redirect breaks every link and bookmark that pointed to it.
- Decide the URL pattern per page type before build, not page by page.

## Graph-aware IA

A site is a graph as well as a tree: pages are nodes, links are edges. People, crawlers
and agents all walk the edges.

- **Topic clusters.** A hub page links to its spokes; each spoke links back to the hub and
  across to relevant siblings.
- **Descriptive anchors.** The anchor text carries the trigger word. Never "click here".
- **Treat the internal link graph as a deliverable.** Review it like navigation; do not
  leave it to whatever the CMS generates.
- **Control facet URL explosions.** Decide which facet combinations are linkable pages and
  canonicalise or block the rest, or crawlers spend their budget on near-duplicates.

Read `references/link-graph.md` before auditing internal links, orphans or click depth from
a crawl.

## Gotchas

- **Org-chart navigation.** The structure mirrors departments. Users do not know or care
  how the company is organised. Organise by task or topic and check with an open card sort.
- **No content model.** Pages built one at a time cannot support facets, reuse or
  consistent labels later.
- **A deep tree "to keep menus short".** It moves the cost into extra clicks and wrong
  turns. Use facets or broader levels.
- **Polyhierarchy everywhere.** Cross-filing every item destroys "you are here". Use it
  only where justified and show it.
- **Validating a tree with the people who built it.** They know where everything is.
  Recruit people who match the users.
- **Tree testing the styled prototype.** Visual cues and search let people succeed past a
  bad structure. Test the bare text tree.
- **A navigation label that changes per section.** The same area under two names reads as
  two areas.
- **Calling a page "unreachable" because your crawler did not find it.** Your crawler's
  coverage is a property of your tool. Report "not found by this crawl" and say what the
  crawl could not see (JavaScript-only links, forms, logged-in areas).

## Verification

Before handing the IA to design or build:

- [ ] Content model exists; every type has its attributes.
- [ ] Inventory complete; audit decision recorded per item.
- [ ] Every category passes MECE; ambiguous ones carry scope notes.
- [ ] Labels traced to user vocabulary sources, consistent across nav, titles, breadcrumbs.
- [ ] Global nav stable, active state visible, about seven top items or fewer.
- [ ] Depth to any leaf three or four levels or fewer.
- [ ] Tree test run on the text tree, with success and directness per task recorded and
      any task under target revised and retested.
- [ ] URL pattern per page type; canonicals and redirects planned.
- [ ] Link-graph check: no orphans among important pages, hubs link to spokes and back.
- [ ] Search has a helpful zero-results state.
