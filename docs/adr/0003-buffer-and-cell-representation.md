# 0003. Buffer and Cell representation

- Status: accepted
- Date: 2026-07-06

## Context
A `Buffer` is a grid of `Cell`s re-touched every tick (e.g. 200×50 = 10k cells). ratatui stores the
symbol as `CompactString` (inline, no heap alloc for typical glyphs). A naive `symbol: string` per
cell would thrash ARC/ORC.

## Decision
- `Buffer` is a value `object` holding `area: Rect` and `content: seq[Cell]`, a flat array indexed
  `y * width + x`.
- `Cell` stores its grapheme via **small-string-optimized rune storage** (inline for the common
  short-grapheme case, spill only for long clusters) behind the `Cell` API, so the storage strategy
  can change without breaking callers.
- Buffers are reused and `swap`ped each tick; `reset` clears in place.

## Consequences
- Steady-state render allocates nothing (supports ADR-0010).
- The exact SSO type can be tuned later; measure with `test_alloc_invariant.nim`.

## Alternatives considered
- `symbol: string`: rejected — per-cell heap allocation, GC pressure.
- `array[4, char]`: rejected — cannot hold long ZWJ emoji clusters.
- Grapheme interning table + index: viable fallback if SSO proves insufficient; revisit if needed.
