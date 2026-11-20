---
name: security-audit
description: Use when asked to audit, pen-test, threat-model or security-review a codebase, a pull request or a design, or when deciding how severe a vulnerability is, including before a launch and after an incident. Covers STRIDE, OWASP and LLM-feature risks. Not for writing secure code as you go; use `security`.
license: MIT
---

# Security audit

This skill is the method for finding and reporting vulnerabilities in something that exists: a
codebase, a diff or a design. Secure defaults for code you are writing now live in the `security`
skill. An audit produces findings with evidence, not a feeling of safety.

## The rules that matter most

1. **Context before hunting.** Map the system before looking for bugs. Scanners and checklists find
   what they already know about. Design flaws (missing authorisation, broken trust boundaries) are only
   visible once you know what each part assumes.
2. **Every finding carries evidence.** A reproduction, a request and response, a failing test or a
   file and line with the exact path from input to sink. "Might be vulnerable" without a path is a lead,
   not a finding.
3. **A clean scan is a floor, not a verdict.** Zero CVEs from `npm audit` or `trivy` means no KNOWN
   vulnerable packages. It says nothing about access control, logic or injection in your own code.
4. **Prove a control positively.** "Is it not open?" scores a broken or down service as protected.
   Require the response that shows the control working (`401`, `403`, a rejected signature, a redirect
   to the identity provider) and treat everything else, including timeouts and `5xx`, as unproven.
5. **One bug means a pattern.** After confirming a finding, search the whole codebase for its variants
   before writing it up.
6. **Triage honestly.** A Medium reported as Critical destroys the report's credibility, and a wall of
   raw tool output buries the one finding that matters.

## When not to use

- Writing or changing code with security impact: use `security`.
- A quick pre-merge check on a small change with no new trust boundary: the `security` skill's
  verification list is enough.
- Infrastructure hardening of hosts and networks: use `infrastructure`, then come back here to audit it.

The `security` skill is written for code you are building. A review loads it only for its rules (what
correct looks like), not for its build steps.

## Method

Copy this checklist and tick it as you go.

```
- [ ] 1. Scope: what is in, what is out, what "done" means, which environment is safe to probe
- [ ] 2. Context: entry points, trust boundaries, data stores, identities, sensitive data flows
- [ ] 3. Harvest: output the tools already produce (compiler, linter, type checker, dependency audit)
- [ ] 4. Threat model: STRIDE per boundary-crossing data flow
- [ ] 5. Hunt: walk each threat and each high-risk area against the code
- [ ] 6. Confirm: reproduce each candidate, or record why it cannot be reproduced
- [ ] 7. Variants: search for the same pattern everywhere
- [ ] 8. Challenge: a separate pass that tries to disprove each finding
- [ ] 9. Triage and report
```

**1. Scope.** Agree the target and the boundaries before reading code. Never probe production or
third-party systems without explicit permission. Note what you will not cover, so the report cannot be
read as a clean bill for it.

**2. Build context.** Adapt depth to size. For a small service, read every handler. For a large one,
start at the entry points (routes, message consumers, CLI arguments, file parsers, scheduled jobs,
webhooks) and the most sensitive stores. For each security-relevant function, note three things:
what it assumes about its input, what it guarantees to its callers and what it depends on. Bugs live
where one function's assumption is not another's guarantee. Use `git log` and blame on suspicious code
to learn the intent: a check that was removed, or a comment that says "temporary", is a lead.

**3. Harvest what already reported it.** Before writing any probe, read the warnings the build already
prints. Classes that are never stylistic deserve a mechanical sweep: "comparison always true/false",
"will never be executed", unreachable code, unchecked return values, implicit any. A compiler that
already names a defect is stronger evidence than a grep you write after, because it was not shaped by
what you expected.

**4. Threat model with STRIDE.** For each data flow that crosses a trust boundary, ask:

| Threat | Question |
|---|---|
| Spoofing | Can someone act as another user or service? |
| Tampering | Can data be changed in transit, at rest or in the client? |
| Repudiation | Could an actor deny an action because nothing recorded it? |
| Information disclosure | Can data reach someone who should not see it, including via errors and logs? |
| Denial of service | Can one caller exhaust a shared resource (CPU, memory, connections, money)? |
| Elevation of privilege | Can a caller reach an action above their role? |

For a high-value asset, an attack tree helps: put the attacker's goal at the root and branch into the
ways to reach it, then mark which leaves the current controls block.

**5. Hunt.** Walk the threats against the code, then the high-risk areas:
- Access control on every route that takes an id: test as a second user and as another tenant.
- Injection: every place input reaches SQL, a shell, a path, a template, a URL fetch or a deserialiser.
- Authentication and sessions: token validation, reset flows, rate limits, session fixation.
- Secrets: history scan, CI config, logs, images (see "Secrets sweep" below).
- Dependencies and supply chain: lock files, unpinned actions and base images, build scripts.
- LLM features, if any: read `references/llm-features.md`.
- Capacity and budget: any shared quota, paid third-party call or daily cap that one caller can drain.
  Check what the limit is keyed on; see `references/checklists.md` (address rotation).
- Abuse cases, not only the happy path: wrong user, missing token, tampered payload, replayed request,
  malformed input, huge input, concurrent requests.

Read `references/checklists.md` for the OWASP category list, capacity and budget exhaustion,
security headers, supply-chain levels, zero-trust checks and where security gates sit in the delivery
lifecycle.

**6. Confirm.** Reproduce against a local or staging instance. If production is the only target, read
"When production is the only target" below first. Exercise the real request: a header in
config, a middleware in the router or a rule in a WAF proves nothing until you see it fire on the path
that matters. Route order and early returns bypass controls that read as present.

