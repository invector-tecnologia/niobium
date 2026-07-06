# 0009. Error handling: Result vs exceptions

- Status: accepted
- Date: 2026-07-06

## Context
Terminal I/O, raw-mode toggling, and backend writes are fallible. Nim supports both exceptions and
`Result`-style values. The render path must stay allocation-free and predictable.

## Decision
- Fallible I/O and backend operations return a **`Result`-style** value (`Result[T, IoError]`).
- **Exceptions are raised only at the public API boundary**, where they are ergonomic, and are
  documented with `raises` pragmas.
- The hot render path does not raise; it propagates `Result`.

## Consequences
- Predictable, allocation-friendly control flow on the render path.
- Callers at the boundary get idiomatic exceptions; internals stay explicit.
- Requires a small `Result` type or the `results` package; keep the dependency surface minimal.

## Alternatives considered
- Exceptions everywhere: rejected — hidden control flow and allocation on the hot path.
- Error codes only: rejected — less ergonomic, easy to ignore.

Follow-up: confirm dependency choice (vendored `Result` vs `results` package) at implementation time.
