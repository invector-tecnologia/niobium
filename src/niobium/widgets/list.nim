## List: a vertical, scrollable, selectable list (ratatui `widgets::List` + `ListState`).

import std/[options, strutils]

import ../core/[rect, style, buffer, text]
import ./draw
import ./blocks

type
  ListItem* = object
    content*: Text
    style*: Style

  List* = object
    items*: seq[ListItem]
    blk*: Option[Block]
    style*: Style
    highlightStyle*: Style
    highlightSymbol*: string

  ListState* = object
    offset*: int
    selected*: Option[int]

func listItem*(s: string, style = defaultStyle()): ListItem =
  ListItem(content: text(s), style: style)

func list*(items: openArray[ListItem], blk = none(Block), style = defaultStyle(),
           highlightStyle = defaultStyle(), highlightSymbol = ""): List =
  ## Construct a list.
  List(items: @items, blk: blk, style: style, highlightStyle: highlightStyle,
       highlightSymbol: highlightSymbol)

proc select*(s: var ListState, i: int) =
  ## Select item `i`.
  s.selected = some(i)

proc render*(l: List, area: Rect, buf: var Buffer, state: var ListState) =
  ## Draw the list, scrolling so the selection stays visible.
  if area.isEmpty: return
  var inner = area
  if l.blk.isSome:
    l.blk.get.render(area, buf)
    inner = l.blk.get.inner(area)
  if inner.isEmpty: return
  let rows = inner.height.int

  if state.selected.isSome:
    let sel = state.selected.get
    if sel < state.offset:
      state.offset = sel
    elif sel >= state.offset + rows:
      state.offset = sel - rows + 1
  if state.offset < 0: state.offset = 0

  let symWidth = l.highlightSymbol.len
  var y = inner.top
  var i = state.offset
  while i < l.items.len and y < inner.bottom:
    let selected = state.selected.isSome and state.selected.get == i
    let rowStyle = if selected: l.style.patch(l.items[i].style).patch(l.highlightStyle)
                   else: l.style.patch(l.items[i].style)
    var x = inner.left
    if symWidth > 0:
      let prefix = if selected: l.highlightSymbol else: " ".repeat(symWidth)
      x += buf.setStringN(x, y, prefix, rowStyle, inner.right - x)
    if l.items[i].content.lines.len > 0:
      drawLine(buf, x, y, l.items[i].content.lines[0], inner.right - x, rowStyle)
    inc y
    inc i
