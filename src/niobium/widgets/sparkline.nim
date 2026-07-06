## Sparkline: a compact single-line trend using eighth-block glyphs.

import std/options

import ../core/[rect, style, buffer]
import ./blocks

type Sparkline* = object
  data*: seq[int]
  max*: Option[int]
  style*: Style
  blk*: Option[Block]

const bars = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]

func sparkline*(
    data: openArray[int], max = none(int), style = defaultStyle(), blk = none(Block)
): Sparkline =
  ## Construct a sparkline.
  Sparkline(data: @data, max: max, style: style, blk: blk)

proc render*(s: Sparkline, area: Rect, buf: var Buffer) =
  ## Draw the sparkline on the bottom row of the (inner) area.
  if area.isEmpty:
    return
  var inner = area
  if s.blk.isSome:
    s.blk.get.render(area, buf)
    inner = s.blk.get.inner(area)
  if inner.isEmpty:
    return

  var maxVal = if s.max.isSome: s.max.get else: 0
  if s.max.isNone:
    for v in s.data:
      maxVal = max(maxVal, v)
  if maxVal <= 0:
    return

  let y = inner.bottom - 1
  let count = min(s.data.len, inner.width.int)
  let start = max(0, s.data.len - inner.width.int)
  for i in 0 ..< count:
    let v = s.data[start + i]
    let level = clamp((v * 8) div maxVal, 0, 8)
    if level > 0:
      buf.setStringN(inner.left + i, y, bars[level - 1], s.style, 1)
