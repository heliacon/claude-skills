---
name: api-design
description: Use when designing or changing an HTTP API contract, adding or editing a route, endpoint or webhook, writing an OpenAPI spec, choosing error, pagination or versioning shapes. Also when asking "is this a breaking change". Not for server internals such as jobs, retries or rate-limit storage; use `backend-patterns`.
license: MIT
---

# API design

The contract is the product. Clients you never meet will depend on every observable
behaviour of it, documented or not (Hyrum's Law). Design so that the contract can grow
by addition and never has to change underneath anyone.

## The rules that matter most

1. **Change by addition only.** New optional fields, new endpoints, new optional query
   parameters. Anything in the breaking column below needs a new major version.
2. **One error shape everywhere:** RFC 9457 problem details (`application/problem+json`).
   No ad-hoc `{"error": "..."}` bodies, ever: they cannot be typed or searched.
3. **Every list is bounded.** A server-side default and maximum page size, enforced in the
   query, not only in the docs.
4. **Explicit schemas in and out.** No `dict`, `Any`, `object` or "free-form JSON" in a
   response model. Input and output types are separate types.
5. **Handlers are thin.** Validate input, call one service function, serialise the result.
   No business logic and no direct database access in a route handler.
6. **The spec is checked by a machine.** The OpenAPI document is generated, committed and
   validated in CI. A route with no `operationId` or no response schema fails the build.

## Breaking or not

| Breaking (new major version) | Not breaking |
|---|---|
| Removing or renaming a field | Adding an optional response field |
| Changing a field's type, unit or format | Adding an endpoint |
| Making an optional input required | Adding an optional query parameter |
| Tightening validation on an existing input | Loosening validation |
| Changing default sort order or default page size | Changing human-readable `detail` text |
| Changing the auth scheme | Adding an enum value, **only if** clients were told to tolerate unknown values |
| Turning a sync response into a 202 + poll | Adding a new error `type` for a new failure |
| Changing which status code a known failure returns | |

Behaviour counts as contract. A default sort order, a field that was "always" present, a
timestamp precision: if a client can observe it, assume one depends on it.

## Versioning

- Version in the URL path: `/api/v1/...`. One default; header versioning is harder to test
  and to cache.
- A breaking change ships as `/api/v2/...` routes alongside v1. Never edit v1 in place.
- Announce retirement with the `Deprecation` header (RFC 9745) and the `Sunset` header
  (RFC 8594), plus `Link: <...>; rel="successor-version"`. Keep the old version for a stated
  period (six months is a sound default) and for longer if mobile clients cannot be forced
  to update.
- Prefer one live version plus one deprecated version. Many parallel versions rot.

## Errors

Problem details fields: `type` (stable URI per error class), `title` (stable per type),
`status` (equals the HTTP status), `detail` (this occurrence), `instance` (the request
path or an occurrence id). Add an `errors[]` extension for field-level validation, each
item with `field`, `message` and a machine `code`.

| Situation | Status |
|---|---|
| Body cannot be parsed, wrong content type | 400 |
| No credentials or bad credentials | 401 |
| Authenticated but not allowed | 403 |
| Not found, **or** exists but the caller may not know it exists | 404 |
| Conflicts with current state (duplicate, version mismatch, in-flight idempotent request) | 409 |
| Precondition failed (`If-Match` mismatch) | 412 |
| Parses, but values are invalid | 422 |
| Rate limited (always send `Retry-After`) | 429 |
| Unexpected server fault (generic `detail`, details go to the log) | 500 |
| An upstream dependency failed | 502 / 503 / 504 |

- Never return a stack trace, ORM message, SQL fragment or raw exception text. Log it with
  a request id and put that id in the problem body so support can find the log line.
- Clients branch on `type`, never on `detail` or `title` text.

## Pagination

- **Default: cursor (keyset) pagination.** Request `?after=<cursor>&limit=20`; response
  `{"items": [...], "next_cursor": "...", "has_more": true}`. The cursor is opaque
  (base64 of the sort key values plus a unique tiebreaker such as the id). The keyset query
  itself is in the `database` skill.
- **Offset pagination** only for admin screens over bounded tables that need "jump to page
  N". `page` 1-indexed, `page_size` default 50, maximum 200.
- `total` is expensive on large tables and wrong under concurrent writes. Leave it out of
  cursor responses unless a screen truly needs it.
- A changed sort order invalidates every cursor in the wild. Treat sort order as contract.

## Schemas and field formats

- **Separate input and output types.** A create or update body never accepts `id`,
  `owner_id`, `role`, `created_at`, `price` or any server-owned field (mass assignment).
  Identity comes from the authenticated session; amounts come from the server.
- **IDs are strings** in the contract, even if they are integers today. Consider a type
  prefix (`ord_...`) so a wrong id in the wrong field is obvious.
- **Datetimes:** RFC 3339 / ISO 8601 with an offset, in UTC (`2025-01-15T09:32:11Z`).
  **Calendar dates** with no time: `YYYY-MM-DD`. Never an ambiguous local time, never a
  bare epoch number without a documented unit.
- **Money:** integer minor units (`1599` with `"currency": "GBP"`) or a decimal string.
  Never a binary float: `0.1 + 0.2` is not `0.3`, and clients in other languages will round
  differently.
- **Enums:** document that unknown values may appear and must be handled. Without that
  sentence, adding a value is a breaking change.
- **Booleans in requests:** a bare `true`/`false` parameter often hides a third state.
  Prefer an enum (`"visibility": "private"`) when the meaning could grow.
- Every response field has a description; give an example where the format is not obvious.

## Sharp edges to design out

A good API makes the safe call the easy call.

- **Dangerous defaults.** A default that deletes, publishes, emails or charges. The default
  must be the harmless choice; the dangerous one is explicit.
- **Silent partial success.** A bulk endpoint that returns 200 while some items failed.
  Return per-item results, or fail the whole request.
- **Stringly typed control.** Permissions, filters or sort expressions passed as free text
  the server parses. Use enums and structured fields.
- **Configuration cliffs.** One flag that switches the endpoint to a different behaviour
  with different guarantees. Make it a different endpoint.
- **Ambiguous absence.** `null`, missing and empty string all meaning different things,
  undocumented. Pick one meaning per field and write it down. For PATCH, say whether `null`
  clears a field.

## Idempotency in the contract

- `GET`, `PUT` and `DELETE` must be idempotent by design. `DELETE` of an already deleted
  resource returns 204 or 404 consistently: choose and document.
- Any `POST` that creates, charges, sends or triggers an irreversible effect accepts an
  `Idempotency-Key` header. Same key, same payload: replay the stored response. Same key,
  different payload: 422. Same key still in flight: 409. The storage design is in the
  `backend-patterns` skill.
- Optimistic concurrency for updates to shared records: return an `ETag`, require
  `If-Match` on update, return 412 on mismatch.

## Handler shape

```python
@router.get("/orders", response_model=OrderPage, operation_id="list_orders",
            summary="List the caller's orders, newest first")
async def list_orders(after: str | None = None,
                      limit: int = Query(20, ge=1, le=100),
                      user: User = Depends(current_user)) -> OrderPage:
    return order_service.list_orders(user.id, after=after, limit=limit)
```

The same shape holds in Express, Hono, Vapor or Ktor: parse, delegate, serialise.

## OpenAPI

- `operationId` on every operation: unique, `verb_noun` (`list_orders`, `update_order_status`).
  Generated clients use it as the method name, so renaming it is a breaking change for them.
- `summary` in one plain sentence. Every error response documented with its problem type.
- Commit the generated spec (for example `docs/openapi.json`). In CI: regenerate, fail if
  any operation lacks an `operationId` or a success schema, and diff against the main branch
  spec with a breaking-change detector (oasdiff or similar). A breaking diff fails the build
  unless the change is in a new version.
- The committed spec is the contract for generated clients (Swift, Kotlin, TypeScript).
  Anything a client needs that is not in the spec (a custom header, multipart quirks) is a
  defect in the spec.

Read `references/openapi-fastapi.md` when generating or validating a spec with FastAPI or
Pydantic: it holds a working generator script and two framework traps.

## Gotchas

- **Testing the contract by reading the handler.** The handler is not the contract; the
  serialised response is. Assert on the JSON a client receives, including headers.
- **A count off a paged endpoint is the page size.** Summing `items` from one page and
  reporting it as a total is a frequent bug in clients and dashboards. Expose the number
  explicitly or say it is not available.
- **Validation tightened in a "fix".** Rejecting input that used to be accepted breaks
  clients. Treat it as breaking, or accept and normalise.
- **Renaming for tidiness.** A field renamed from `amount` to `total` is a removal plus an
  addition. Keep the old field until the version retires.
- **Sort without a tiebreaker.** `ORDER BY created_at` alone gives duplicate and missing
  rows across pages when timestamps collide. Always append the unique id.
- **404 vs 403 leaks existence.** For resources the caller may not know exist, return 404.

## Verification

Done means each item has evidence, not a statement:

- The spec regenerates cleanly and the CI check passes (show the command output).
- The breaking-change diff against the main branch is empty, or every breaking item lives
  under a new version.
- A contract test per endpoint covers success, validation failure (422 with `errors[]`),
  auth denied (401 and 403) and not found, asserting the problem `type`.
- A list endpoint called with `limit` above the maximum is clamped or rejected, never
  unbounded.
- A replayed `POST` with the same `Idempotency-Key` creates one resource, not two.
