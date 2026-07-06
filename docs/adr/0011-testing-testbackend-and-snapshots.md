# 0011. Testing strategy: TestBackend and snapshots

- Status: accepted
- Date: 2026-07-06

## Context
Rendering must be verifiable deterministically, without a real TTY, and fidelity to ratatui must be
guarded against regression.

## Decision
- Provide a **`TestBackend`** that renders into an in-memory `Buffer` satisfying the `Backend`
  concept.
- Assert rendered output against **golden snapshots** in `tests/snapshots/` (one line per row; a
  companion style map when styles are under test).
- Test layout with **table-driven truth-tables** `(area, direction, constraints) -> rects`.
- Enforce the allocation invariant and **fuzz** the ANSI event parser.
- Tests use Nim `unittest`, aggregated in `tests/all_tests.nim`, run via `nimble test` under ORC.

## Consequences
- Fast, deterministic, CI-friendly verification; snapshots double as executable specs.
- Golden changes must be intentional and acknowledged.

## Alternatives considered
- Manual TTY testing: rejected — non-deterministic, not CI-able.
- Pixel/screenshot testing: rejected — overkill for a text grid.
