## The ANSI + termios backend for Linux and macOS (ADR-0007, ADR-0008, ADR-0012).
##
## This is the only module that writes bytes to the terminal. It manages raw mode, the alternate
## screen, cursor visibility, and encodes buffer patches as SGR + cursor-move sequences with color
## degradation.

import std/[strutils, os]

import ../core/[rect, color, style, cell, buffer]

when defined(posix):
  import std/[termios, posix]

type
  ColorLevel* = enum
    clAnsi16   ## 16 colors only.
    clAnsi256  ## 8-bit palette.
    clTrueColor ## 24-bit.

  AnsiBackend* = object
    outFile: File
    level: ColorLevel
    hasStyle: bool
    curFg, curBg: Color
    curMods: set[Modifier]
    when defined(posix):
      savedTermios: Termios
      rawActive: bool

const esc = "\e["

proc detectLevel(): ColorLevel =
  let ct = getEnv("COLORTERM")
  if ct.contains("truecolor") or ct.contains("24bit"): return clTrueColor
  let term = getEnv("TERM")
  if term.contains("256"): return clAnsi256
  clAnsi16

proc newAnsiBackend*(f: File = stdout, level = detectLevel()): AnsiBackend =
  ## A backend writing to `f` (stdout by default), degrading color to `level`.
  AnsiBackend(outFile: f, level: level, curFg: Reset, curBg: Reset)

# --- color encoding / degradation (ADR-0012) ------------------------------------------------------

func nearest16(r, g, b: int): int =
  ## Map an RGB triple to the nearest of the 16 base ANSI colors (approximate).
  let
    luma = (r * 299 + g * 587 + b * 114) div 1000
    bright = if max(r, max(g, b)) > 170: 8 else: 0
  if max(r, max(g, b)) - min(r, min(g, b)) < 24:
    if luma < 64: 0 elif luma < 160: 8 else: 15
  else:
    var idx = 0
    if r > 96: idx = idx or 1
    if g > 96: idx = idx or 2
    if b > 96: idx = idx or 4
    (idx or bright)

func to256(r, g, b: int): int =
  ## Map an RGB triple to the 6x6x6 color cube (16..231).
  func c(v: int): int = (if v < 48: 0 elif v < 115: 1 else: (v - 35) div 40)
  16 + 36 * c(r) + 6 * c(g) + c(b)

proc colorSeq(c: Color, fg: bool, level: ColorLevel): string =
  let base = if fg: 30 else: 40
  case c.kind
  of ckReset:
    (if fg: "39" else: "49")
  of ckIndexed16:
    let n = c.idx16.int
    if n < 8: $(base + n) else: $((if fg: 90 else: 100) + n - 8)
  of ckIndexed256:
    (if fg: "38;5;" else: "48;5;") & $c.idx256.int
  of ckRgb:
    let (r, g, b) = (c.r.int, c.g.int, c.b.int)
    case level
    of clTrueColor: (if fg: "38;2;" else: "48;2;") & $r & ";" & $g & ";" & $b
    of clAnsi256: (if fg: "38;5;" else: "48;5;") & $to256(r, g, b)
    of clAnsi16:
      let n = nearest16(r, g, b)
      if n < 8: $(base + n) else: $((if fg: 90 else: 100) + n - 8)

proc modSeq(mods: set[Modifier]): string =
  var parts: seq[string]
  if mBold in mods: parts.add "1"
  if mDim in mods: parts.add "2"
  if mItalic in mods: parts.add "3"
  if mUnderlined in mods: parts.add "4"
  if mSlowBlink in mods: parts.add "5"
  if mRapidBlink in mods: parts.add "6"
  if mReversed in mods: parts.add "7"
  if mHidden in mods: parts.add "8"
  if mCrossedOut in mods: parts.add "9"
  parts.join(";")

proc emitStyle(b: var AnsiBackend, c: Cell) =
  if b.hasStyle and c.fg == b.curFg and c.bg == b.curBg and c.modifier == b.curMods:
    return
  var parts = @["0"]
  let ms = modSeq(c.modifier)
  if ms.len > 0: parts.add ms
  if c.fg.kind != ckReset: parts.add colorSeq(c.fg, true, b.level)
  if c.bg.kind != ckReset: parts.add colorSeq(c.bg, false, b.level)
  b.outFile.write esc & parts.join(";") & "m"
  b.hasStyle = true
  b.curFg = c.fg
  b.curBg = c.bg
  b.curMods = c.modifier

# --- Backend surface ------------------------------------------------------------------------------

proc size*(b: AnsiBackend): Size =
  ## Current terminal size, falling back to 80x24.
  when defined(posix):
    type WinSize = object
      row, col, xpixel, ypixel: cushort
    when defined(macosx):
      const TIOCGWINSZ = 0x40087468
    else:
      const TIOCGWINSZ = 0x5413
    var ws: WinSize
    if ioctl(cint(1), TIOCGWINSZ.culong, addr ws) == 0 and ws.col > 0'u16:
      return size(ws.col.int, ws.row.int)
  size(80, 24)

proc setCursorPos*(b: var AnsiBackend, p: Position) =
  b.outFile.write esc & $(p.y.int + 1) & ";" & $(p.x.int + 1) & "H"

proc draw*(b: var AnsiBackend, patches: seq[BufferPatch]) =
  ## Encode patches as cursor moves + SGR + symbols, minimizing redundant sequences.
  var lastX, lastY = -1
  for p in patches:
    if p.y.int != lastY or p.x.int != lastX:
      b.setCursorPos(pos(p.x.int, p.y.int))
    b.emitStyle(p.cell)
    b.outFile.write p.cell.symbol
    lastY = p.y.int
    lastX = p.x.int + max(1, p.cell.width)

proc flush*(b: var AnsiBackend) = b.outFile.flushFile()
proc hideCursor*(b: var AnsiBackend) = b.outFile.write esc & "?25l"
proc showCursor*(b: var AnsiBackend) = b.outFile.write esc & "?25h"
proc clear*(b: var AnsiBackend) = b.outFile.write esc & "2J"
proc enterAltScreen*(b: var AnsiBackend) = b.outFile.write esc & "?1049h"
proc leaveAltScreen*(b: var AnsiBackend) = b.outFile.write esc & "?1049l"

proc enterRaw*(b: var AnsiBackend) =
  ## Put the terminal into raw mode, saving the previous state.
  when defined(posix):
    if tcGetAttr(cint(0), addr b.savedTermios) == 0:
      var raw = b.savedTermios
      raw.c_iflag = raw.c_iflag and not (BRKINT or ICRNL or INPCK or ISTRIP or IXON)
      raw.c_oflag = raw.c_oflag and not (OPOST)
      raw.c_lflag = raw.c_lflag and not (ECHO or ICANON or IEXTEN or ISIG)
      raw.c_cc[VMIN] = 0.char
      raw.c_cc[VTIME] = 1.char
      discard tcSetAttr(cint(0), TCSAFLUSH, addr raw)
      b.rawActive = true

proc leaveRaw*(b: var AnsiBackend) =
  ## Restore the terminal to its pre-raw state.
  when defined(posix):
    if b.rawActive:
      discard tcSetAttr(cint(0), TCSAFLUSH, addr b.savedTermios)
      b.rawActive = false
