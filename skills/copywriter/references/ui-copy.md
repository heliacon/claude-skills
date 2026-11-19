# Interface copy patterns

Contents

- Buttons and links
- Errors
- Empty states
- Confirmations and destructive actions
- Success and notifications
- Forms
- Onboarding
- Translation

## Buttons and links

- Verb plus object, naming the outcome: "Save draft", "Send invoice", "Export CSV".
- The label predicts what happens next. If the click opens a form, it says so ("Add payment
  method"), not the final result.
- Sentence case. No full stop.
- Link text makes sense out of context. Never "click here" or "read more" alone.

## Errors

Formula: what happened, why (only if it helps), what to do now.

| Weak | Better |
|---|---|
| Invalid input | Enter a date in the format DD/MM/YYYY |
| Something went wrong | We could not save your changes. Check your connection and try again. |
| Unauthorised | You do not have access to this project. Ask its owner to invite you. |

- Do not blame ("You entered an invalid...") and do not apologise at length.
- Put the message next to the field it concerns. Keep the user's input.
- For a blocking error, say who can help and how to reach them.

## Empty states

- Say what will appear here and how to make it appear: one line plus the action.
  "No invoices yet. Create your first invoice to see it here." with a "Create invoice" button.
- Distinguish first-use empty (an invitation), no-results empty (suggest a change to the
  search or filter) and cleared empty (a short confirmation that the work is done).

## Confirmations and destructive actions

- Name the object and the consequence: "Delete 'March report'? This cannot be undone."
- The confirming button repeats the verb: "Delete report", not "OK" or "Yes".
- Prefer undo to a confirmation dialog when the action is reversible.

## Success and notifications

- Past tense of the same verb: "Invoice sent". Add the next useful step if there is one
  ("View invoice").
- Do not celebrate routine actions.

## Forms

- Labels above fields, always visible. Placeholder text is not a label.
- Helper text says the format before the user gets it wrong.
- Mark the optional fields, not the required ones, when most are required.

## Onboarding

- One instruction per screen. Lead with what the user gets, then the step.
- Let the user skip, and tell them where to find the guidance later.

## Translation

- Leave room: many languages run 30% or more longer than English; short labels can double.
- Never build a sentence by joining fragments ("You have " + n + " items"). Use full strings
  with placeholders and plural rules.
- Avoid idioms, puns and culture-specific references in interface text.
- Keep dates, numbers and currency in the locale's format, produced by code, not typed into
  the copy.
