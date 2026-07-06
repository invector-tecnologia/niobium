# Cell spec

- Parity: `buffer::Cell` · ADR: 0003, 0005, 0006 · Tests: tests/core/test_cell.nim

## Purpose
One grid position: a grapheme cluster plus its style and a `skip` flag for the trailing half of a
wide glyph.

## API surface
- `Cell = object` with symbol (SSO rune storage, ADR-0003), `fg`, `bg`, `underlineColor: Color`,
  `modifier: set[Modifier]`, `skip: bool`.
- `cell(sym: string, style = defaultStyle()): Cell`.
- `symbol(c): string` / `setSymbol(c, s)`.
- `reset(c)` — restore to blank (space, default style, `skip = false`) in place.
- `setStyle(c, s)` — overlay a `Style` (patch semantics, ADR-0005).
- `width(c): int` — display columns of the symbol (0/1/2).

## Behavior
1. A blank cell is a single space with default style and `skip = false`.
2. `setStyle` overlays only the style's set fields; unset fields are unchanged.
3. `setSymbol` with a width-2 grapheme does not itself set the neighbor's `skip`; the buffer writer
   does (see buffer spec).
4. `reset` performs no heap allocation.

## Acceptance criteria
- [ ] `setStyle` patch semantics verified.
- [ ] `width` correct for ASCII, CJK, combining, and ZWJ-emoji graphemes.
- [ ] `reset` allocation-free (covered by allocation-invariant test).
