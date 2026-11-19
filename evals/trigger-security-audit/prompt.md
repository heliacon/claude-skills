---
description: The security-audit skill fires; the nearest sibling, security, does not.
tags: [trigger]
runs: 2
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

Before launch, threat model our new file upload service: it accepts user files, stores them in S3 and generates thumbnails.
