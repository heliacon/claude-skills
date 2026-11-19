---
description: The database skill fires; the nearest sibling, backend-patterns, does not.
tags: [trigger]
runs: 2
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

I need to rename a column on a 200 million row Postgres table that serves live traffic, with zero downtime. Plan the migration.
