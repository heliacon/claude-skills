---
name: visual-design
description: Use when building or changing a design system, such as design tokens, colour palette, contrast, typefaces, type scale, spacing scale, dark mode, motion tokens or component state specs. Not for laying out or critiquing a specific page or redesign; use `designer`. Not for making images; use `artist`.
license: MIT
---

# Visual design

The system underneath every screen: tokens for colour, type, space, shape, depth and
motion, and the component specs built from them. The `designer` skill applies this system
to real pages. Build the system once; let pages spend it.

## The rules that matter most

1. **Write the design direction in words before any token.** Three or four sentences: who
   it is for, what it should feel like, what it must never feel like, and the one thing it
   borrows from the subject matter. Every token decision is checked against that paragraph.
2. **Components reference semantic tokens, never primitives.** `--color-text-primary`, not
   `--grey-900`. Dark mode, theming and rebrands then become a remap, not a rewrite.
3. **Check contrast for every real pair, in both themes**, against the table below. A
   palette that passes on white can fail on its own tinted surface.
4. **A default is not a decision.** Framework greys, Inter on everything, a 4px radius on
   every box: each looks fine and together they look like every other product. Decide each
   value or knowingly accept it.
5. **Every component spec lists every state**: default, hover, focus, active, disabled,
   loading, error, and selected where it applies. Missing states get invented in the build,
   inconsistently.
6. **Fewer values, used consistently.** A scale with 6 steps used everywhere beats one
   with 14 steps used at random.

## When not to use

- Arranging a specific page, choosing what goes above the fold, critiquing a screen or
  running a redesign: `designer`.
- Generating illustrations, icons, hero images or brand marks: `artist`.
- Charts and data visualisation palettes: the `frontend` skill's `references/charts.md`.
  Categorical chart colours have constraints a brand palette does not.
- Implementing the tokens in a framework: `frontend`.

## Build order

Each layer depends on the one before:

1. Direction paragraph.
2. Colour: primitives, then semantic tokens.
3. Type: faces, then scale and roles.
4. Spacing scale and grid.
5. Radius, border and elevation.
6. Motion tokens.
7. Component tokens and component specs.

## Colour

Structure:

```
Primitives (raw values, one ramp per hue, e.g. 50, 100 ... 900, 950):
  --blue-600: oklch(0.55 0.17 255)

Semantic tokens (reference primitives, named by job):
  --color-bg, --color-surface, --color-surface-raised
  --color-text, --color-text-muted, --color-text-on-accent
  --color-accent, --color-accent-hover
  --color-border, --color-focus-ring
  --color-danger, --color-success, --color-warning (each with a text-safe variant)
```

Rules that separate a considered palette from a default one:

- **Build ramps in OKLCH.** Lightness stays perceptually even across hues, so a 600 blue and
  a 600 green carry the same visual weight. HSL lightness lies.
- **Tint the neutrals.** Pure grey and pure black or white look unowned. Add a small amount
  of chroma (about 0.005 to 0.015) towards the brand hue.
- **Text on a coloured surface** uses a dark shade of that surface's hue, not neutral grey.
  Grey on colour looks washed out.
- **Choose a commitment level and hold it**: restrained (neutral ground, one accent),
  committed (brand hue present throughout), full palette, or drenched (brand hue is the
  ground). A half commitment reads as indecision.
- **Never let colour carry meaning alone.** Pair it with an icon, a label or a pattern.
- **Watch the current reflexes.** A warm cream page with a serif display and a terracotta
  accent, or near-black with one acid accent, are what generated designs reach for when
  nothing was decided. Use them only when the direction paragraph asks for them.

### Contrast (WCAG 2.2)

| Pair | AA | AAA |
|---|---|---|
| Body text (below large size) | 4.5:1 | 7:1 |
| Large text: 24px regular, or about 18.7px bold, and up | 3:1 | 4.5:1 |
| UI component boundaries, icons, focus indicators, chart marks that carry meaning | 3:1 | none |

