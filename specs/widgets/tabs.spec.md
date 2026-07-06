# Tabs spec

- Parity: `widgets::Tabs` · Tests: tests/test_widgets.nim
- Status: mirrored

## Purpose
A single-line horizontal tab bar with a selected tab.

## API surface
- `Tabs` with `titles: seq[string]`, `selected: int`, `blk`, `style`, `highlightStyle`,
    `divider: string`.
- `tabs(titles, selected = 0, highlightStyle = defaultStyle(), divider = " | ", blk = none(Block))`
    constructor.
- `render(tabs, area, buf)`.

## Behavior
1. Titles render left-to-right separated by `divider`.
2. The `selected` title uses `highlightStyle`.
3. Titles overflowing the width are truncated at the boundary.

## Acceptance criteria
- [ ] Goldens: basic tabs; selection highlight; custom divider; overflow truncation.
