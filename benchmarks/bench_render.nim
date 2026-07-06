## Render benchmark scaffold (`nimble bench`). Stage 2 replaces the body with a real
## diff/draw loop over a sized buffer and reports throughput; CI fails on regression.

import std/[times, monotimes]

proc main() =
  let start = getMonoTime()
  var acc = 0
  for i in 0 ..< 1_000_000:
    acc += i
  let elapsed = (getMonoTime() - start).inMilliseconds
  echo "scaffold bench: ", elapsed, " ms (acc=", acc, ")"

when isMainModule:
  main()
