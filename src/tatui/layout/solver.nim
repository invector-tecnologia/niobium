## The layout solver: split a `Rect` by constraints (ADR-0004).
##
## v1 uses a deterministic greedy solver behind the final `Constraint` API. Segment sizes always sum
## exactly to the available extent (remainder distributed start -> end), so no cells are lost or
## overlapped. Solved results are memoized in a thread-local cache keyed by the request.

import std/tables

import ../core/rect
import ./constraint

var cache {.threadvar.}: Table[string, seq[int]]
var cacheReady {.threadvar.}: bool

func solveSizes(available: int, cs: seq[Constraint]): seq[int] =
  let n = cs.len
  if n == 0:
    return
  var sizes = newSeq[int](n)
  for i, c in cs:
    sizes[i] =
      case c.kind
      of conLength:
        c.length
      of conPercentage:
        (c.percent * available + 50) div 100
      of conRatio:
        (if c.den == 0: 0 else: (c.num * available + c.den div 2) div c.den)
      of conMin:
        c.minVal
      of conMax:
        min(c.maxVal, available)
      of conFill:
        0
    if sizes[i] < 0:
      sizes[i] = 0

  var used = 0
  for s in sizes:
    used += s
  var rem = available - used

  if rem > 0:
    var totalWeight = 0
    for c in cs:
      if c.kind == conFill:
        totalWeight += max(0, c.weight)
    if totalWeight > 0:
      var assigned = 0
      for i, c in cs:
        if c.kind == conFill:
          sizes[i] = (rem * max(0, c.weight)) div totalWeight
          assigned += sizes[i]
      var leftover = rem - assigned
      var k = 0
      while leftover > 0:
        if cs[k mod n].kind == conFill:
          sizes[k mod n] += 1
          dec leftover
        inc k
    # With no Fill constraint, leftover space is left unused (segments keep their intents).
  elif rem < 0:
    var deficit = -rem
    while deficit > 0:
      var progressed = false
      for i in countdown(n - 1, 0):
        if deficit == 0:
          break
        if sizes[i] > 0:
          dec sizes[i]
          dec deficit
          progressed = true
      if not progressed:
        break
  sizes

proc keyOf(available, spacing: int, cs: seq[Constraint]): string =
  result = $available & "|" & $spacing & "|"
  for c in cs:
    result.add $c.kind & ":"
    result.add (
      case c.kind
      of conLength: $c.length
      of conPercentage: $c.percent
      of conRatio: $c.num & "/" & $c.den
      of conMin: $c.minVal
      of conMax: $c.maxVal
      of conFill: $c.weight
    )
    result.add ";"

proc cachedSolve(available, spacing: int, cs: seq[Constraint]): seq[int] =
  if not cacheReady:
    cache = initTable[string, seq[int]]()
    cacheReady = true
  let k = keyOf(available, spacing, cs)
  if cache.hasKey(k):
    return cache[k]
  result = solveSizes(available, cs)
  cache[k] = result

proc split*(
    area: Rect,
    dir: Direction,
    constraints: openArray[Constraint],
    spacing = 0,
    margin = 0,
): seq[Rect] =
  ## Split `area` along `dir` into one rect per constraint.
  runnableExamples:
    import tatui/core/rect
    import tatui/layout/constraint
    let cols = rect(0, 0, 10, 1).split(Horizontal, @[length(3), fill(1)])
    doAssert cols[0] == rect(0, 0, 3, 1)
    doAssert cols[1] == rect(3, 0, 7, 1)
  let inner = area.inner(margin, margin)
  let n = constraints.len
  if n == 0:
    return
  let cs = @constraints
  let totalSpacing = spacing * (n - 1)
  if dir == Horizontal:
    let avail = max(0, inner.width.int - totalSpacing)
    let sizes = cachedSolve(avail, spacing, cs)
    var x = inner.left
    for s in sizes:
      result.add rect(x, inner.top, s, inner.height.int)
      x += s + spacing
  else:
    let avail = max(0, inner.height.int - totalSpacing)
    let sizes = cachedSolve(avail, spacing, cs)
    var y = inner.top
    for s in sizes:
      result.add rect(inner.left, y, inner.width.int, s)
      y += s + spacing
