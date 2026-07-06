## Paragraph: styled text with optional wrapping, alignment, and vertical scroll.

import std/[options, strutils]

import ../core/[rect, style, buffer, text, unicodewidth]
import ./draw
import ./blocks

type
  Wrap* = object
    trim*: bool

  Paragraph* = object
    text*: Text
    blk*: Option[Block]
    wrap*: Option[Wrap]
    scroll*: tuple[x, y: int]
    alignment*: Alignment
    style*: Style

  VisualLine = object
    s: string
    st: Style
    align: Alignment

func paragraph*(t: Text, blk = none(Block), wrap = none(Wrap),
                alignment = alLeft, style = defaultStyle()): Paragraph =
  ## Construct a paragraph.
  Paragraph(text: t, blk: blk, wrap: wrap, alignment: alignment, style: style)

func paragraph*(s: string): Paragraph =
  paragraph(text(s))

func wrapString(s: string, width: int): seq[string] =
  if width <= 0: return @[s]
  var line = ""
  var lineW = 0
  for word in s.split(' '):
    let ww = displayWidth(word)
    if lineW == 0:
      line = word
      lineW = ww
    elif lineW + 1 + ww <= width:
      line.add ' '
      line.add word
      lineW += 1 + ww
    else:
      result.add line
      line = word
      lineW = ww
  result.add line

proc render*(p: Paragraph, area: Rect, buf: var Buffer) =
  ## Draw the paragraph, applying its block, wrapping, alignment, and scroll.
  if area.isEmpty: return
  var inner = area
  if p.blk.isSome:
    p.blk.get.render(area, buf)
    inner = p.blk.get.inner(area)
  if inner.isEmpty: return

  var vlines: seq[VisualLine]
  for ln in p.text.lines:
    let flat = block:
      var s = ""
      for sp in ln.spans: s.add sp.content
      s
    let align = (if p.alignment != alLeft: p.alignment else: ln.alignment)
    if p.wrap.isSome:
      for chunk in wrapString(flat, inner.width.int):
        vlines.add VisualLine(s: chunk, st: p.style.patch(ln.style), align: align)
    else:
      vlines.add VisualLine(s: flat, st: p.style.patch(ln.style), align: align)

  var y = inner.top
  var idx = p.scroll.y
  while idx < vlines.len and y < inner.bottom:
    let vl = vlines[idx]
    let shown =
      if p.scroll.x > 0 and p.scroll.x < vl.s.len: vl.s[p.scroll.x .. ^1] else: vl.s
    let off = alignOffset(vl.align, inner.width.int, displayWidth(shown))
    buf.setStringN(inner.left + off, y, shown, vl.st, inner.width.int - off)
    inc y
    inc idx
