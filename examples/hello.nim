## Interactive "hello world": a rounded block with a paragraph; press `q` to quit.
## Run with: `nim c -r --mm:orc examples/hello.nim`

import std/[options, unicode]

import tatui

proc main() =
  var term = newTerminal(newAnsiBackend())
  term.setup()
  defer: term.restore()

  var running = true
  while running:
    term.draw proc(f: var Frame) =
      let b = initBlock(title = " TaTUÍ ", borders = AllBorders, borderType = btRounded,
                        borderStyle = defaultStyle().fg(Cyan))
      f.renderWidget(b, f.area)
      f.renderWidget(
        paragraph(text("Hello, terminal!\n\nPress q to quit.")),
        b.inner(f.area))

    let ev = pollEvent(100)
    if ev.isSome and ev.get.kind == evKey:
      let k = ev.get.key
      if k.code == kcChar and k.rune == Rune('q'.ord): running = false
      if k.code == kcEsc: running = false

when isMainModule:
  main()
