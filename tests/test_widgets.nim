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

suite "widgets: clear":
  test "clears only the target sub-rect":
    var buf = newBuffer(rect(0, 0, 5, 3))
    for y in 0 ..< 3:
      buf.setString(0, y, "xxxxx")
    Clear().render(rect(1, 1, 3, 1), buf)
    check buf[0, 0].symbol == "x"
    check buf[1, 1].symbol == " "
    check buf[2, 1].symbol == " "
    check buf[3, 1].symbol == " "
    check buf[4, 2].symbol == "x"

suite "widgets: table":
  test "truncates cells to column widths with spacing":
    let t = table(@[row(["toolong", "wide"])], @[length(3), length(2)], columnSpacing = 1)
    var state: TableState
    var buf = newBuffer(rect(0, 0, 6, 1))
    t.render(rect(0, 0, 6, 1), buf, state)
    check buf[0, 0].symbol == "t"
    check buf[1, 0].symbol == "o"
    check buf[2, 0].symbol == "o"
    check buf[3, 0].symbol == " "
    check buf[4, 0].symbol == "w"
    check buf[5, 0].symbol == "i"

  test "keeps header fixed and scrolls selection into view":
    let t = table(
      @[row(["r0", "a0"]), row(["r1", "a1"]), row(["r2", "a2"])],
      @[length(2), length(2)],
      header = some(row(["H0", "H1"])),
      highlightStyle = defaultStyle().fg(Red),
      highlightSymbol = "> "
    )
    var state: TableState
    state.selected = some(2)
    var buf = newBuffer(rect(0, 0, 7, 3))
    t.render(rect(0, 0, 7, 3), buf, state)
    check state.offset == 1
    check buf[2, 0].symbol == "H"
    check buf[0, 2].symbol == ">"
    check buf[2, 2].symbol == "r"
    check buf[2, 2].fg == Red

suite "widgets: tabs":
  test "renders divider, highlights selection, and truncates overflow":
    let t = tabs(["Hello", "World"], selected = 1, highlightStyle = defaultStyle().fg(Red),
        divider = "|")
    let tb = renderOnce(t, 7, 1)
    check tb.render() == "Hello|W"
    check tb.buffer[6, 0].fg == Red

suite "widgets: bar chart":
  test "renders scaled bars with labels":
    let c = barChart([bar(4, "A"), bar(8, "B")], max = some(8))
    let tb = renderOnce(c, 3, 4)
    check tb.buffer[0, 1].symbol == "▄"
    check tb.buffer[0, 2].symbol == "█"
    check tb.buffer[2, 0].symbol == "█"
    check tb.buffer[2, 3].symbol == "B"

suite "widgets: sparkline":
  test "clips to width from the right and respects explicit max":
    let s = sparkline([1, 2, 3, 4, 5], max = some(5))
    let tb = renderOnce(s, 3, 1)
    check tb.render() == "▄▆█"

suite "widgets: chart":
  test "plots in-bounds points and clips out-of-bounds ones":
    let ds = dataset("p", [(0.0, 0.0), (4.0, 4.0), (10.0, 10.0)], marker = mkBlock)
    let c = chart([ds], (lo: 0.0, hi: 4.0), (lo: 0.0, hi: 4.0))
    let tb = renderOnce(c, 5, 5)
    check tb.buffer[0, 4].symbol == "█"
    check tb.buffer[4, 0].symbol == "█"
    check tb.buffer[4, 4].symbol == " "

suite "widgets: scrollbar":
  test "renders vertical thumb at the expected offset":
    let s = scrollbar()
    let state = ScrollbarState(contentLength: 10, position: 3, viewportContentLength: 4)
    var buf = newBuffer(rect(0, 0, 1, 4))
    s.render(rect(0, 0, 1, 4), buf, state)
    check buf[0, 0].symbol == "│"
    check buf[0, 1].symbol == "█"
    check buf[0, 2].symbol == "│"

  test "renders horizontal thumb at the expected offset":
    let s = scrollbar(orientation = soHorizontalBottom, trackSymbol = "-")
    let state = ScrollbarState(contentLength: 10, position: 5, viewportContentLength: 5)
    var buf = newBuffer(rect(0, 0, 4, 1))
    s.render(rect(0, 0, 4, 1), buf, state)
    check buf[0, 0].symbol == "-"
    check buf[1, 0].symbol == "-"
    check buf[2, 0].symbol == "█"
    check buf[3, 0].symbol == "█"
