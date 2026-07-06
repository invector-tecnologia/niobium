# Paragraph spec

- Parity: `widgets::Paragraph` · Tests: tests/widgets/test_paragraph.nim

## Purpose
Render `Text` with optional wrapping, alignment, and vertical scroll, optionally inside a Block.

## API surface
- `Paragraph` with `text: Text`, `block: Option[Block]`, `wrap: Option[Wrap]` (trim flag),
  `alignment`, `scroll: (x, y)`, `style`.
- `render(p, area, buf)`.

## Behavior
1. With no wrap, long lines are truncated to the width; with wrap, lines break on width honoring the
   `trim` flag for leading whitespace.
2. `alignment` (Left/Center/Right) positions each visual line within the width.
3. `scroll.y` skips leading visual lines; `scroll.x` shifts horizontally.
4. When a Block is set, text renders in the Block's inner area.
5. Wide graphemes never split at the wrap/truncate boundary.

## Acceptance criteria
- [ ] Goldens: no-wrap truncation; wrap with/without trim; each alignment; vertical scroll; inside a
      Block; CJK wrapping.
