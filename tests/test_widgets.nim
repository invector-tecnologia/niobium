import std/[options, strutils, unittest]

import ../src/niobium

proc renderOnce[W](w: W, width, height: int): TestBackend =
  result = newTestBackend(width, height)
  var buf = newBuffer(rect(0, 0, width, height))
  w.render(rect(0, 0, width, height), buf)
  var patches: seq[BufferPatch]
  diff(newBuffer(rect(0, 0, width, height)), buf, patches)
  result.draw(patches)

suite "widgets: block":
  test "full border draws corners and title":
    let b = initBlock(title = "Hi", borders = AllBorders)
    let tb = renderOnce(b, 8, 3)
    check tb.buffer[0, 0].symbol == "┌"
    check tb.buffer[7, 0].symbol == "┐"
    check tb.buffer[0, 2].symbol == "└"
    check tb.buffer[1, 0].symbol == "H"

  test "inner excludes borders":
    let b = initBlock(borders = AllBorders)
    check b.inner(rect(0, 0, 10, 10)) == rect(1, 1, 8, 8)

suite "widgets: paragraph":
  test "renders and wraps":
    let p = paragraph(text("hello world"), wrap = some(Wrap(trim: false)))
    let tb = renderOnce(p, 5, 3)
    check tb.render().splitLines()[0] == "hello"

suite "widgets: list selection":
  test "highlight symbol on selected row":
    let l = list(
      @[listItem("one"), listItem("two"), listItem("three")], highlightSymbol = "> "
    )
    var st: ListState
    st.select(1)
    var buf = newBuffer(rect(0, 0, 10, 3))
    l.render(rect(0, 0, 10, 3), buf, st)
    check buf[0, 1].symbol == ">"
    check buf[2, 1].symbol == "t"

  test "scrolls selection into view":
    var items: seq[ListItem]
    for i in 0 ..< 10:
      items.add listItem("item" & $i)
    let l = list(items)
    var st: ListState
    st.select(9)
    var buf = newBuffer(rect(0, 0, 10, 3))
    l.render(rect(0, 0, 10, 3), buf, st)
    check st.offset == 7

suite "widgets: gauge":
  test "half fill":
    let g = gauge(0.5)
    let tb = renderOnce(g, 10, 1)
    check tb.buffer[0, 0].symbol == "█"
    check tb.buffer[9, 0].symbol == " "
