# Dark mode implementation

## Token remap

Only semantic tokens change. Primitives stay the same.

```css
:root {
  --color-bg: var(--grey-50);
  --color-surface: var(--white);
  --color-text: var(--grey-900);
}
@media (prefers-color-scheme: dark) {
  :root:not([data-theme="light"]) {
    --color-bg: var(--grey-950);
    --color-surface: var(--grey-900);
    --color-text: var(--grey-50);
  }
}
:root[data-theme="dark"] {
  --color-bg: var(--grey-950);
  --color-surface: var(--grey-900);
  --color-text: var(--grey-50);
}
```

The `:not([data-theme="light"])` guard lets a user who picked light keep it on a dark system.

## Choice and persistence

Three options: system, light, dark. Default to system.

```html
<script>
  // Inline in <head>, before stylesheets render, so the first paint is right.
  try {
    var t = localStorage.getItem('theme');
    if (t === 'light' || t === 'dark') document.documentElement.setAttribute('data-theme', t);
  } catch (e) {}
</script>
```

Wrap storage access in try/catch: private windows and blocked storage throw.

## Do not

- Use `filter: invert()` on the page. Colours shift and photos invert.
- Hard-code `white` or `black` in components.
- Override semantic tokens with `!important`. It breaks the remap.

## Images and media

- Photos: usually unchanged. Reduce brightness slightly only if they glare.
- Icons: SVG with `fill="currentColor"` or `stroke="currentColor"` so they follow text colour.
- Illustrations on a white ground: provide a dark variant, or use `<picture>` with a
  `prefers-color-scheme` source.
- Logos: supply a version that works on dark.

## Test matrix

- [ ] System dark respected with no stored choice.
- [ ] Stored choice overrides system in both directions.
- [ ] Choice survives reload and a new tab.
- [ ] No flash of the wrong theme on a hard reload.
- [ ] Every contrast pair passes AA in dark.
- [ ] Focus rings visible on dark surfaces.
- [ ] Page works when storage throws.
