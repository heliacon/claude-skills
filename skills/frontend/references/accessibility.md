# Accessibility review

A method for checking a built page against WCAG 2.2 AA. Automated tools find perhaps a third of real
problems. The rest needs a keyboard, a narrow window and judgement.

## Contents
1. Order of work
2. Reflow and zoom
3. Keyboard path
4. Focus visibility
5. Scroll regions
6. Target size
7. Motion
8. Names, landmarks and skip links
9. Reading tool output
10. Reporting

## 1. Order of work

Do these on every page in scope, not on the home page only. Templates differ, and the page nobody
reviewed is where the defect lives.

1. Reflow at 320 CSS px.
2. Keyboard pass from the address bar to the footer.
3. Automated audit (axe, Lighthouse or the project's tool).
4. Sort the tool output into real findings and false positives (section 9).
5. Spot checks: target size, motion, names of repeated controls.

## 2. Reflow and zoom

- Set the viewport to 320 CSS px wide (this equals 1280 px at 400% zoom). The page body must not
  scroll sideways. Content may not be clipped or overlap.
- Exempt: content that needs two dimensions to make sense (data tables, maps, diagrams, code). It may
  scroll inside its own container, never the whole page.
- Check text resized to 200% with browser text zoom, not only page zoom. Fixed heights on text
  containers clip here.
- Measure it. In a headless browser compare `document.documentElement.scrollWidth` with
  `clientWidth`; a difference is horizontal page scroll. Then find the widest element.

## 3. Keyboard path

- Put the mouse away. Tab from the first stop to the last, then Shift+Tab back.
- Every interactive element is reached, can be operated (Enter for links and buttons, Space for
  buttons and checkboxes, arrows inside composite widgets) and does what a click does.
- **Tab order matches visual order.** Write down the order you reach things and compare it with the
  reading order on screen. CSS `order`, `flex-direction: row-reverse`, grid placement and absolute
  positioning move the picture without moving the DOM. A positive `tabindex` is almost always a bug.
- Nothing hidden takes focus. An off-canvas menu or a closed accordion whose links are still in the
  tab order sends the user into content they cannot see. Use `hidden`, `inert` or `display: none`.
- No trap: focus can always leave a widget. A modal holds focus while open, and Escape closes it.

## 4. Focus visibility

- Each stop shows a visible indicator, with at least 3:1 contrast against what is next to it.
- A focused element is not fully hidden by a sticky header, cookie banner or chat launcher (WCAG
  2.4.11). Tab down a long page and watch for focus going under the header. `scroll-padding-top` on
  the scroll container fixes most cases.
- `outline: none` with no `:focus-visible` replacement is a fail.

## 5. Scroll regions

A container with `overflow: auto` or `scroll` must be reachable by keyboard, or its content cannot be
scrolled without a mouse. Some browsers now make such containers focusable by default; others do
not, so do not rely on it. Give the container `tabindex="0"`, `role="region"` and an accessible name
(`aria-label` or `aria-labelledby`), unless it already holds a focusable element that brings it into
view. Typical cases: wide tables, code blocks, horizontal card rows.

## 6. Target size

WCAG 2.5.8 (AA) asks for pointer targets of at least 24 by 24 CSS px. A smaller target still passes
under the **spacing exception**: draw a 24 px circle centred on each undersized target. If no circle
overlaps another target or another target's circle, it passes. Other exceptions: links inside a
sentence, a control the browser draws unstyled, an equivalent control elsewhere on the page that meets
the size and a size that is essential to the information.

Measure with `getBoundingClientRect()` on the rendered page, at phone width. Common failures: icon
buttons in a header, close buttons on banners, pagination numbers, social icons set close together.
Platform guidance for native touch apps is larger (44 pt on iOS, 48 dp on Android); use that as the
design target and 24 px as the conformance floor.

## 7. Motion

- Turn on reduced motion (the operating system setting, or emulate `prefers-reduced-motion: reduce`
  in the browser). Parallax, auto-scrolling, large slides and scroll-linked animation should stop or
  become a fade. Content must still appear: an element that only becomes visible when its animation
  runs can stay invisible for good.
- Anything that moves, blinks or scrolls by itself for more than five seconds has a pause or stop
  control.
- Nothing flashes more than three times a second.

## 8. Names, landmarks and skip links

- **Skip link.** The first Tab stop on a page with repeated navigation is a "Skip to content" link
  that becomes visible on focus and moves focus to the main region. Press Enter on it and confirm the
  next Tab lands inside the main content, not back in the header.
- **Landmarks.** One `main`, a `nav` for each navigation block (named when there is more than one),
  `header` and `footer`. One `h1`, and heading levels that do not skip.
- **Repeated controls need distinct names.** Five "Read more" links or ten "Copy" buttons all sound
  the same in a screen reader's list of links. Add context to the accessible name ("Copy install
  command", or visually hidden text naming the item). The visible label must still be contained in
  the accessible name so voice users can say what they see.
- Images: informative ones describe their meaning; decorative ones have `alt=""`.
- Form fields: a programmatic label, errors tied with `aria-describedby`, required state exposed.

## 9. Reading tool output

Tools report what they measure, at the moment they measure it. Before you report a tool's finding,
check that it is not one of these:

- **Contrast measured mid-animation.** A fade-in or reveal-on-scroll element caught at partial
  opacity reports a low ratio that the settled page does not have. Re-run with reduced motion on, or
  after animations finish, and measure the final colours.
- **Disabled controls.** Text in an inactive control is exempt from the contrast rules. Confirm the
  control really is disabled (`disabled` or `aria-disabled="true"`), not only grey.
- **Text over an image or gradient.** Tools often cannot compute the background and either guess or
  flag it as needing review. Sample the worst point by hand.
- **Logos and incidental text** (decorative, or part of a picture) are exempt.
- **Hidden content.** Some tools audit elements that are not rendered. Check it can actually appear.

Also look for the opposite: issues the tool cannot see. Tab order, focus hidden under a sticky
header, meaningful alt text and names of repeated controls all pass an automated scan while broken.

## 10. Reporting

Per finding: the page URL, the element (a selector or a short description), the WCAG success
criterion, what happens, how you checked it (tool, keyboard, measured size) and the fix. State which
pages were covered. Say which findings came from a tool and which you confirmed by hand, and list the
tool results you rejected as false positives with the reason.
