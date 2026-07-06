---
name: nim-testing
description: "Use when writing or updating Niobium tests: TestBackend usage, golden snapshot format, layout truth-tables, the allocation invariant test, or ANSI parser fuzzing. Triggers: test, snapshot, golden, TestBackend, unittest, truth-table, allocation test, fuzz."
---

# Testing Niobium

## Harness
- Nim `unittest`; every suite is imported by `tests/all_tests.nim` (run via `nimble test`).
- `TestBackend` renders into an in-memory `Buffer` — assert on cells/rows without a real TTY.

## Golden snapshots
- Store expected renders in `tests/snapshots/<name>.txt`: one line per buffer row.
- When styles matter, add `<name>.style.txt` mapping cells to a style legend.
- Update goldens deliberately; call out the change in the PR/description.

## Layout truth-tables
```
check split(area, Vertical, @[length(3), fill(1)]) == @[rect(...), rect(...)]
```
Cover Min/Max/Ratio/Fill interactions and integer-rounding boundaries.

## Allocation invariant
`test_alloc_invariant.nim`: run N steady-state ticks, assert `getOccupiedMem()` delta == 0.

## Fuzz smoke
`fuzz/ansi_parser_smoke.nim`: feed random/truncated escape byte streams; assert no crash and total
consumption of input.
