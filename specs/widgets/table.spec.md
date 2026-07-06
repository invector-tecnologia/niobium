# Table spec

- Parity: `widgets::Table` + `TableState` · Tests: tests/widgets/test_table.nim

## Purpose
Rows and columns with constraint-based column widths, optional header, and row selection.

## API surface
- `Row = object { cells: seq[Text], height: int, style }`; `Cell` wraps `Text`.
- `Table` with `rows`, `header: Option[Row]`, `widths: seq[Constraint]`, `columnSpacing`, `block`,
  `style`, `highlightStyle`, `highlightSymbol`.
- `TableState = object { offset: int, selected: Option[int] }`.
- `render(table, area, buf, state)`.

## Behavior
1. Column widths are computed by splitting the inner width with `widths` (layout solver) plus
   `columnSpacing` between columns.
2. Header (if present) renders on the first row and does not scroll.
3. Selected row uses `highlightStyle` + `highlightSymbol`; offset scrolls selection into view.
4. Cell content is truncated to its column width; wide graphemes never split.

## Acceptance criteria
- [ ] Goldens: fixed/percentage/min column widths; header; selection; scrolling; spacing.