- Placeholder text that tells the user anything is text: 4.5:1.
- Disabled controls are exempt, but a user still has to see that a control is there.
- Measure computed colours, including opacity and overlays. A 60% opacity label on a tinted
  card is a new colour.

## Typography

- **Choose faces for the content's register**, not by habit. Three roles: a display face
  with character, used sparingly; a comfortable body face; a utility face for labels,
  captions and data (tabular figures for numbers in tables).
- **Pair on a clear contrast** (serif with sans, geometric with humanist) or use one family
  across weights. Two faces that are similar but not the same read as a mistake.
- **Modular scale.** Pick one ratio: 1.2 for dense product UI, 1.25 to 1.333 for content
  and marketing. Name roles, not sizes: `display`, `h1` to `h4`, `body-lg`, `body`,
  `body-sm`, `label`, `caption`.
- **Measure** 60 to 75 characters for body text (`max-width: 70ch`).
- **Display type** gets tighter tracking (around `-0.02em` to `-0.04em`) and a size ceiling
  (about 6rem via `clamp()`). Bigger rarely reads as intentional.
- `text-wrap: balance` on headings, `text-wrap: pretty` on body prose.
- Line height: about 1.5 for body, 1.1 to 1.25 for display.

## Space, shape, depth

- **Spacing scale** on a 4 or 8 base: for example 4, 8, 12, 16, 24, 32, 48, 64. Components
  use tokens, never raw pixel values.
- **Radius**: two or three values with a rule for which applies where. Nested radii: the
  inner radius equals the outer radius minus the padding between them.
- **Elevation**: three or four levels, each tied to a job (resting card, dropdown, modal).
  In dark themes, raise elevation with a lighter surface, not a heavier shadow.

## Motion

- Tokens: durations (for example 120ms, 200ms, 320ms) and two or three easing curves
  (one for entering, a sharper one for exiting). Elements reuse them; nobody picks a
  per-element value.
- Motion explains a change: where something came from, what responded. Motion that only
  decorates looks generated.
- One choreographed moment beats everything fading in at once.
- Honour `prefers-reduced-motion: reduce`: remove movement and long transitions, keep
  opacity changes.
- Do not scale photos on hover. Animate the container (shadow, border, background).

## Dark mode

- A dark theme is a remap of semantic tokens, never an inversion. Use dark greys for the
  ground, not pure black, and lower the chroma of accents that glow.
- Re-check every contrast pair in the dark theme.
- Prevent the flash of the wrong theme: decide the theme in a small inline script in the
  document head, before the first paint.

Read `references/dark-mode.md` when implementing theme switching, persistence or images in
dark mode.

## Component specs

Read `references/component-spec.md` before writing a component spec. It holds the template
and the state checklist.

## Gotchas

- **11 shades named 100 to 900.** That is 9 steps. Name ramps so the count and the names
  agree (50, 100 ... 900, 950 gives 11).
- **"Large text" means 18 point, not 18 pixels.** 18px regular body text needs 4.5:1, not
  3:1. The large-text threshold is 24px regular or about 18.7px bold.
- **Primitive tokens in components.** Works until the first theme. Then every component
  needs editing.
- **Contrast checked on the mock, not the build.** Opacity, overlays and anti-aliasing
  change the real colour. Measure the rendered pixels or computed styles.
- **One global adjustment to fix a local problem.** Darkening the whole palette to rescue
  one failing pair shifts every other pair. Fix the pair's token.
- **A token nobody uses, or a raw value nobody tokenised.** Both mean the system and the
  build have drifted. Grep the build for raw hex and pixel values.
- **A new font loaded for one heading.** Each face costs load time. Use the faces the
  system already loads.

## Verification

- [ ] Direction paragraph written, and each token family can be traced to it.
- [ ] Every text and UI pair passes AA in light and dark, measured on the built page.
- [ ] Components use semantic tokens only: grep shows no raw colour or spacing values in
      component code.
- [ ] Every component spec lists all its states.
- [ ] Reduced-motion setting tested: no movement remains.
- [ ] Theme switch shows no flash on a hard reload with the opposite system setting.
