# OpenAPI with FastAPI and Pydantic

Read this when generating, validating or publishing an OpenAPI spec from a FastAPI app.

## Generator and CI check

Run in CI. It exits 1 if any operation lacks an `operationId` or a success response schema,
otherwise writes the spec.

```python
# scripts/generate_openapi.py
import json, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:          # runnable directly, no PYTHONPATH needed
    sys.path.insert(0, str(ROOT))

from app.main import app  # noqa: E402

schema = app.openapi()
errors = []
for path, methods in schema.get("paths", {}).items():
    for method, op in methods.items():
        if method not in ("get", "post", "put", "patch", "delete"):
            continue
        if "operationId" not in op:
            errors.append(f"missing operationId: {method.upper()} {path}")
        ok = {c: r for c, r in op.get("responses", {}).items() if c.startswith("2")}
        if not any(r.get("content") or c == "204" for c, r in ok.items()):
            errors.append(f"missing success schema: {method.upper()} {path}")

if errors:
    print("\n".join(errors))
    sys.exit(1)

out = ROOT / "docs" / "openapi.json"
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(schema, indent=2, sort_keys=True) + "\n")
print(f"openapi.json written: {len(schema.get('paths', {}))} paths")
```

`sort_keys=True` keeps the committed file stable so diffs show real changes only.

## Trap 1: inspect the generated JSON, not `app.routes`

FastAPI can rewrite operation metadata while it builds the schema. Checks that read route
objects can pass while the published document is wrong. Validate `app.openapi()["paths"]`:
the JSON is what clients receive.

## Trap 2: a response field named after a reserved word

To emit a JSON key such as `global` from a Python attribute, all three parts are needed. Any
one missing and the key silently comes out as the Python name.

```python
class FeatureFlagOut(BaseModel):
    model_config = {"populate_by_name": True}
    global_enabled: bool = Field(serialization_alias="global")

@router.get("/flags", response_model=FeatureFlagOut,
            response_model_by_alias=True, operation_id="get_flags")
```

## Field descriptions

```python
class OrderOut(BaseModel):
    id: str = Field(..., description="Order id", examples=["ord_8f2k1"])
    placed_at: datetime = Field(..., description="When the order was placed, UTC")
    total_minor: int = Field(..., description="Total in minor units of `currency`",
                             examples=[1599])
    currency: str = Field(..., description="ISO 4217 code", examples=["GBP"])
```

## Problem details handler

```python
@app.exception_handler(DomainValidationError)
async def on_validation(request: Request, exc: DomainValidationError) -> JSONResponse:
    return JSONResponse(
        status_code=422,
        media_type="application/problem+json",
        content={
            "type": "https://example.com/problems/validation-failed",
            "title": "Validation failed",
            "status": 422,
            "detail": exc.public_message,   # never str(exc) of an arbitrary exception
            "instance": request.url.path,
            "errors": exc.field_errors,
        },
    )
```

Also register a catch-all handler for `Exception` that logs the full error with the request
id and returns a generic 500 problem body containing that id.

## Client generation

Document in the repo how a client is generated from the committed spec, for example with
`swift-openapi-generator` or `openapi-generator`. List anything the generator cannot express
(multipart uploads, a custom auth header) next to the command, then fix the spec so the list
shrinks over time.
