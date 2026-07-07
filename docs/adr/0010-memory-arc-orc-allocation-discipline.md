# 0010. Memory management: ARC/ORC and allocation discipline

- Status: accepted
- Date: 2026-07-06

## Context
TaTUÍ targets high-frequency redraws. GC pauses or per-frame allocation would cause jank and defeat
the diffing optimization.

## Decision
- Build with **`--mm:orc`** only. No `--mm:refc`, no manual `alloc`/`dealloc`.
- The render path (`draw` → diff → dispatch) performs **zero heap allocations** in steady state:
  buffers are sized once, reused, and `swap`ped; scratch buffers are preallocated.
- This is enforced as a testable invariant.

## Consequences
- Smooth, predictable redraws; minimal GC involvement on the hot path.
- Prefer value types and `seq`-backed flat arrays over `ref` in hot code.
- Introduces `tests/test_alloc_invariant.nim` (asserts `getOccupiedMem()` delta == 0 across ticks).

## Alternatives considered
- `--mm:refc`: rejected — reference-counting cycles and pauses, not the project default.
- Manual memory management: rejected — unsafe, non-idiomatic, unnecessary under ORC.
