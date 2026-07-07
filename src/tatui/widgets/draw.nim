## Shared drawing helpers for widgets. These operate on a `var Buffer` and never touch the terminal.

import ../core/[rect, style, cell, text, buffer]

proc fillStyle*(buf: var Buffer, area: Rect, st: Style) =
  ## Apply a style to every cell in `area` (used for widget backgrounds).
  for y in area.top ..< area.bottom:
    for x in area.left ..< area.right:
      if buf.inside(x, y):
        var c = buf[x, y]
        c.apply(st)
        buf[x, y] = c

proc drawLine*(
    buf: var Buffer, x, y: int, ln: Line, maxWidth: int, base: Style
): int {.discardable.} =
  ## Draw a `Line` (span by span) starting at `(x, y)`, bounded by `maxWidth`. Returns width used.
  var cx = x
  var remaining = maxWidth
  for sp in ln.spans:
    if remaining <= 0:
      break
    let st = base.patch(ln.style).patch(sp.style)
    let used = buf.setStringN(cx, y, sp.content, st, remaining)
    cx += used
    remaining -= used
  cx - x

func alignOffset*(align: Alignment, width, content: int): int =
  ## Left offset to place `content` columns within `width`, per alignment.
  case align
  of alLeft:
    0
  of alCenter:
    max(0, (width - content) div 2)
  of alRight:
    max(0, width - content)

proc drawText*(buf: var Buffer, area: Rect, t: Text, base: Style) =
  ## Draw `Text` clipped to `area`, honoring per-line alignment. No wrapping.
  var y = area.top
  for ln in t.lines:
    if y >= area.bottom:
      break
    let w = ln.width
    let off = alignOffset(ln.alignment, area.width.int, w)
    drawLine(buf, area.left + off, y, ln, area.width.int - off, base.patch(t.style))
    inc y
