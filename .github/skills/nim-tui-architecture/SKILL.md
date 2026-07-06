---
name: nim-tui-architecture
description: "Use when working on Niobium's render path: Buffer, Cell, diffing, the terminal tick loop, or backend dispatch. Covers allocation-free steady state, buffer swapping, and the immediate/retained boundary. Triggers: buffer, diff, tick, render path, allocation, swap, double buffering."
---

# Niobium render-path architecture

## The tick (never reorder)
1. `Terminal.draw(render)` builds a `Frame` over `nextBuffer`.
2. Layout splits the `Rect`; widgets `render(area, nextBuffer)`.
3. Diff `nextBuffer` vs `currentBuffer` → minimal cell patches.
4. Encode patches (minimal cursor moves + coalesced SGR runs) → `Backend.draw`.
5. `Backend.flush`; reconcile cursor; `swap(current, next)`; reset `next` in place.

## Allocation-free rules
- Buffers are sized once to the terminal area and reused. Per-frame reallocation is a bug.
- No `string` building or `seq` growth in diff/encode. Pre-size, index, reuse scratch buffers.
- Verify with `tests/test_alloc_invariant.nim` (0 `getOccupiedMem` delta across ticks).

## Immediate vs retained
- Widgets are immediate: reconstructed each tick, no retained render state.
- The cell buffer is retained: it is the diff baseline. Do not remove or bypass it.

## Backend boundary
Output bytes only in `src/niobium/backend/`. Core describes *what* changed via `BufferPatch`.
