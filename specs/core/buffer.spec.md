# Buffer spec

- Parity: `buffer::Buffer` · ADR: 0001, 0003, 0010 · Tests: tests/core/test_buffer.nim

## Purpose
A retained 2-D grid of `Cell`s. It is the diff baseline that makes double buffering possible.

## API surface
- `Buffer = object { area: Rect, content: seq[Cell] }` — flat, indexed `y*width + x`.
- `newBuffer(area): Buffer` / `emptyBuffer(area)`.
- `index(b, x, y): int`, `get(b, x, y): Cell`, `[]=` to set.
- `setString(b, x, y, s, style)` — write text, advancing by grapheme width and marking `skip`.
- `reset(b)` — blank all cells in place (no realloc).
- `resize(b, area)` — grow/shrink backing storage (allocation allowed here, not in steady state).
- `diff(old, new): seq[BufferPatch]` — minimal changed cells, in draw order, honoring `skip`.

## Behavior
1. Out-of-area coordinates are rejected/clamped (documented), never a memory error.
2. `setString` writing a width-2 grapheme sets the following cell `skip = true` and clears any stale
   half; truncation never splits a wide grapheme.
3. `diff` emits a patch only for cells whose symbol/style changed; `skip` cells are never emitted
   independently.
4. `diff` and `reset` allocate nothing once buffers are sized (ADR-0010).
5. Two buffers of equal area can be `swap`ped in O(1).

## Acceptance criteria
- [ ] Golden: `setString` with ASCII, CJK, emoji; verify `skip` placement.
- [ ] Diff minimality: single-cell change yields exactly one patch.
- [ ] Allocation invariant across repeated reset/diff.
