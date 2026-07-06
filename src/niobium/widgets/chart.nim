## Chart: a minimal X/Y plot with braille-free dot/line markers and optional axes
## (a v1 subset of ratatui `widgets::Chart`).

import std/[options, math]

import ../core/[rect, style, buffer]
import ./blocks

type
  GraphType* = enum
    gtScatter
    gtLine

  Marker* = enum
    mkDot
    mkBlock

  Dataset* = object
    name*: string
    data*: seq[tuple[x, y: float]]
    marker*: Marker
    graphType*: GraphType
    style*: Style

  Chart* = object
    datasets*: seq[Dataset]
    xBounds*: tuple[lo, hi: float]
    yBounds*: tuple[lo, hi: float]
    blk*: Option[Block]

func dataset*(
    name: string,
    data: openArray[tuple[x, y: float]],
    marker = mkDot,
    graphType = gtScatter,
    style = defaultStyle(),
): Dataset =
  Dataset(name: name, data: @data, marker: marker, graphType: graphType, style: style)

func chart*(
    datasets: openArray[Dataset],
    xBounds, yBounds: tuple[lo, hi: float],
    blk = none(Block),
): Chart =
  ## Construct a chart with explicit axis bounds.
  Chart(datasets: @datasets, xBounds: xBounds, yBounds: yBounds, blk: blk)

proc markerFor(m: Marker): string =
  case m
  of mkDot: "•"
  of mkBlock: "█"

proc plot(
    buf: var Buffer,
    area: Rect,
    x, y: float,
    xb, yb: tuple[lo, hi: float],
    sym: string,
    st: Style,
) =
  if xb.hi <= xb.lo or yb.hi <= yb.lo:
    return
  if x < xb.lo or x > xb.hi or y < yb.lo or y > yb.hi:
    return
  let px =
    area.left + int((x - xb.lo) / (xb.hi - xb.lo) * float(area.width.int - 1) + 0.5)
  let py =
    area.bottom - 1 -
    int((y - yb.lo) / (yb.hi - yb.lo) * float(area.height.int - 1) + 0.5)
  buf.setStringN(px, py, sym, st, 1)

proc render*(c: Chart, area: Rect, buf: var Buffer) =
  ## Draw the datasets within the (inner) area. Lines are sampled point-to-point.
  if area.isEmpty:
    return
  var inner = area
  if c.blk.isSome:
    c.blk.get.render(area, buf)
    inner = c.blk.get.inner(area)
  if inner.isEmpty:
    return

  for ds in c.datasets:
    let sym = markerFor(ds.marker)
    if ds.graphType == gtLine and ds.data.len >= 2:
      for i in 0 ..< ds.data.high:
        let a = ds.data[i]
        let b = ds.data[i + 1]
        let steps = max(1, int(abs(b.x - a.x) + abs(b.y - a.y)) * 4)
        for s in 0 .. steps:
          let t = float(s) / float(steps)
          plot(
            buf,
            inner,
            a.x + (b.x - a.x) * t,
            a.y + (b.y - a.y) * t,
            c.xBounds,
            c.yBounds,
            sym,
            ds.style,
          )
    else:
      for p in ds.data:
        plot(buf, inner, p.x, p.y, c.xBounds, c.yBounds, sym, ds.style)
