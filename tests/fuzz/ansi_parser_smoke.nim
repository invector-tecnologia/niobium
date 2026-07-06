## ANSI event-parser fuzz smoke (ADR-0007): feed random/truncated byte streams to the real decoder
## and assert it never crashes and never over-consumes its input.

import std/[random, unittest]

import ../../src/niobium

suite "ansi parser fuzz smoke":
  test "random byte streams never crash and never over-consume":
    var rng = initRand(0xC0FFEE)
    for _ in 0 ..< 20000:
      let n = rng.rand(0 .. 48)
      var s = newStringOfCap(n)
      for _ in 0 ..< n:
        s.add char(rng.rand(0 .. 255))
      let r = decodeAll(s)
      check r.consumed >= 0
      check r.consumed <= s.len

