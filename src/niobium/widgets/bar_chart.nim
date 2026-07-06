## BarChart: labeled vertical bars using eighth-block glyphs for sub-cell resolution.

import std/options

import ../core/[rect, style, buffer, text, unicodewidth]
import ./draw
import ./blocks

type
  Bar* = object
    value*: int
    label*: string
    style*: Style

  BarChart* = object
    bars*: seq[Bar]
    barWidth*: int
    barGap*: int
    max*: Option[int]
    barStyle*: Style
    valueStyle*: Style
    labelStyle*: Style
    blk*: Option[Block]

const eighthsUp = ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"]

func bar*(value: int, label = "", style = defaultStyle()): Bar =
  Bar(value: value, label: label, style: style)

func barChart*(
    bars: openArray[Bar],
    barWidth = 1,
    barGap = 1,
    max = none(int),
    barStyle = defaultStyle(),
    blk = none(Block),
): BarChart =
  ## Construct a bar chart.
  BarChart(
    bars: @bars,
    barWidth: barWidth,
    barGap: barGap,
    max: max,
    barStyle: barStyle,
    blk: blk,
  )

proc render*(c: BarChart, area: Rect, buf: var Buffer) =
  ## Draw vertical bars. The bottom row is reserved for labels when present.
  if area.isEmpty:
    return
  var inner = area
  if c.blk.isSome:
    c.blk.get.render(area, buf)
    inner = c.blk.get.inner(area)
  if inner.isEmpty:
    return

  let hasLabels = block:
    var any = false
    for b in c.bars:
      if b.label.len > 0:
        any = true
    any
  let chartBottom =
    if hasLabels:
      inner.bottom - 1
    else:
      inner.bottom
  let chartHeight = chartBottom - inner.top
  if chartHeight <= 0:
    return

  var maxVal = if c.max.isSome: c.max.get else: 0
  if c.max.isNone:
    for b in c.bars:
      maxVal = max(maxVal, b.value)
  if maxVal <= 0:
    return

  var x = inner.left
  for b in c.bars:
    if x >= inner.right:
      break
    let eighths = (b.value * chartHeight * 8) div maxVal
    let fullRows = eighths div 8
    let partial = eighths mod 8
    for col in 0 ..< c.barWidth:
      let bx = x + col
      if bx >= inner.right:
        break
      for r in 0 ..< fullRows:
        buf.setStringN(bx, chartBottom - 1 - r, "█", c.barStyle.patch(b.style), 1)
      if partial > 0 and fullRows < chartHeight:
        buf.setStringN(
          bx,
          chartBottom - 1 - fullRows,
          eighthsUp[partial - 1],
          c.barStyle.patch(b.style),
          1,
        )
    if hasLabels and b.label.len > 0:
      let off = alignOffset(alCenter, c.barWidth, displayWidth(b.label))
      buf.setStringN(x + off, chartBottom, b.label, c.labelStyle, c.barWidth)
    x += c.barWidth + c.barGap