**7. Variants.** Turn the confirmed bug into a search: the same sink, the same missing check, the same
helper misused. Count the callers of the vulnerable function to size the blast radius. Report the
variants together, with the count.

**8. Challenge pass.** Re-read each finding as a sceptic, ideally as a separate agent that has not seen
your reasoning. Is the input really attacker-controlled? Is there a check upstream you missed? Is it
reachable in the deployed configuration? Drop or downgrade what does not survive. Merge duplicates.

**9. Triage and report.** See below.

## When production is the only target

With written permission and no staging copy, every probe must be harmless if the control it tests is
broken. Design the probe so that the failure case still does nothing.

- **Probe with input that cannot spend anything.** To test that a paid or rate-limited endpoint
  rejects a caller, send an empty or invalid body that the endpoint would refuse even with the
  control missing. The status and headers still show whether the control ran first.
- **Cross-origin checks with a no-op.** Send a foreign `Origin` with a body that changes nothing (an
  empty form, a read). The CORS headers or the rejection are the evidence; no state moves.
- **Budget paid operations.** If a probe must trigger a real paid call (an AI model, an SMS, an email),
  set the count before you start, keep it small and record each one.
- **Never volume test.** No load, no flood, no brute force against production. A denial of service
  that would need volume is reported as **PLAUSIBLE**, not confirmed, with the arithmetic: the limit
  per key, how many keys an attacker can get (see address rotation in `references/checklists.md`) and the cost per request,
  against the daily budget. For example, 20 requests per address per day, a /64 of IPv6 addresses
  each counted separately, against a shared cap of 1,000 calls a day: one attacker drains it.
- Note every probe you ran with its time, so the owner can match it in their logs.

## Secrets sweep

1. History: `gitleaks git .` (older gitleaks: `gitleaks detect --source .`) or
   `trufflehog git file://.` (a plain
   `git log -p | grep` misses encoded and split keys and drowns in noise).
   If neither tool is installed and you cannot install one, fall back to a regex sweep of the full
   history and state it in the report as partial:
   ```
   git log -p --all | grep -nE 'AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY|ghp_[A-Za-z0-9]{36}|sk_live_|xox[baprs]-|(api|secret|token|passw)[a-z_]*\s*[:=]'
   ```
   It finds well-known key shapes and obvious assignments only: it misses encoded, split and
   unfamiliar secrets.
2. `.env.example` documents every required secret with no real values.
3. CI config injects secrets from the platform's secret store, never as plaintext YAML, and they are not
   exposed to builds from forks.
4. Logs, error responses and analytics events contain no tokens, passwords or personal data.
5. Container images: inspect layers for copied `.env` files and build arguments that held secrets.

## Severity

Score with CVSS where a number is needed. Bands: Critical 9.0 to 10.0, High 7.0 to 8.9, Medium 4.0 to
6.9, Low 0.1 to 3.9. In words:
- **Critical:** remote code execution, or unauthenticated access to all data.
- **High:** authentication bypass, privilege escalation, significant data exposure.
- **Medium:** limited exposure, or needs user interaction or an unusual precondition.
- **Low:** minimal impact or heavy preconditions.

Default response times: Critical blocks the release and is fixed now. High within 7 days, Medium within
30, Low tracked. A longer time needs a written exception with an owner and a date.

## Report

One block per finding:

```markdown
### [ID] [Title naming the flaw and where]
- Severity: High (CVSS 8.1) | Confidence: confirmed / likely / suspected
- Location: path/to/file.ts:142 (and N variants, listed below)
- Path: [input source] -> [functions] -> [sink], one line each
- Evidence: [request and response, failing test or reproduction steps]
- Impact: [what an attacker gains, in one or two sentences]
- Fix: [the specific change, and the test that proves it]
```

Open with a short table of findings by severity, then scope and what was NOT covered. Close with the
systemic causes (for example "no shared authorisation helper") since they predict the next bugs.

## Gotchas

- **Auditing what is declared, not what runs.** A manifest can list a vulnerable package that is never
  loaded, or miss the version that actually resolves. Check the lock file and the runtime.
- **Config is not behaviour.** A CORS rule or auth decorator present in source can be skipped by route
  order. Send the request.
- **No threat model.** Jumping straight to tools finds known CVEs and misses insecure design, which no
  scanner sees.
- **Happy-path testing.** Confirming the authorised user can do the thing proves nothing about the
  attacker.
- **Direct dependencies only.** The vulnerable package is usually transitive. CI actions, base images and
  build tools are attack surface too.
- **Severity inflation and raw dumps.** Every finding "Critical", or 400 lines of scanner output, and the
  reader stops reading.
- **A detector that never fires.** A security check with zero hits across a large real data set may be
  unable to fire at all. Feed it the condition it detects and watch it trigger before counting it.

- **Rate limits keyed on one IPv6 address.** A single customer usually holds a /64 or more, so a
  per-address limit is no limit. Key on the /64 at least, and cap shared budgets globally.

## Rationalisations to reject

| Thought | Reality |
|---|---|
| "The scanner is clean, so we're fine." | Scanners do not see your access control or your logic. |
| "It's internal only." | Internal is one compromised laptop away from external. |
| "Exploiting that needs an authenticated user." | Most attackers are authenticated users. |
| "The framework escapes it." | Only in the context it knows. Check this sink. |
| "I couldn't exploit it, so it's not a bug." | Record it as suspected with the path. Someone else may. |
| "It's too small to report." | Small findings chain. Report it as Low. |
| "Only a load test would prove the DoS." | On production, report it PLAUSIBLE with the arithmetic. Do not flood it. |

## Verification

The audit is done when: every in-scope entry point is listed with its result; every finding has
evidence and survived the challenge pass; variants were searched and counted; the out-of-scope list is
written; and each fix comes with a test that fails on the vulnerable code and passes on the fixed code.
