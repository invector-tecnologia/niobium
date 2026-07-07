## Table: rows and columns with constraint-based widths and row selection.

import std/[options, strutils]

import ../core/[rect, style, buffer]
import ../layout/[constraint, solver]
import ./blocks

type
  Row* = object
    cells*: seq[string]
    style*: Style

  Table* = object
    rows*: seq[Row]
    header*: Option[Row]
    widths*: seq[Constraint]
    columnSpacing*: int
    blk*: Option[Block]
    style*: Style
    highlightStyle*: Style
    highlightSymbol*: string

  TableState* = object
    offset*: int
    selected*: Option[int]

func row*(cells: openArray[string], style = defaultStyle()): Row =
  Row(cells: @cells, style: style)

func table*(
    rows: openArray[Row],
    widths: openArray[Constraint],
    header = none(Row),
    columnSpacing = 1,
    blk = none(Block),
    style = defaultStyle(),
    highlightStyle = defaultStyle(),
    highlightSymbol = "",
): Table =
  ## Construct a table.
  Table(
    rows: @rows,
    widths: @widths,
    header: header,
    columnSpacing: columnSpacing,
    blk: blk,
    style: style,
    highlightStyle: highlightStyle,
    highlightSymbol: highlightSymbol,
  )

proc drawRow(buf: var Buffer, area: Rect, cols: seq[Rect], r: Row, st: Style) =
  for i in 0 ..< min(cols.len, r.cells.len):
    buf.setStringN(cols[i].left, area.top, r.cells[i], st, cols[i].width.int)

proc render*(t: Table, area: Rect, buf: var Buffer, state: var TableState) =
  ## Draw the table, scrolling so the selection stays visible.
  if area.isEmpty:
    return
  var inner = area
  if t.blk.isSome:
    t.blk.get.render(area, buf)
    inner = t.blk.get.inner(area)
  if inner.isEmpty:
    return

  let symWidth = t.highlightSymbol.len
  let gridLeft = inner.left + symWidth
  let gridWidth = max(0, inner.width.int - symWidth)
  let cols = rect(gridLeft, inner.top, gridWidth, 1).split(
      Horizontal, t.widths, spacing = t.columnSpacing
    )

  var y = inner.top
  if t.header.isSome:
    let hrect = rect(inner.left, y, inner.width.int, 1)
    let hcols = rect(gridLeft, y, gridWidth, 1).split(
        Horizontal, t.widths, spacing = t.columnSpacing
      )
    drawRow(buf, hrect, hcols, t.header.get, t.style.patch(t.header.get.style))
    inc y

  let rows = inner.bottom - y
  if state.selected.isSome:
    let sel = state.selected.get
    if sel < state.offset:
      state.offset = sel
    elif sel >= state.offset + rows:
      state.offset = sel - rows + 1
  if state.offset < 0:
    state.offset = 0

  var i = state.offset
  while i < t.rows.len and y < inner.bottom:
    let selected = state.selected.isSome and state.selected.get == i
    let st =
      if selected:
        t.style.patch(t.rows[i].style).patch(t.highlightStyle)
      else:
        t.style.patch(t.rows[i].style)
    if symWidth > 0:
      let prefix =
        if selected:
          t.highlightSymbol
        else:
          " ".repeat(symWidth)
      buf.setStringN(inner.left, y, prefix, st, symWidth)
    let rrect = rect(inner.left, y, inner.width.int, 1)
    let rcols = rect(gridLeft, y, gridWidth, 1).split(
        Horizontal, t.widths, spacing = t.columnSpacing
      )
    drawRow(buf, rrect, rcols, t.rows[i], st)
    inc y
    inc i
