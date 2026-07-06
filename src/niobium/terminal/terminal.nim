## The tick driver: owns two buffers and the backend, and runs draw -> diff -> dispatch -> swap
## (ADR-0001, ADR-0002). Generic over any backend providing the `Backend` surface.

import std/options

import ../core/[rect, buffer]
import ./frame
import ./viewport

type
  Terminal*[B] = object
    backend*: B
    buffers: array[2, Buffer]
    current: int
    viewport*: Viewport
    frameCount: int
    patches: seq[BufferPatch]

proc newTerminal*[B](backend: B, viewport = fullscreen()): Terminal[B] =
  ## Create a terminal over `backend`. Buffers are sized lazily on the first `draw`.
  result.backend = backend
  result.viewport = viewport
  result.buffers[0] = newBuffer(rect(0, 0, 0, 0))
  result.buffers[1] = newBuffer(rect(0, 0, 0, 0))

proc currentArea*[B](t: Terminal[B]): Rect =
  ## The area used on the last draw.
  t.buffers[t.current].area

proc setup*[B](t: var Terminal[B]) =
  ## Enter raw mode + alternate screen and hide the cursor (ADR-0008).
  mixin enterRaw, enterAltScreen, hideCursor, clear, flush
  t.backend.enterRaw()
  t.backend.enterAltScreen()
  t.backend.hideCursor()
  t.backend.clear()
  t.backend.flush()

proc restore*[B](t: var Terminal[B]) =
  ## Restore the terminal to its original state. Safe to call more than once.
  mixin showCursor, leaveAltScreen, leaveRaw, flush
  t.backend.showCursor()
  t.backend.leaveAltScreen()
  t.backend.leaveRaw()
  t.backend.flush()

proc draw*[B](t: var Terminal[B], render: proc(f: var Frame)) =
  ## Run one tick: build the next frame, diff it, dispatch the deltas, and swap buffers.
  mixin size, draw, flush, hideCursor, showCursor, setCursorPos
  let sz = t.backend.size()
  let area = viewportArea(t.viewport, sz)
  if t.buffers[0].area != area:
    t.buffers[0].resize(area)
    t.buffers[1].resize(area)
  let nextIdx = 1 - t.current
  t.buffers[nextIdx].reset()

  var f = Frame(buf: addr t.buffers[nextIdx], frameArea: area, count: t.frameCount)
  render(f)

  diff(t.buffers[t.current], t.buffers[nextIdx], t.patches)
  t.backend.draw(t.patches)
  if f.cursor.isSome:
    t.backend.setCursorPos(f.cursor.get)
    t.backend.showCursor()
  else:
    t.backend.hideCursor()
  t.backend.flush()

  t.current = nextIdx
  inc t.frameCount
