---
name: docs
description: "Use when writing, reviewing or fixing technical documentation: README, ADR, API docs, architecture overview, changelog, runbook, contributor guide, CLAUDE.md, or when docs may have drifted from the code. Not for marketing copy (use `copywriter`) or product specs (use `requirements`)."
license: MIT
---

# Technical documentation

## Rules that matter most

1. **Run every command and open every link before publishing.** A README command that fails costs the reader more than no README. Untested examples are the commonest doc defect.
2. **Document what exists, marked by status.** Each feature is working, partial, planned or broken. Aspirational features written as current are the second commonest defect.
3. **One fact, one place.** Every other mention links to it. A count, version or port written in three files will disagree within a month.
4. **Current beats comprehensive.** Delete what is wrong before adding what is new. A short accurate doc beats a long stale one.
5. **Test the doc on a reader with no context.** Give it to a fresh subagent with only the doc and ask it to do the task or answer the reader's likely questions. Where it guesses or fails, the doc has a gap.
6. **Follow the project's existing conventions first.** If there are ADRs, a docs folder layout or a changelog format already, match them. Only introduce a scheme when none exists, and never add a second one beside the first.

## When not to use

- Landing pages, product copy, release announcements for customers: the `copywriter` and `marketing` skills.
- Specs and user stories: the `requirements` skill.
- Session plans and hand-off files: the `workflow` skill.

## Start with the reader

Before writing, answer in one line each: who reads this, what they are trying to do and how much time they have. Then list the questions that reader will arrive with. The doc is done when it answers them in the order they arise.

Pick the kind of doc and keep to it. Mixing kinds is why docs feel long:

| Kind | Reader wants | Shape |
|---|---|---|
| Tutorial | To learn by doing, once | One path, every step works, no options |
| How-to | To finish a task now | Numbered steps, prerequisites, the result to expect |
| Reference | To look up a fact | Tables, signatures, every option, no narrative |
| Explanation | To understand why | Prose, trade-offs, history, links to ADRs |

## Levels of depth

- **Overview (1 page)**: what it is in two sentences, the problem it solves, what makes it different, current status. Someone with no context understands it in a minute.
- **Architecture and features (a few pages)**: feature table with status, component and data-flow diagrams, the API surface, known issues.
- **Deep dive (per topic)**: implementation, design decisions (link the ADRs), code paths, failure modes, test commands. Assumes the codebase is open.

Same facts, different depth. The deeper level links up; it does not restate.

## Writing standards

- Lead with the answer, then the reasoning.
- One idea per paragraph. Active voice: "Run the migration", not "The migration should be run".
- Be specific: "add three lines to `config.py`", not "make some changes".
- Code blocks always name the language. Commands are copy-pasteable as written, with the expected output shown where it matters.
- Tables for anything structured: options, status, comparisons, endpoints.
- Bold a key term at first use only. Do not bold for emphasis.
- Relative links for internal docs, full URLs for external ones. "See X" always carries the link.
- Date claims that will go stale: "as of <month year>".
- No marketing words in technical docs: powerful, seamless, cutting-edge, robust, effortless.
- State known issues plainly, with severity and the workaround.
- Labels and captions say what happens for the reader, never an internal enum, flag or code name. Grep the built output for internal names before publishing.
- One unit per number, and the unit stated with the number. "7 of 120 services" not "7 services, 120 have one".

## Making docs usable by tools and models

- Consistent status vocabulary in tables (`working | partial | planned | broken`).
- Exact file paths and function names where a reader will need to find them.
- Example requests and responses as valid JSON, parsed before publishing.
- Dependencies with exact versions.
- Agent-facing files (`CLAUDE.md`, rules files): put the step the agent must take in the file, put reference material behind a link with "read X when Y" and state what done looks like.

## Specific doc types

Read `references/doc-types.md` before writing an ADR, changelog, runbook or README from scratch. It has a skeleton and the rules for each.

## Drift: keeping docs true

Docs drift because code changes and nobody re-reads them. Check for drift whenever a feature ships, a public API changes or a version is bumped:

- Grep the docs for every name the change renamed or removed.
- Recount every count the docs quote (endpoints, tests, ADRs, supported versions) against the files.
- Run the README quick start from a clean checkout.
- Compare the feature table's status column against what the code and tests show.

Where possible make drift fail a check: a test that runs the README commands, a link checker in CI, a script that counts ADRs and compares the number quoted. A rule that needs someone to remember it will be forgotten.

## Reviewing for machine-sounding prose

When asked to remove an "AI-written" feel, look for: stock openers and closers, groups of three by reflex, hedges stacked on hedges, vague intensifiers, headings that announce instead of inform. Treat a hit as a quality signal and fix the sentence. It is never proof of who wrote it; detectors and heuristics flag human writing too.

## Gotchas

- **The README that describes the roadmap.** Readers try the planned feature, fail and stop trusting the rest.
- **"See the docs" with no link.** Every cross-reference is a link.
- **TODO left in a published doc.** Write the section or remove it.
- **A diagram that no longer matches the code.** Check it against the code, not against memory.
- **Counts quoted in prose.** "12 endpoints" goes stale the day number 13 lands. Link to the generated list or recount on every release.
- **A new ADR format beside the old one.** Look for the existing convention (an ADR folder, a numbering scheme, a template) first.
- **ADRs for everything.** Record decisions that are costly to reverse or that someone will ask "why" about. Routine choices clutter the record until nobody reads it.

## Verification

Before committing documentation:

- [ ] Every command was run and works as written; output shown where it matters
- [ ] Every link resolves
- [ ] Versions, counts and status match the code, checked against the files, not assumed
- [ ] Known issues stated with severity and workaround
- [ ] Structured sections use one consistent vocabulary
- [ ] A fresh subagent given only the doc could do the reader's task, or its failures were fixed
