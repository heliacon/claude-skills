---
name: designer
description: "Use when asked to critique, redesign or review the layout and hierarchy of a page, screen, landing page or dashboard (hero, CTAs, card grids, testimonials), or when a design \"looks off\", \"looks generic\" or \"looks AI-made\". Use it for any layout feedback, even if the word design is not used. Not for tokens, palettes or type scales; use `visual-design`. Not for images; use `artist`."
license: MIT
---

# Designer

Applying a design system to a real page so a person feels it was considered, and
redesigning one that has drifted. The `visual-design` skill builds the system (tokens,
scales, component specs). The `artist` skill makes the images. The `copywriter` skill
writes the words. This skill decides what goes where and why, then proves it on the
rendered page.

## The rules that matter most

1. **Write the intent first.** One sentence: who the page is for and the single thing it
   must make them do or understand. If you cannot write it, you cannot design it.
2. **Never restyle first.** Audit, structure and hierarchy come before colour. Most
   redesigns are mostly subtraction.
3. **Judge the rendered page, not the code.** Open it at 375px and at full width, take a
   screenshot and look. An agent that has not seen its output is guessing.
4. **One primary action per view.** If two things shout, nothing is heard.
5. **Commit a direction before writing CSS** and run the median test on it (below).
6. **Decide the surface register** (brand, product or content) before any craft decision.
   The same flourish is right on one and a bug on another.

## When not to use

- Defining tokens, ramps, type scales, dark-mode remaps or component state specs:
  `visual-design`.
- Generating or directing illustrations, icons, hero images, marks or diagrams: `artist`.
- Writing headlines, calls to action or microcopy: `copywriter`. This skill decides where
  copy sits and how much space it gets.
- Site-wide navigation and taxonomy: `information-architecture`.
- Implementation detail of components and state management: `frontend`.

## The redesign process

1. **Intent.** The one sentence above.
2. **First impression.** Before reading anything, look at the current page for two
   seconds. Write down what registered: the first thing seen, the second, and what you
   think the page is for. That is what a stranger gets.
3. **Audit.** List every block and its job. Mark each keep, cut, move or merge.
4. **Structure.** Decide what belongs on this page and what belongs on another. A page is
   an entrance, not a warehouse (see "Distributing content").
5. **Hierarchy.** Rank the remaining blocks: first, second, third look.
6. **Wireframe.** Blocks and hierarchy in greyscale only. Prove the structure works
   without colour.
7. **Direction.** Commit the four lines below.
8. **Apply the system.** Tokens, type roles, spacing, components from `visual-design`.
9. **Assets.** Brief the images through `artist`.
10. **Render, critique, fix.** Run the loop in "Render and verify" until the checklist
    passes. Then cut one more thing.

## Commit a direction

Four lines, decided before any CSS:

- **Colour**: 4 to 6 named values and the job of each.
- **Type**: faces for display, body and utility roles.
- **Layout**: one sentence plus a text wireframe of each key view.
- **Signature**: the single element the page will be remembered by. Spend the boldness
  there and keep everything around it quiet.

Then the **median test**: would you produce this same design for any similar brief? If
yes, it is a default, not a design. Go back to the subject matter and find what is
specific to it (its materials, its documents, its tools, its era) and let that shape the
signature.

### Generated-design tells (refuse them as reflexes)

- A default typeface chosen because nobody chose (Inter, Roboto, Arial, Space Grotesk).
- A big number, a small label and a gradient accent, when the content is not one number.
- `01 / 02 / 03` markers on content that is not a sequence.
- Grids of identical cards, each with an icon, a heading and two lines.
- Glassmorphism, gradient text, coloured side stripes on cards, tiny uppercase eyebrows.
- An eyebrow or tag slot that is filled on every item. A label that is always present
  carries no information. If you keep an eyebrow, it names the parent section.
- Cream page, serif display, terracotta accent; or near-black with one acid accent.

These are common defaults in generated designs. None of these is wrong in itself. Each is wrong when nobody decided it.

## Surface register

- **Brand surface** (marketing, landing, launch): the design is part of the offer.
  Expressive, generous space, one memorable signature. Motion can earn its place.
- **Product surface** (app, dashboard, settings): the design serves the work. Dense,
  quiet, predictable, fast. Boldness here is a defect.
- **Content surface** (docs, articles): reading is the job. Comfortable measure, clear
  heading levels, restraint.

## Hierarchy and layout

- The eye is pulled, strongest first, by size, weight, contrast, position (top left in
  left-to-right languages) and isolation. Space around an element outranks a box around it.
