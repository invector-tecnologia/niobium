# Block spec

- Parity: `widgets::Block` · Tests: tests/test_widgets.nim
- Status: mirrored

## Purpose
Foundational container: optional borders, titles, and padding. Many widgets render inside a Block's
inner area.

## API surface
- `Block` with `borders: set[Side]` (Top/Right/Bottom/Left/All), `borderType` (Plain/Rounded/Double/
  Thick), `borderStyle: Style`, `titles: seq[Title]` (content + position + alignment), `padding`,
  `style` (fills the area).
- `inner(block, area): Rect` — area inside borders and padding.
- `render(block, area, buf)`.

## Behavior
1. Borders draw box-drawing glyphs per `borderType`; corners only where two sides meet.
2. Titles render on the top/bottom border with Left/Center/Right alignment, truncated to fit.
3. `inner` subtracts drawn borders and padding; with no borders it subtracts padding only.
4. `style` fills the whole area before borders/titles.

## Acceptance criteria
- [ ] Golden snapshots: each border type; partial border sets; titled borders; padding.
- [ ] `inner` correctness for all border/padding combinations.
