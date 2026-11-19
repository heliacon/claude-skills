---
description: The tdd skill fires; the nearest sibling, quality-assurance, does not.
tags: [trigger]
runs: 2
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

Our paginate(items, page, size) helper in src/paginate.ts drops the last item on the final page. I want to fix it test-first. Walk me through exactly how you will do it.
