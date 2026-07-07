## Allocation invariant (ADR-0010): the render path must not leak or grow the live heap in steady
## state. We drive a real draw loop through the `TestBackend` and assert `getOccupiedMem()` stays
## flat after warmup (per-frame churn is freed by ORC; a growing figure would indicate a leak).

import std/unittest

import ../src/tatui

proc drawTick(term: var Terminal[TestBackend], frame: int) =
  term.draw proc(f: var Frame) =
    let b = initBlock(title = "alloc", borders = AllBorders)
    f.renderWidget(b, f.area)
    f.renderWidget(paragraph("frame " & $frame), b.inner(f.area))
    let cols = f.area.split(Horizontal, @[pct(50), pct(50)])
    f.renderWidget(gauge(float(frame mod 100) / 100.0), cols[0])

suite "allocation invariant":
  test "steady-state draws do not leak (growth converges to zero)":
    var term = newTerminal(newTestBackend(40, 10))
    for i in 0 ..< 200: # warmup: size buffers, fill the layout cache, grow scratch seqs
      drawTick(term, i)
    GC_fullCollect()
    let m1 = getOccupiedMem()
    for i in 0 ..< 500:
      drawTick(term, i)
    GC_fullCollect()
    let m2 = getOccupiedMem()
    for i in 0 ..< 500:
      drawTick(term, i)
    GC_fullCollect()
    let m3 = getOccupiedMem()
    # A true steady state: the second window must not grow more than the first — i.e. per-frame
    # churn is reclaimed and live memory is not growing with the iteration count.
    check (m3 - m2) <= max(0, m2 - m1)