- Three text levels (display, body, meta) are usually enough.
- Everything aligns to something. A near-miss of a few pixels reads as broken.
- Proximity groups. Tight inside a group, loose between sections.
- Spacing from the scale only. Consistent vertical rhythm is most of what "looks designed"
  means.
- Front-load meaning. People scan headings and first words; the skim alone must carry the
  message.
- Mobile first: what survives the 375px column is the real hierarchy. The page body never
  scrolls sideways; wide tables and code scroll inside their own container.

## Distributing content

A page that holds everything buries the message.

- The home or landing page carries the one message, the primary action and a short
  pointer to each major area. Enough to orient and route.
- Depth lives on dedicated pages, one topic each.
- If a home-page section needs more than a short paragraph and a link, it probably wants
  its own page with a teaser.
- Every teaser links to its page; every page links back and across. Splitting content
  without links just hides it.

## States and microcopy

- Design the empty, loading, error, partial and success states, not only the full one.
- Every action gives visible feedback.
- Labels say the outcome, in the user's words. Never show an internal name (an enum value,
  a field key, a team's code word) to a reader.
- An action keeps one name through the flow: "Publish" produces "Published".

Hand the actual wording to `copywriter`.

## Render and verify

1. Build and open the real page, at 375px and at full width, in light and dark if both
   exist. Use a headless browser (for example Playwright) to take full-page screenshots.
   **A full-page screenshot misses content that reveals on scroll.** Sections that fade or
   slide in when scrolled into view are captured in their hidden state, so the image shows
   blank bands that real visitors never see (or hides a reveal that really is broken).
   Emulate reduced motion if the page honours it, or scroll through the page in steps and
   wait for animations before capturing. Then check reduced motion still shows everything.
2. Look at the screenshot against the intent. Then convert it to greyscale and check the
   hierarchy still holds.
3. Read the browser console. A broken layout often has an error that explains it.
4. Fix the cause, render again. Two or three passes is normal.
5. **Prove your change landed.** A style edit that did not match anything is a silent
   no-op. Toggle the change and confirm the pixels differ.
6. For a review of someone else's change, compare against a saved screenshot of the
   previous version and only report what changed.
7. Run an accessibility check on the rendered page. On an existing page, compare against
   a baseline so new issues are not lost among old ones.

**Check components across pages, not one page.** Open the same component on pages from
different sections (home, a marketing page, docs, the app, a legal page) side by side: header
and footer, link colour and underline, button styles, heading sizes, spacing. Sections built
at different times or from different templates drift apart, and docs or legal pages often
run on a different stylesheet. Report each difference with both locations.

A metric (a Lighthouse score, a contrast checker, a pixel diff) checks one property. It
cannot tell you the page is good. Render it and look.

Where possible, give reviewers a running preview they can click as well as screenshots.
Interaction, scroll and responsive behaviour do not show in a still.

## Critique output

Report findings ranked by impact, highest first. For each: what you saw, where, why it
matters against the intent, and the fix. Then apply the fixes you can make rather than
leaving a list, unless the critique is read-only (a review or audit with no licence to
change the page): then the ranked list with fixes is the deliverable. Separate taste ("I would prefer") from defects ("the primary action is
below the fold at 375px").

## Gotchas

- **Restyling a page whose problem is structure.** New colours on a confused page give a
  confused page in new colours.
- **Trusting a full-page screenshot of an animated page.** Scroll-triggered sections are
  captured hidden. Scroll through or turn motion off first.
- **A shared header or footer that each page sizes differently.** Shared parts must own
  their own width and spacing, or every page drifts.
- **Fixing a pattern with an exception list.** "Hide the border on these five selectors"
  breaks on the sixth. Key the rule on the state that causes it.
- **Designing at desktop width only.** The 375px view is where hierarchy decisions are
  forced; doing it last means redoing them.
- **Boldness on a product surface.** A hero animation that delights on a landing page is
  noise on a dashboard.
- **Calling it done from the code.** The build may not match what you imagine. Look.

## Verification

- [ ] Intent sentence written; a stranger can state the page's purpose within five seconds
      of seeing the render.
- [ ] Median test passed: the direction could not answer any similar brief.
- [ ] Exactly one primary action per view, and it is the most prominent thing.
- [ ] Hierarchy holds in greyscale.
- [ ] Alignment and spacing on the grid and scale; no near-misses.
- [ ] At most three text levels and two or three faces.
- [ ] Contrast passes AA on the rendered page (see `visual-design`).
- [ ] 375px width with no horizontal page scroll.
- [ ] Empty, loading and error states rendered and checked.
- [ ] Screenshots taken after the last change, and the change confirmed visible.
- [ ] Scroll-revealed content captured in its visible state (reduced motion or scrolled through).
- [ ] Shared components (header, footer, links, buttons) match across every section of the site.
