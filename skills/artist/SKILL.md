---
name: artist
description: Use when making or directing visual assets such as illustrations, hero images, icons, logos, brand marks, textures or diagrams, or writing prompts for an image-generation model. Covers art direction, reference boards and critique against a brief. Not for page layout; use `designer`. Not for palettes and tokens; use `visual-design`.
license: MIT
---

# Artist

Making the images a design needs, and making them belong to it. The `designer` skill
decides where an image goes and what job it does. The `visual-design` skill owns the
palette and type the images must agree with. This skill directs the asset: the brief, the
references, the tool, the prompts, the critique and the delivery.

## The rules that matter most

1. **Write the brief before generating anything.** Job, medium, palette, light, mood,
   composition, what it must not look like. A prompt with no brief behind it produces the
   model's average image.
2. **Choose the tool for the job first.** Generate, draw in a vector tool, render from
   code, or use a photograph. An image model is the wrong tool for exact geometry and text.
3. **References set the ground, palette and light, not a texture to paste.** Read what a
   reference shows (its colour range, its light direction, its contrast, its density) and
   write those down as brief values. Copying a surface pattern from it misses the point.
4. **Critique every output against the written brief**, item by item, not against how
   impressive it looks. A striking image that breaks the brief is a reject.
5. **Keep an iteration log.** Prompt, settings, seed, output file, verdict, and what to
   change next. Without it you cannot reproduce the good one or explain the bad one.
6. **The person who owns the brand gives the art direction.** Propose options and name the
   trade-offs. Do not invent a house style and present it as settled.

## When not to use

- Deciding page layout, image placement or crop on a page: `designer`.
- Choosing brand colours, type or tokens: `visual-design`.
- Charts and data graphics: the `frontend` skill's `references/charts.md`. Their colours encode
  data.
- Purely decorative code art (generative patterns in a canvas): treat it as code, with its
  own render and look loop.

## Choose the tool

| Asset | Default tool | Why |
|---|---|---|
| Mood, hero, spot illustration, texture | Image-generation model | Fast exploration of look and light |
| Icon set, logo, wordmark | Vector tool, explored first with the image model | Needs exact geometry, a shared grid and clean scaling |
| Diagram | Rendered from code or a diagram tool | Needs exact labels and editable structure |
| Real people, real products, real places | Photography | Generated images of real things mislead |
| Text inside an image | Set it in HTML or a vector tool | Image models garble letterforms |

Prefer a generated, drawn or photographed image for illustration. Hand-written SVG or ASCII
art rarely matches their quality next to them. Keep hand-written SVG for geometry (icons on a
grid, diagrams, charts).

## The brief

```
Job:          what the asset must do (set a mood, explain a structure, mark a brand)
Where:        placement, size and crop on the page; what sits on top of it
Medium:       photographic | illustrative | abstract | diagrammatic
Palette:      2 to 4 values taken from the system's tokens, with proportions
Light:        direction, quality (hard or soft), time of day, contrast range
Mood:         three words, and three words it must not be
References:   2 to 5 images, each with what to take from it
Composition:  focal point, negative space for text, aspect ratio
Avoid:        the look it would drift to by default
Done when:    the checks it must pass (see Critique)
```

### Reference boards

