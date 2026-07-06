import std/unittest

import ../src/niobium

suite "terminal: draw loop":
  test "composes block + paragraph via TestBackend":
    var term = newTerminal(newTestBackend(12, 3))
    term.draw proc(f: var Frame) =
      let b = initBlock(title = "T", borders = AllBorders)
      f.renderWidget(b, f.area)
      f.renderWidget(paragraph("hi"), b.inner(f.area))
    check term.backend.buffer[0, 0].symbol == "┌"
    check term.backend.buffer[1, 1].symbol == "h"

  test "cursor is hidden when unset, shown when set":
    var term = newTerminal(newTestBackend(5, 2))
    term.draw proc(f: var Frame) = discard
    check term.backend.cursorVisible == false
    term.draw proc(f: var Frame) = f.setCursor(pos(2, 1))
    check term.backend.cursorVisible == true
    check term.backend.cursor == pos(2, 1)
