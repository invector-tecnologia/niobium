## Core geometry: rectangles, positions, and sizes measured in terminal cells.
##
## Mirrors ratatui's `layout::Rect`. Pure value types; no rendering. All arithmetic is done in
## `int` internally and clamped back into `uint16`, so operations saturate instead of overflowing.

type
  Position* = object ## A 0-based cell coordinate.
    x*, y*: uint16

  Size* = object ## A width/height extent in cells.
    width*, height*: uint16

  Rect* = object
    ## An axis-aligned rectangle of cells. `right`/`bottom` edges are exclusive.
    x*, y*, width*, height*: uint16

func rect*(x, y, width, height: int): Rect =
  ## Construct a `Rect`, clamping negatives to zero.
  runnableExamples:
    let r = rect(1, 2, 3, 4)
    doAssert r.width == 3
  func c(v: int): uint16 =
    (if v < 0: 0 elif v > int(high(uint16)): int(high(uint16)) else: v).uint16
  Rect(x: c(x), y: c(y), width: c(width), height: c(height))

func pos*(x, y: int): Position =
  Position(x: x.uint16, y: y.uint16)

func size*(width, height: int): Size =
  Size(width: width.uint16, height: height.uint16)

func area*(r: Rect): int =
  ## Number of cells the rectangle covers.
  runnableExamples:
    doAssert rect(0, 0, 3, 4).area == 12
  r.width.int * r.height.int

func left*(r: Rect): int =
  r.x.int
func top*(r: Rect): int =
  r.y.int
func right*(r: Rect): int = ## Exclusive.
  r.x.int + r.width.int
func bottom*(r: Rect): int = ## Exclusive.
  r.y.int + r.height.int

func isEmpty*(r: Rect): bool =
  ## True when the rectangle covers no cells.
  r.width == 0 or r.height == 0

func contains*(r: Rect, x, y: int): bool =
  ## Whether the cell `(x, y)` lies inside `r`.
  x >= r.left and x < r.right and y >= r.top and y < r.bottom

func intersection*(a, b: Rect): Rect =
  ## The overlapping region of `a` and `b`; empty (zero-sized) if they are disjoint.
  runnableExamples:
    doAssert rect(0, 0, 2, 2).intersection(rect(1, 1, 2, 2)) == rect(1, 1, 1, 1)
  let
    x1 = max(a.left, b.left)
    y1 = max(a.top, b.top)
    x2 = min(a.right, b.right)
    y2 = min(a.bottom, b.bottom)
  if x2 <= x1 or y2 <= y1:
    rect(x1, y1, 0, 0)
  else:
    rect(x1, y1, x2 - x1, y2 - y1)

func union*(a, b: Rect): Rect =
  ## The smallest rectangle containing both `a` and `b`.
  if a.isEmpty:
    return b
  if b.isEmpty:
    return a
  let
    x1 = min(a.left, b.left)
    y1 = min(a.top, b.top)
    x2 = max(a.right, b.right)
    y2 = max(a.bottom, b.bottom)
  rect(x1, y1, x2 - x1, y2 - y1)

func inner*(r: Rect, horizontal, vertical: int): Rect =
  ## Shrink `r` by the given margins on each axis, clamped so dimensions never go negative.
  runnableExamples:
    doAssert rect(0, 0, 10, 10).inner(2, 1) == rect(2, 1, 6, 8)
  if r.width.int < 2 * horizontal or r.height.int < 2 * vertical:
    rect(
      r.x.int + min(horizontal, r.width.int),
      r.y.int + min(vertical, r.height.int),
      0,
      0,
    )
  else:
    rect(
      r.x.int + horizontal,
      r.y.int + vertical,
      r.width.int - 2 * horizontal,
      r.height.int - 2 * vertical,
    )

func inner*(r: Rect, margin: int): Rect =
  ## Shrink `r` uniformly by `margin` on all sides.
  r.inner(margin, margin)
