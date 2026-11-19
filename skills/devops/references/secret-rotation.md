# Secret rotation

Read when rotating a secret on a schedule, after someone with access leaves or after a suspected leak.

## Schedule

| Secret | Rotate | How |
|---|---|---|
| Third-party API keys | Quarterly | New key, update the secrets manager, redeploy, revoke the old key |
| Database passwords | Quarterly | Dual-secret rotation (below) |
| Token signing keys | Yearly, or on compromise | Publish the new key, sign with it, keep verifying the old one until its tokens expire |
| TLS certificates | Before expiry, automatically | cert-manager or an ACME client, with an expiry alert as backup |
| Infrastructure credentials | When anyone with access leaves | Immediately |

Automate wherever the provider supports it. Prefer short-lived credentials issued on demand (cloud
workload identity, OIDC from CI) over long-lived keys that need rotating at all.

## Dual-secret rotation (no downtime)

1. Create the new secret and store it alongside the old one.
2. Deploy code that accepts both.
3. Switch all writers and clients to the new secret.
4. Confirm from logs or metrics that the old secret is no longer used.
5. Revoke the old secret.
6. Remove the dual-accept code.

Skipping step 4 is how rotations cause outages: some forgotten job still held the old value.

## After a suspected compromise

- Revoke at once. Do not wait for a window, and accept the outage risk.
- Search the provider's access logs for use of the secret since it could first have leaked.
- If data may have been read, tell the security owner and follow your breach-notification duties.
- Find how it leaked and add a check for that path (see the `security` skill's repository hygiene notes
  if it was committed).
