---
description: The ci-cd skill fires; the nearest sibling, devops, does not.
tags: [trigger]
runs: 2
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

Our GitHub Actions workflow takes 25 minutes, runs on pull_request_target and has secrets in it. Harden it and speed it up.
