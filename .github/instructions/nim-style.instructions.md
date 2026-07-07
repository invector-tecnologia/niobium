---
applyTo: "**/*.nim"
description: "Nim coding conventions for TaTUÍ: naming, style, memory model, error handling."
---

# Nim style — TaTUÍ

## Formatting & naming
- 2-space indentation, 100-column lines, formatted with `nph`.
- Types: `PascalCase`. Procs/vars/fields: `camelCase`. Enums: `PascalCase` values with a short prefix
  (e.g. `ckLength`, `ckPercentage` for `ConstraintKind`).
- Prefer explicit exports (`*`) only for the intended public API.

## Memory model
- Target `--mm:orc`. Never call `alloc`/`dealloc` or use `--mm:refc`.
- Prefer value types (`object`) and `seq`-backed flat arrays over `ref object` in the render path.
- In the hot path (buffer write, diff, dispatch) do not allocate: reuse buffers and `swap` them.

## Error handling
- Fallible I/O returns a `Result`-style value (see `docs/adr/0009-error-handling.md`).
- Raise exceptions only at the public API boundary, and document them with a `raises` pragma.
- Terminal state (raw mode, alt screen, mouse capture) must always be restored via `defer` or a
  destructor, even on exception/panic.

## Documentation
- Every exported symbol has a doc comment (`##`).
- Rendering/computing procs include a `runnableExamples` block; these are compiled by `nimble docs`.

## Prohibited
- Writing to stdout/stderr or emitting escape sequences outside `src/tatui/backend/`.
- Hidden global mutable state; pass `Buffer`/`Frame`/state explicitly.
