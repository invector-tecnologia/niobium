## A single grid cell: a grapheme plus its style and a `skip` flag (ADR-0003, ADR-0006).
##
## v1 stores the symbol as a `string`. The public API (`symbol`/`setSymbol`) hides this so the
## representation can move to small-string-optimized storage later without breaking callers.

import std/options

import ./color
import ./style
import ./unicodewidth

type Cell* = object
  sym: string ## Grapheme cluster; empty is treated as a single space.
  fg*: Color
  bg*: Color
  underlineColor*: Color
  modifier*: set[Modifier]
  skip*: bool ## True for the trailing column of a wide (2-cell) glyph.

func symbol*(c: Cell): string =
  ## The cell's grapheme (a single space when unset).
  if c.sym.len == 0: " " else: c.sym

proc `symbol=`*(c: var Cell, s: string) =
  ## Set the cell's grapheme.
  c.sym = s

func width*(c: Cell): int =
  ## Display width of the cell's grapheme (0, 1, or 2).
  displayWidth(c.symbol)

func `==`*(a, b: Cell): bool =
  ## Structural equality (used by the diff to detect changed cells).
  a.symbol == b.symbol and a.fg == b.fg and a.bg == b.bg and
    a.underlineColor == b.underlineColor and a.modifier == b.modifier and
    a.skip == b.skip

func cell*(sym = " "): Cell =
  ## A cell holding `sym` with default (reset) colors and no modifiers.
  Cell(sym: sym, fg: Reset, bg: Reset, underlineColor: Reset)

proc reset*(c: var Cell) =
  ## Restore the cell to a blank space with default style, in place.
  c.sym = " "
  c.fg = Reset
  c.bg = Reset
  c.underlineColor = Reset
  c.modifier = {}
  c.skip = false

proc apply*(c: var Cell, s: Style) =
  ## Overlay a `Style` onto the cell using patch semantics.
  runnableExamples:
    import tatui/core/[color, style]
    var x = cell("a")
    x.apply(defaultStyle().fg(Red).add(mBold))
    doAssert x.fg == Red and mBold in x.modifier
  if s.fg.isSome:
    c.fg = s.fg.get
  if s.bg.isSome:
    c.bg = s.bg.get
  if s.underlineColor.isSome:
    c.underlineColor = s.underlineColor.get
  c.modifier = (c.modifier - s.subMods) + s.addMods
