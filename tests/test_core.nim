import std/[options, unittest]

import ../src/niobium

suite "core: rect":
  test "edges and area":
    let r = rect(2, 3, 4, 5)
    check r.right == 6
    check r.bottom == 8
    check r.area == 20

  test "intersection and inner":
    check rect(0, 0, 2, 2).intersection(rect(1, 1, 2, 2)) == rect(1, 1, 1, 1)
    check rect(0, 0, 10, 10).inner(2, 1) == rect(2, 1, 6, 8)
    check rect(0, 0, 4, 4).inner(3).width == 0

suite "core: style":
  test "patch overlays set fields":
    let merged = defaultStyle().fg(Red).patch(defaultStyle().bg(Blue).add(mBold))
    check merged.fg == some(Red)
    check merged.bg == some(Blue)
    check mBold in merged.addMods

suite "core: text width":
  test "display width counts wide runes as two":
    check displayWidth("ab") == 2
    check displayWidth("世界") == 4
    check line("hello").width == 5

suite "core: buffer":
  test "setString writes and diff is minimal":
    var a = newBuffer(rect(0, 0, 10, 1))
    var b = newBuffer(rect(0, 0, 10, 1))
    b.setString(0, 0, "hi")
    var patches: seq[BufferPatch]
    diff(a, b, patches)
    check patches.len == 2
    check patches[0].cell.symbol == "h"

  test "wide glyph marks the trailing skip cell":
    var b = newBuffer(rect(0, 0, 4, 1))
    b.setString(0, 0, "世")
    check b[0, 0].symbol == "世"
    check b[1, 0].skip