- Collect 2 to 5 references. For each, write the one thing to take ("the low, warm side
  light", "the large flat shapes with no outline").
- Extract measurable values: dominant colours (sample them), light direction, value range
  (how dark the darks, how bright the lights), density of detail.
- A reference that shows a quality you cannot name is not yet useful. Name it or drop it.

## Prompting an image model

- **Order:** subject, style, composition, palette, light, finish. Specific nouns beat
  adjectives. "A brass pressure gauge on a workbench" beats "a beautiful industrial scene".
- **Composition for use.** If text sits on top, ask for a calm, low-detail region in the
  right place ("plain dark upper third"). For icons, ask for a centred subject on a flat
  ground.
- **One variable at a time.** Fix the seed and change one clause, so you know what each
  change did. Change the seed only to explore.
- **Sets share a style clause.** Write the style clause once and reuse it verbatim; vary only
  the subject. If the model supports a reference image or style input, use the same one for
  every item.
- **Generate several, choose a direction, then refine.** The first batch is for choosing,
  not for shipping.
- **Avoid asking for:** readable text, exact logos, hands holding small objects precisely,
  tables, pixel-exact alignment, counts of objects above about five. Do those in code or a
  vector tool and composite.
- Check the model's licence and terms for commercial use before the asset ships.

## Iconography

- One grid, one stroke weight, one corner radius across the set. A set on a shared grid
  reads as a system; a mixed set reads as clip art.
- One clear metaphor per icon. If it needs a caption to be understood, change the metaphor.
- Balance optically, not mathematically. A circle must be slightly larger than a square to
  look the same size.
- Test at the size it ships at, on light and dark.

## Brand marks

- Simple enough to draw from memory.
- Works in one colour, and in pure black and white, before any gradient.
- Test at 16px (favicon) and at hero size. If it fails at either end, it is not the mark.

## Diagrams

- One idea per diagram. Two ideas, two diagrams.
- The shape carries the argument: a fan for one-to-many, a line for sequence, convergence
  for aggregation. Remove the labels and ask whether the shape still says something. If not,
  the layout is arbitrary.
- Use the real names (real endpoints, real event names, real fields), never
  "Input, Process, Output".
- One visual language: the same shape always means the same kind of thing; colour means
  something or is not used.
- Render, look, fix: check for clipped text, overlaps, crossed arrows and uneven spacing.
  Two to four passes is normal.

## Critique

Score each output against the brief, line by line:

- [ ] Palette within the brief's values (sample the image, do not eyeball).
- [ ] Light direction and contrast range match the references.
- [ ] Composition leaves the space the layout needs, at the real crop and size.
- [ ] In a set: grid, weight and style match its siblings when placed side by side.
- [ ] Legible at the size it will ship at.
- [ ] No artefacts: extra fingers, melted text, broken symmetry, seams in tiles.
- [ ] Earns its place. If removing it loses nothing, remove it.

A measure (a palette distance, a sharpness score) checks one property and can reward the
wrong thing. Place the asset in the real page and look.

## Delivery

- Format: photographs and rich illustration as AVIF or WebP with a JPEG fallback; flat
  art and icons as SVG; PNG only when transparency and raster are both needed.
- Export at the sizes used (1x and 2x), and compress to the smallest file that still looks
  right.
- Write alt text that says what the image communicates in context. Decorative images get
  an empty `alt=""`.
- Record the source of each asset (prompt and seed, or file, or photographer and licence).

## Gotchas

- **"Not like that" is not a direction.** When feedback says what the image must not be,
  ask or propose what it should be before regenerating. Several different targets satisfy
  the same "not".
- **Prompting harder to fix a wrong tool.** Ten attempts at a crisp logo from an image model
  is a sign to switch to a vector tool, not to add adjectives.
- **A filter is not a mark.** Asked for visible brush strokes or layered paint, a smooth
  image with a texture overlay is not the same thing. Each stroke is a placed object.
- **Faking a real object from primitives.** A real shape traced or referenced from its
  source beats a plausible approximation made of circles and noise.
- **A set made one image at a time with a new prompt each time.** It will not match. Fix
  the style clause and the reference first.
- **Judging the asset alone.** An image that looks good full-screen can fail at the 320px
  crop behind a headline. Judge it in place.

## Verification

- [ ] Written brief exists and every delivered asset maps to it.
- [ ] Iteration log records prompt, settings, seed and verdict for the chosen output.
- [ ] Critique checklist passed with the asset placed in the real page, both themes.
- [ ] Exported at shipping sizes and formats; file sizes noted.
- [ ] Alt text written; source and licence recorded.
