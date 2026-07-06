## The per-draw handle widgets render into (ADR-0001).
##
## A `Frame` wraps the next buffer, the drawable area, and an optional cursor request. Widgets are
## any type providing `render(area: Rect, buf: var Buffer)`; stateful widgets also take `var state`.

import std/options

import ../core/[rect, buffer]

type Frame* = object
  buf*: ptr Buffer
  frameArea*: Rect
  cursor*: Option[Position]
  count*: int

func area*(f: Frame): Rect =
  ## The drawable area for this frame.
  f.frameArea

proc setCursor*(f: var Frame, p: Position) =
  ## Request the terminal cursor be shown at `p` after this draw.
  f.cursor = some(p)

proc renderWidget*[W](f: var Frame, w: W, area: Rect) =
  ## Render a stateless widget into `area`.
  w.render(area, f.buf[])

proc renderStateful*[W, S](f: var Frame, w: W, area: Rect, state: var S) =
  ## Render a stateful widget into `area`.
  w.render(area, f.buf[], state)
