## ANSI event-parser fuzz smoke (ADR-0007): feed random/truncated byte streams to the parser
## and assert it never crashes and fully consumes its input. Stage 2 wires this to the real
## `event/reader` parser; for now it exercises the harness with a no-op consumer.

import std/[random, unittest]

proc consume(bytes: openArray[byte]): int =
  ## Placeholder total parser: consumes all input, never raises. Replaced in Stage 2.
  bytes.len

suite "ansi parser fuzz smoke":
  test "random byte streams are fully consumed without crashing":
    var rng = initRand(0xC0FFEE)
    for _ in 0 ..< 5000:
      let n = rng.rand(0 .. 64)
      var buf = newSeq[byte](n)
      for i in 0 ..< n:
        buf[i] = byte(rng.rand(0 .. 255))
      check consume(buf) == n
