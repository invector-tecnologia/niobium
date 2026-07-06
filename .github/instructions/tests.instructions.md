---
applyTo: "tests/**"
description: "Testing conventions for Niobium: TestBackend, golden snapshots, layout truth-tables."
---

# Testing — Niobium

## Structure
- Tests use Nim's `unittest` module and are aggregated in `tests/all_tests.nim`.
- Deterministic rendering assertions use `TestBackend`, which renders into an in-memory `Buffer`
  instead of a real TTY.

## Golden snapshots
- Rendered output is asserted against golden files in `tests/snapshots/`.
- A snapshot is a plain-text render of a `Buffer`: one line per row, with a companion style map when
  styles are under test.
- Changing a golden file must be intentional; note it in the change description.

## Layout truth-tables
- Layout tests are table-driven: `(area, direction, constraints) -> expected rects`.
- Cover interactions of `Min`/`Max`/`Ratio`/`Fill` and integer rounding on the cell grid.

## Allocation & fuzz
- `test_alloc_invariant.nim` asserts `getOccupiedMem()` delta == 0 across steady-state ticks.
- `fuzz/ansi_parser_smoke.nim` feeds random/malformed byte streams to the event parser and asserts
  it never crashes.
