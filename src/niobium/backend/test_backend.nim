## An in-memory backend for deterministic tests (ADR-0011). Renders patches into a `Buffer` instead
## of a real terminal, so rendering can be asserted with golden snapshots.

import ../core/[rect, cell, buffer]

type
  TestBackend* = object
    buffer*: Buffer
    cursor*: Position
    cursorVisible*: bool

proc newTestBackend*(width, height: int): TestBackend =
  ## A test backend sized to `width` x `height`.
  TestBackend(buffer: newBuffer(rect(0, 0, width, height)), cursorVisible: true)

proc size*(b: TestBackend): Size =
  size(b.buffer.area.width.int, b.buffer.area.height.int)

proc draw*(b: var TestBackend, patches: seq[BufferPatch]) =
  ## Apply patches to the in-memory buffer.
  for p in patches:
    b.buffer[p.x.int, p.y.int] = p.cell

proc flush*(b: var TestBackend) = discard
proc hideCursor*(b: var TestBackend) = b.cursorVisible = false
proc showCursor*(b: var TestBackend) = b.cursorVisible = true
proc setCursorPos*(b: var TestBackend, p: Position) = b.cursor = p
proc getCursorPos*(b: TestBackend): Position = b.cursor
proc clear*(b: var TestBackend) = b.buffer.reset()
proc enterRaw*(b: var TestBackend) = discard
proc leaveRaw*(b: var TestBackend) = discard
proc enterAltScreen*(b: var TestBackend) = discard
proc leaveAltScreen*(b: var TestBackend) = discard

proc render*(b: TestBackend): string =
  ## A plain-text snapshot of the buffer: one line per row, trailing spaces trimmed per line.
  runnableExamples:
    import niobium/core/buffer
    var tb = newTestBackend(3, 1)
    tb.buffer.setString(0, 0, "hi")
    doAssert tb.render() == "hi"
  for y in 0 ..< b.buffer.area.height.int:
    var row = ""
    for x in 0 ..< b.buffer.area.width.int:
      let c = b.buffer[x, y]
      if not c.skip:
        row.add c.symbol
    while row.len > 0 and row[^1] == ' ':
      row.setLen(row.len - 1)
    if y > 0: result.add "\n"
    result.add row
