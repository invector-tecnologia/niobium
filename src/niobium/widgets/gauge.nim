## Gauge and LineGauge: progress bars (ratatui `widgets::Gauge`, `LineGauge`).

import std/options

import ../core/[rect, style, buffer, text, unicodewidth]
import ./draw
import ./blocks

type
  Gauge* = object
    ratio*: float
    label*: Option[string]
    blk*: Option[Block]
    gaugeStyle*: Style

  LineGauge* = object
    ratio*: float
    label*: string
    filledStyle*: Style
    unfilledStyle*: Style
    blk*: Option[Block]

const eighths = ["", "▏", "▎", "▍", "▌", "▋", "▊", "▉"]

func gauge*(ratio: float, label = none(string), gaugeStyle = defaultStyle(),
            blk = none(Block)): Gauge =
  ## Construct a gauge; `ratio` is clamped to 0..1.
  Gauge(ratio: clamp(ratio, 0.0, 1.0), label: label, gaugeStyle: gaugeStyle, blk: blk)

func percent*(g: Gauge): int =
  int(g.ratio * 100 + 0.5)

proc render*(g: Gauge, area: Rect, buf: var Buffer) =
  ## Draw a block-style gauge filling `ratio` of the width, with a centered label.
  if area.isEmpty: return
  var inner = area
  if g.blk.isSome:
    g.blk.get.render(area, buf)
    inner = g.blk.get.inner(area)
  if inner.isEmpty: return

  let w = inner.width.int
  let filledEighths = int(g.ratio * float(w) * 8.0 + 0.5)
  let fullCols = filledEighths div 8
  let partial = filledEighths mod 8
  let label = if g.label.isSome: g.label.get else: $g.percent() & "%"
  let labelStart = inner.left + alignOffset(alCenter, w, displayWidth(label))

  for y in inner.top ..< inner.bottom:
    for i in 0 ..< w:
      let x = inner.left + i
      var st = g.gaugeStyle
      var sym = " "
      if i < fullCols:
        sym = "█"
      elif i == fullCols and partial > 0:
        sym = eighths[partial]
      buf.setStringN(x, y, sym, st, 1)
    # Draw the label over the middle row.
    if y == inner.top + inner.height.int div 2:
      buf.setStringN(labelStart, y, label, g.gaugeStyle.add(mReversed), w)

proc render*(g: LineGauge, area: Rect, buf: var Buffer) =
  ## Draw a single-line gauge: a label followed by filled/unfilled cells.
  if area.isEmpty: return
  var inner = area
  if g.blk.isSome:
    g.blk.get.render(area, buf)
    inner = g.blk.get.inner(area)
  if inner.isEmpty: return
  let y = inner.top
  var x = inner.left
  if g.label.len > 0:
    x += buf.setStringN(x, y, g.label & " ", defaultStyle(), inner.right - x)
  let barWidth = inner.right - x
  let filled = int(clamp(g.ratio, 0.0, 1.0) * float(barWidth) + 0.5)
  for i in 0 ..< barWidth:
    let st = if i < filled: g.filledStyle else: g.unfilledStyle
    buf.setStringN(x + i, y, (if i < filled: "█" else: "─"), st, 1)
