# Rect spec

- Parity: `layout::Rect` · ADR: — · Tests: tests/core/test_rect.nim

## Purpose
An axis-aligned rectangle of terminal cells: the unit of area passed to layout and widgets. Pure
value type, no rendering.

## API surface
- `Rect = object { x, y, width, height: uint16 }`
- `rect(x, y, w, h): Rect`
- `area(r): int` — `width * height`.
- `left/right/top/bottom(r)` — edge coordinates (right/bottom exclusive).
- `intersection(a, b): Rect` — overlapping region (zero-sized if disjoint).
- `union(a, b): Rect` — bounding box.
- `inner(r, margin): Rect` — shrink by margin on all sides, clamped to zero.
- `contains(r, x, y): bool`.

## Behavior
1. `right = x + width`, `bottom = y + height` (exclusive edges).
2. `intersection` of disjoint rects has `width == 0 or height == 0`.
3. `inner` never produces negative dimensions; over-large margins yield a zero-area rect at the
   center-clamped origin.
4. All arithmetic saturates within `uint16`; no overflow/underflow.

## Acceptance criteria
- [ ] Truth-table for intersection/union/inner across overlapping, disjoint, and contained pairs.
- [ ] Clamping edge cases (margin ≥ half extent).
