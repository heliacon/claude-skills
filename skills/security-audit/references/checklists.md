# Audit checklists

Read during the hunt and report stages of an audit. Each section is a checklist to walk, not prose to
repeat in a report.

## Contents
- OWASP Top 10 categories
- Security headers (web)
- Supply chain (SLSA)
- Zero-trust checks
- Security gates in the delivery lifecycle

## OWASP Top 10 categories

Refer to categories by name in reports. The numbering changes between editions (the 2025 edition
reorders the list, adds software supply chain failures and mishandling of exceptional conditions, and
folds server-side request forgery into broken access control).

- **Broken access control.** Every route enforces object-level authorisation, not only login. Includes
  IDOR, path traversal, CORS misuse and SSRF.
- **Security misconfiguration.** Default credentials, debug modes, verbose errors, open storage buckets,
  missing headers, unnecessary services.
- **Software supply chain failures / vulnerable components.** Known-vulnerable or unmaintained
  dependencies, unpinned CI actions and base images, compromised build steps.
- **Cryptographic failures.** Sensitive data unencrypted in transit or at rest, weak algorithms, fast
  password hashes, hard-coded keys, nonce reuse.
- **Injection.** SQL, NoSQL, OS command, LDAP, template and header injection. XSS belongs here.
- **Insecure design.** Missing controls that no implementation fix can add: no rate limit on a costly
  operation, a reset flow that trusts the client, business-logic abuse.
- **Authentication failures.** Credential stuffing, weak reset, missing MFA option, session fixation,
  tokens that never expire.
- **Software or data integrity failures.** Unsigned updates, unsafe deserialisation, CI that runs
  untrusted code with secrets.
- **Security logging and alerting failures.** Security events not logged, logs that hold secrets, no alert on
  repeated failures.
- **Mishandling of exceptional conditions.** Errors that fail open, partial transactions, exceptions
  that leak state.

## Security headers (web)

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
Content-Security-Policy: [a policy for this app; avoid 'unsafe-inline' for scripts]
X-Content-Type-Options: nosniff
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: [disable features the app does not use]
X-Frame-Options: DENY    (or CSP frame-ancestors 'none', which supersedes it)
```

Check headers on the deployed response, including error pages and static assets, not in config.

## Supply chain (SLSA)

SLSA stands for Supply-chain Levels for Software Artifacts. SLSA (v1.0 and later) defines a Build track
(later versions keep it unchanged and add a Source track):
- **Build L1:** provenance exists that says how the artefact was built.
- **Build L2:** builds run on a hosted build platform that signs the provenance.
- **Build L3:** the build platform is hardened so builds cannot influence each other or fake
  provenance.

Default target for production artefacts: Build L2. Practical checks:
- [ ] Release builds run in CI, never on a developer laptop.
- [ ] Main branch is protected and changes arrive by reviewed pull request.
- [ ] Provenance is generated and signed (for example GitHub's build-provenance attestation).
- [ ] Dependencies are locked, and pinned by hash where the ecosystem supports it.
- [ ] Base images are pinned by digest. CI actions are pinned by commit SHA.
- [ ] An SBOM is produced per build (syft or a CycloneDX tool).

## Zero-trust checks

- [ ] Every service-to-service call is authenticated (mTLS or a signed token), not trusted by network
      location.
- [ ] Service identities hold only the permissions their job needs.
- [ ] Networks are segmented so one compromised service cannot reach all others.
- [ ] Credentials are short-lived. No permanent keys where a rotating alternative exists.
- [ ] Internal services are unreachable by default, with an explicit allow-list per caller.
- [ ] Access, allowed and denied, is logged with enough context to reconstruct an incident.

## Security gates in the delivery lifecycle

| Stage | Gate |
|---|---|
| Requirements | Identify sensitive data and the flows that carry it. |
| Design | STRIDE per component. Record auth decisions as an architecture decision record. |
| Coding | Static analysis (semgrep, bandit, language linters). No secrets in code. |
| Pull request | Security items in the PR template. Independent review for auth, tenancy and data changes. |
| CI | Dependency audit, static analysis, secret scan, container scan, all blocking at High. |
| Staging | Dynamic scan (OWASP ZAP or similar) against the running app. |
| Before release | Manual test of new auth flows and anything that widens data exposure. |
| Production | Alerting on auth anomalies. Review WAF rules if one is used. |
| After an incident | Record the root cause where the team keeps lessons, and add a check that would have caught it. |
