# Table spec

- Parity: `widgets::Table` + `TableState` · Tests: tests/test_widgets.nim
- Status: mirrored

## Purpose
Rows and columns with constraint-based column widths, optional header, and row selection.

## API surface
- `Row = object { cells: seq[string], style }`.
- `Table` with `rows`, `header: Option[Row]`, `widths: seq[Constraint]`, `columnSpacing`, `blk`,
  `style`, `highlightStyle`, `highlightSymbol`.
- `TableState = object { offset: int, selected: Option[int] }`.
- `row(cells, style = defaultStyle())` and `table(rows, widths, header, columnSpacing, blk, style,
  highlightStyle, highlightSymbol)` constructors.
- `render(table, area, buf, state)`.

## Behavior
1. Column widths are computed by splitting the inner width with `widths` (layout solver) plus
   `columnSpacing` between columns.
2. Header (if present) renders on the first row and does not scroll.
3. Selected row uses `highlightStyle` + `highlightSymbol`; offset scrolls selection into view.
4. Cell content is truncated to its column width.

## Acceptance criteria
- [ ] Goldens: fixed/percentage/min column widths; header; selection; scrolling; spacing.
