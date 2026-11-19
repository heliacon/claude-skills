---
description: The testing-strategy skill fires; the nearest sibling, tdd, does not.
tags: [trigger]
runs: 2
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

Our test suite has 1,400 tests and is always green, yet bugs keep reaching production. Work out whether our tests can actually fail and what we are not testing.
