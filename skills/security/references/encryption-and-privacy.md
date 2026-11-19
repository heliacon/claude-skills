# Encryption at rest, sync and privacy

Read before designing encryption for stored data, backups or sync, or before writing a privacy
policy. The key discipline below applies to any product. The storage, sync and privacy sections use
one worked example (a local-first app with no account); a hosted service makes different storage
choices but keeps the same rules for keys.

## Contents
- Key discipline (any product)
- Example: a local-first app with no account
- Privacy stance
- PRIVACY.md template

## Key discipline (any product)

- **Envelope encryption.** Encrypt data with a random data key using AES-256-GCM or
  ChaCha20-Poly1305. Wrap the data key with a key-encryption key, held in a KMS for a hosted service
  or derived from a passphrase on a device. Rotating or changing the outer key then only re-wraps the
  data key instead of re-encrypting everything.
- **Passphrase-derived keys:** Argon2id with a random 16-byte salt. OWASP's minimum is 19 MiB memory,
  2 iterations, parallelism 1. Raise memory if the unlock time allows.
- Store the salt beside the data (it is not secret) but never the passphrase or a derived key.
- Keys live in memory or in the platform's key store (KMS, Keychain, Android Keystore). Never in an env
  var, config file, log or the same backup as the data.
- No default and no empty passphrase.
- If there is no recovery path, say so plainly: a forgotten passphrase means the data is unrecoverable
  without a backup and its passphrase. Do not add a hidden recovery path: it is a back door.
- **Backups:** encrypt each archive with an AEAD mode and its own salt or wrapped key. Keep salt,
  nonce and ciphertext together in one self-contained file, with no separate key file to lose.
- **Test restore.** An encrypted backup that has never been decrypted is not known to be a backup.

## Example: a local-first app with no account

An app that keeps the user's data on their own device might choose:

- **Storage:** with SQLite, SQLCipher for whole-file encryption, keyed from the user's passphrase when
  the app unlocks. Otherwise envelope encryption as above.
- **Sync, staged by risk:**
  1. A local network API bound to the LAN interface only, never `0.0.0.0` on a laptop that joins public
     Wi-Fi. Put auth middleware in place from the first version, even if it starts permissive, so
     turning it on is a config change.
  2. An encrypted file export with the user's passphrase, so the transport (email, USB, a cloud drive)
     need not be trusted.
  3. Remote sync, end-to-end encrypted. The server stores opaque blobs and never sees a key. Sync
     encrypted deltas, not whole-database copies. A fully compromised sync server then learns only
     sizes and timing.

Each stage is a separate decision with its own threat model. Adopt the later stages only when the
product needs them.

## Privacy stance

Decide the product's stance, write it in `README.md` under "Privacy" and in `PRIVACY.md`, and enforce
it in review. A strict stance, for products that choose one, looks like this:
- Store only what the user enters. Collect nothing automatically.
- No analytics, telemetry or crash reporting, or only with explicit opt-in.
- No account or identity required where the product can work without one.
- External services (for example an AI feature) receive the minimum the feature needs, never raw
  records or identifiers.
- Any sync server stores only encrypted blobs.

Whatever the stance, keep the written claims true. A privacy claim that the code does not honour is a
liability, not a feature.

## PRIVACY.md template

```markdown
# Privacy

## What data does [Product] collect?
[Exactly what, and whether anything is collected automatically.]

## Where is it stored?
[Where: on your device, or with [provider] in [region]. Whether it is encrypted at rest.]

## Is it shared with anyone?
[No.] / [Only [feature] uses [service], which receives [exactly what].]

## Is there telemetry, analytics or crash reporting?
[No.] / [Yes: [what], [opt-in or opt-out], [how to turn it off].]

## How long is it kept, and how do I delete it?
[Retention period and the deletion route.]
```
