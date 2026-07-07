## The retained cell grid and its diff (ADR-0001, ADR-0003, ADR-0010).
##
## A `Buffer` is a flat `seq[Cell]` indexed `(y - area.y) * width + (x - area.x)`. It is the diff
## baseline that enables double buffering. `diff` fills a caller-provided patch seq so the steady
## state does not allocate.

import std/unicode

import ./rect
import ./cell
import ./style
import ./unicodewidth

type
  Buffer* = object
    area*: Rect
    content*: seq[Cell]

  BufferPatch* = object
    x*, y*: uint16
    cell*: Cell

func newBuffer*(area: Rect): Buffer =
  ## A buffer sized to `area`, filled with blank cells.
  runnableExamples:
    import tatui/core/rect
    let b = newBuffer(rect(0, 0, 4, 2))
    doAssert b.content.len == 8
  result.area = area
  result.content = newSeq[Cell](area.area)
  for i in 0 ..< result.content.len:
    result.content[i] = cell()

func index*(b: Buffer, x, y: int): int =
  ## Flat index of cell `(x, y)`; assumes the coordinate is inside `b.area`.
  (y - b.area.y.int) * b.area.width.int + (x - b.area.x.int)

func inside*(b: Buffer, x, y: int): bool =
  ## Whether `(x, y)` lies within the buffer's area.
  b.area.contains(x, y)

func `[]`*(b: Buffer, x, y: int): Cell =
  ## Read the cell at `(x, y)`.
  b.content[b.index(x, y)]

proc `[]=`*(b: var Buffer, x, y: int, c: Cell) =
  ## Write the cell at `(x, y)` (no-op if out of bounds).
  if b.inside(x, y):
    b.content[b.index(x, y)] = c

proc reset*(b: var Buffer) =
  ## Blank every cell in place (no reallocation).
  for i in 0 ..< b.content.len:
    b.content[i].reset()

proc resize*(b: var Buffer, area: Rect) =
  ## Resize the backing storage to `area` (allocation permitted; not on the steady-state path).
  b.area = area
  b.content.setLen(area.area)
  b.reset()

proc setStringN*(
    b: var Buffer, x, y: int, s: string, st: Style, maxWidth: int
): int {.discardable.} =
  ## Write `s` starting at `(x, y)`, applying style `st`, up to `maxWidth` columns.
  ## Wide graphemes are never split; the trailing cell is marked `skip`. Returns columns written.
  var cx = x
  let limit = x + maxWidth
  for r in s.runes:
    let w = runeDisplayWidth(r)
    if w == 0:
      continue # combining mark: v1 attaches nothing; skip to keep the grid stable
    if cx + w > limit or cx >= b.area.right:
      break
    if not b.inside(cx, y):
      break
    var c = cell($r)
    c.apply(st)
    b.content[b.index(cx, y)] = c
    if w == 2 and b.inside(cx + 1, y):
      var trailing = cell(" ")
      trailing.apply(st)
      trailing.skip = true
      b.content[b.index(cx + 1, y)] = trailing
    cx += w
  cx - x

proc setString*(
    b: var Buffer, x, y: int, s: string, st: Style = defaultStyle()
): int {.discardable.} =
  ## Write `s` at `(x, y)` bounded by the buffer's right edge. Returns columns written.
  b.setStringN(x, y, s, st, b.area.right - x)

proc diff*(prev, cur: Buffer, into: var seq[BufferPatch]) =
  ## Fill `into` with the minimal set of changed, non-`skip` cells (draw order). Allocation-free
  ## once `into` has enough capacity.
  into.setLen(0)
  if prev.content.len != cur.content.len:
    # Full repaint (e.g. after resize).
    for y in cur.area.top ..< cur.area.bottom:
      for x in cur.area.left ..< cur.area.right:
        let c = cur[x, y]
        if not c.skip:
          into.add BufferPatch(x: x.uint16, y: y.uint16, cell: c)
    return
  for y in cur.area.top ..< cur.area.bottom:
    for x in cur.area.left ..< cur.area.right:
      let idx = cur.index(x, y)
      let c = cur.content[idx]
      if c.skip:
        continue
      if c != prev.content[idx]:
        into.add BufferPatch(x: x.uint16, y: y.uint16, cell: c)

proc diff*(prev, cur: Buffer): seq[BufferPatch] =
  ## Convenience wrapper returning a fresh patch seq.
  diff(prev, cur, result)
