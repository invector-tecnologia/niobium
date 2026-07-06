# Tabs spec

- Parity: `widgets::Tabs` · Tests: tests/widgets/test_tabs.nim

## Purpose
A single-line horizontal tab bar with a selected tab.

## API surface
- `Tabs` with `titles: seq[Line]`, `selected: int`, `block`, `style`, `highlightStyle`,
  `divider: string`, `padding`.
- `render(tabs, area, buf)`.

## Behavior
1. Titles render left-to-right separated by `divider`, each padded by `padding`.
2. The `selected` title uses `highlightStyle`.
3. Titles overflowing the width are truncated at the boundary.

## Acceptance criteria
- [ ] Goldens: basic tabs; selection highlight; custom divider; overflow truncation.
