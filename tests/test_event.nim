import std/[unicode, unittest]

import ../src/niobium

suite "event: decode":
  test "chars, arrows, enter":
    let r = decodeAll("a\e[A\r")
    check r.events.len == 3
    check r.events[0].key.code == kcChar
    check r.events[0].key.rune == Rune('a'.ord)
    check r.events[1].key.code == kcUp
    check r.events[2].key.code == kcEnter

  test "ctrl and function keys":
    let r = decodeAll("\x03\eOP")
    check r.events[0].key.code == kcChar
    check kmCtrl in r.events[0].key.mods
    check r.events[1].key.code == kcFunction
    check r.events[1].key.function == 1

  test "sgr mouse":
    let r = decodeAll("\e[<0;5;7M")
    check r.events[0].kind == evMouse
    check r.events[0].mouse.col == 4
    check r.events[0].mouse.row == 6
    check r.events[0].mouse.kind == mkDown

  test "trailing partial escape is left unconsumed":
    let r = decodeAll("ab\e[")
    check r.events.len == 2
    check r.consumed == 2
