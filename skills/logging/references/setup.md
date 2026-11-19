# Logger setup by language

Read this when configuring logging in a new component.

## Contents

- Python: text to a rotating file (local tools)
- Python: JSON to stdout (services)
- Redaction filter
- Go: slog
- Rust: tracing
- Swift: os.Logger

## Python: text to a rotating file (local tools)

Call `configure_logging()` first in the entry point, before importing modules that log at
import time. Single process only (see the gotcha on rotation).

```python
import logging, os
from logging.handlers import RotatingFileHandler

FMT = "[%(asctime)s] [%(levelname)s] [%(name)s] %(message)s"
DATEFMT = "%Y-%m-%d %H:%M:%S"

def configure_logging(path: str = "logs/app.log") -> None:
    level = logging.DEBUG if os.getenv("LOG_LEVEL") == "DEBUG" else logging.INFO
    os.makedirs(os.path.dirname(path), exist_ok=True)

    file_handler = RotatingFileHandler(path, maxBytes=10 * 1024 * 1024, backupCount=5)
    handlers = [file_handler]
    if os.getenv("APP_ENV", "development") == "development":
        handlers.append(logging.StreamHandler())     # console in development only

    root = logging.getLogger()
    root.setLevel(level)
    for h in handlers:
        h.setFormatter(logging.Formatter(FMT, DATEFMT))
        h.addFilter(RedactFilter())
        root.addHandler(h)
```

Name loggers by component: `logging.getLogger("PARSER")`.

## Python: JSON to stdout (services)

Prefer a maintained structured logger (`structlog`, or `python-json-logger` on the standard
library). The shape with the standard library alone:

```python
import json, logging, sys, time

class JsonFormatter(logging.Formatter):
    RESERVED = set(vars(logging.makeLogRecord({})))
    def format(self, r: logging.LogRecord) -> str:
        out = {
            "ts": time.strftime("%Y-%m-%dT%H:%M:%S", time.gmtime(r.created))
                  + f".{int(r.msecs):03d}Z",
            "level": r.levelname, "logger": r.name, "msg": r.getMessage(),
        }
        out.update({k: v for k, v in vars(r).items() if k not in self.RESERVED})
        if r.exc_info:
            out["exc"] = self.formatException(r.exc_info)
        return json.dumps(out, default=str)

handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())
handler.addFilter(RedactFilter())
logging.basicConfig(level=logging.INFO, handlers=[handler])

log = logging.getLogger("orders")
log.error("Payment charge failed", extra={"order_id": oid, "attempt": 2}, exc_info=True)
```

Add `trace_id` and `span_id` with the OpenTelemetry logging instrumentation, or a filter that
reads them from the current span.

## Redaction filter

```python
import logging, re

PATTERNS = [
    (re.compile(r"(?i)(authorization|password|secret|token|api[_-]?key)(\W+)\S+"), r"\1\2[REDACTED]"),
    (re.compile(r"\b\d{12,19}\b"), "[CARD?]"),
    (re.compile(r"[\w.+-]+@[\w-]+\.[\w.]+"), "[EMAIL]"),
]

class RedactFilter(logging.Filter):
    def filter(self, record: logging.LogRecord) -> bool:
        msg = record.getMessage()
        for pat, repl in PATTERNS:
            msg = pat.sub(repl, msg)
        record.msg, record.args = msg, ()
        return True
```

A regex filter is a safety net, not a policy. The policy is to log ids, not data. Test the
filter with planted values.

## Go: slog

```go
logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
slog.SetDefault(logger)

reqLog := logger.With("trace_id", traceID, "route", "/orders")
reqLog.Error("payment charge failed", "order_id", orderID, "attempt", 2, "err", err)
```

- `logger.With(...)` for request-scoped fields; pass the logger in the context.
- Implement `slog.LogValuer` on types that hold secrets so they log as redacted.

## Rust: tracing

```rust
use tracing::{error, info, instrument};

#[instrument(skip(db), fields(order_id = %order_id))]
async fn process_order(db: &Pool, order_id: &str) -> Result<()> {
    info!("processing order");
    if let Err(e) = charge(db, order_id).await {
        error!(error = %e, attempt = 2, "payment charge failed");
    }
    Ok(())
}
```

- `tracing` gives structured events and spans; `tracing-subscriber` with the JSON formatter
  for services, the pretty formatter for local use.
- `#[instrument]` records arguments by default. `skip` anything large or sensitive.

## Swift: os.Logger

```swift
import os
let log = Logger(subsystem: "com.example.app", category: "networking")
log.info("Request completed: \(route, privacy: .public) in \(ms) ms")
log.error("Payment failed for order \(orderID, privacy: .public): \(error.localizedDescription, privacy: .private)")
```

- Interpolated strings are private by default in release logs; mark only non-sensitive values
  `.public`.
- Read with Console.app or `log stream --predicate 'subsystem == "com.example.app"'`.
