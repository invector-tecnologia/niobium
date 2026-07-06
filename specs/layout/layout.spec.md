# Layout spec

- Parity: `layout::{Layout,Constraint,Direction}` · ADR: 0004 · Tests: tests/layout/test_layout.nim

## Purpose
Split a `Rect` into sub-rects by constraints along a direction. The only way widgets obtain areas.

## API surface
- `Direction = enum { Horizontal, Vertical }`.
- `Constraint` variant: `Length(n)`, `Percentage(p)`, `Ratio(num,den)`, `Min(n)`, `Max(n)`,
  `Fill(weight)`.
- `split(area, dir, constraints; spacing = 0, margin = 0): seq[Rect]`.
- Convenience: `length(n)`, `pct(p)`, `ratio(a,b)`, `min(n)`, `max(n)`, `fill(w)`.

## Behavior
1. The number of output rects equals the number of constraints.
2. Along `dir`, fixed intents (`Length`, `Percentage`, `Ratio`) are honored first; `Min`/`Max` clamp;
   `Fill` splits leftover space proportional to weight.
3. Output rects are contiguous, non-overlapping, and their extents sum exactly to the available
   extent (after `spacing`/`margin`) — deterministic remainder distribution (start → end).
4. The cross-axis extent equals the parent's (minus margin).
5. Zero available space yields zero-width/height rects at correct offsets, never negative.
6. Identical inputs hit the thread-local layout cache (observable only via performance, not results).

## Acceptance criteria
- [ ] Truth-tables: pure Length; Percentage rounding; Ratio; Min/Max clamping; Fill weighting;
      mixed constraints; spacing and margin; zero/So-small areas.
- [ ] Sum-to-parent invariant holds for every row.
