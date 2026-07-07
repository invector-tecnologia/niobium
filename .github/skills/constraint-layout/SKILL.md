---
name: constraint-layout
description: "Use when implementing or testing TaTUÍ's layout engine: Constraint, Rect splitting, the solver, spacing/margins, or the layout cache. Covers constraint semantics, integer rounding, and cache keying. Triggers: layout, constraint, split, rect, flex, percentage, ratio, fill, solver."
---

# Constraint-based layout

## Constraint kinds (ADR-0004)
`Length(n)`, `Percentage(p)`, `Ratio(num, den)`, `Min(n)`, `Max(n)`, `Fill(weight)`.

## Semantics
- A layout splits a `Rect` along a `Direction` (Horizontal/Vertical) into segments.
- Fixed intents (`Length`, `Percentage`, `Ratio`) are honored first; `Min`/`Max` clamp; `Fill`
  distributes leftover space proportional to weight.
- All arithmetic is on integer cells. Distribute rounding remainder deterministically
  (left-to-right / top-to-bottom) so totals equal the parent extent — no lost or overlapping cells.

## Solver strategy
- v1: greedy solver behind the final `Constraint` API.
- Later: linear (kasuari-style) solver, swappable without changing callers.

## Caching
- Solving repeats every frame; cache solved results in a thread-local LRU keyed by
  `(area, direction, constraints, spacing, margin)`.

## Testing
Table-driven truth-tables: `(area, direction, constraints) -> expected rects`. Cover Min/Max/Ratio/
Fill interactions and rounding edges.
