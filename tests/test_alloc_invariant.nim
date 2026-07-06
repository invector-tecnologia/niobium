## Allocation invariant (ADR-0010): the render path must not allocate on the heap in steady
## state. Stage 2 replaces this scaffold with N draw ticks and asserts a zero `getOccupiedMem`
## delta. For now it establishes the harness and passes trivially.

import std/unittest

proc steadyStateAllocDelta(iterations: int): int =
  ## Placeholder: returns the heap growth (bytes) across `iterations` steady-state ticks.
  ## Stage 2 will drive a real `Terminal.draw` loop here.
  let before = getOccupiedMem()
  for _ in 0 ..< iterations:
    discard
  getOccupiedMem() - before

suite "allocation invariant":
  test "steady-state ticks do not grow the heap":
    check steadyStateAllocDelta(1000) == 0
