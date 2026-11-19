# Component spec template

Copy, fill in every line, delete only what genuinely does not apply and say why.

```
Component:   [name]
Purpose:     [one line: the job it does for the user]
Not for:     [the nearby job it must not be used for, and the component to use instead]

Variants:    [e.g. primary | secondary | danger | quiet]
Sizes:       [e.g. sm | md | lg], with the use for each

States (tokens only):
  default:   bg --color-accent, text --color-text-on-accent, border none
  hover:     bg --color-accent-hover
  focus:     2px outline --color-focus-ring, offset 2px (visible on every surface)
  active:    bg --color-accent-pressed
  disabled:  bg --color-disabled, text --color-text-disabled, not focusable or announced as disabled
  loading:   spinner position and size; width does not change; repeat clicks blocked
  error:     [if it takes input]
  selected:  [if it toggles]

Spacing:     padding [space token] [space token]; min height 44px for touch
Typography:  [role token]
Radius:      [radius token]
Content:     max label length; behaviour when the label wraps or truncates
Behaviour:   keyboard keys; screen reader name, role and state
```

## State checklist

- Focus is visible on light and dark surfaces and in high-contrast mode.
- Hover is never the only way to reveal content or an action.
- Loading does not change the component's size (no layout shift).
- Disabled has a reason the user can discover (helper text or tooltip on a focusable wrapper).
- Long, short, empty and translated labels are all specified. German and Finnish strings are
  often 30% or more longer than English.
