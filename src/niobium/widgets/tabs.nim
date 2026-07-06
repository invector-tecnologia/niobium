## Tabs: a single-line tab bar with a highlighted selection.

import std/options

import ../core/[rect, style, buffer]
import ./blocks

type Tabs* = object
  titles*: seq[string]
  selected*: int
  blk*: Option[Block]
  style*: Style
  highlightStyle*: Style
  divider*: string

func tabs*(
    titles: openArray[string],
    selected = 0,
    highlightStyle = defaultStyle(),
    divider = " | ",
    blk = none(Block),
): Tabs =
  ## Construct a tab bar.
  Tabs(
    titles: @titles,
    selected: selected,
    highlightStyle: highlightStyle,
    divider: divider,
    blk: blk,
  )

proc render*(t: Tabs, area: Rect, buf: var Buffer) =
  ## Draw the tab bar on a single line.
  if area.isEmpty:
    return
  var inner = area
  if t.blk.isSome:
    t.blk.get.render(area, buf)
    inner = t.blk.get.inner(area)
  var x = inner.left
  for i, title in t.titles:
    if x >= inner.right:
      break
    let st =
      if i == t.selected:
        t.style.patch(t.highlightStyle)
      else:
        t.style
    x += buf.setStringN(x, inner.top, title, st, inner.right - x)
    if i < t.titles.high and x < inner.right:
      x += buf.setStringN(x, inner.top, t.divider, t.style, inner.right - x)
