## A non-interactive demo: compose several widgets into one frame and print the rendered text.
## Useful without a TTY. Run with: `nim c -r --mm:orc examples/demo.nim`

import std/options

import tatui

proc main() =
  var term = newTerminal(newTestBackend(48, 12))
  term.draw proc(f: var Frame) =
    let outer = initBlock(title = " Dashboard ", borders = AllBorders)
    f.renderWidget(outer, f.area)
    let inner = outer.inner(f.area)
    let rows = inner.split(Vertical, @[length(1), length(3), fill(1)])

    f.renderWidget(tabs(@["Home", "Stats", "About"], selected = 1,
                        highlightStyle = defaultStyle().fg(Yellow).add(mBold)), rows[0])
    f.renderWidget(gauge(0.42, blk = some(initBlock(title = "Progress",
                        borders = AllBorders))), rows[1])

    let cols = rows[2].split(Horizontal, @[pct(50), pct(50)])
    var items: seq[ListItem]
    for s in ["alpha", "beta", "gamma", "delta"]: items.add listItem(s)
    var st: ListState
    st.select(2)
    f.renderStateful(list(items, blk = some(initBlock(title = "List", borders = AllBorders)),
                          highlightSymbol = "> ",
                          highlightStyle = defaultStyle().fg(Green)), cols[0], st)
    f.renderWidget(sparkline(@[1, 3, 2, 5, 4, 7, 6, 8, 5, 9],
                             blk = some(initBlock(title = "Trend", borders = AllBorders))), cols[1])

  echo term.backend.render()

when isMainModule:
  main()
