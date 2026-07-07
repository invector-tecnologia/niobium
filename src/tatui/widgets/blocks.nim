## The `Block` container: borders, a title, and padding (ratatui `widgets::Block`).

import ../core/[rect, style, buffer, text]
import ./draw

type
  Side* = enum
    sTop
    sRight
    sBottom
    sLeft

  Borders* = set[Side]

  BorderType* = enum
    btPlain
    btRounded
    btDouble
    btThick

  Padding* = object
    left*, right*, top*, bottom*: int

  Block* = object
    borders*: Borders
    borderType*: BorderType
    borderStyle*: Style
    title*: string
    titleAlignment*: Alignment
    titleStyle*: Style
    style*: Style
    padding*: Padding

const AllBorders* = {sTop, sRight, sBottom, sLeft}

func padding*(all: int): Padding =
  Padding(left: all, right: all, top: all, bottom: all)

func padding*(horizontal, vertical: int): Padding =
  Padding(left: horizontal, right: horizontal, top: vertical, bottom: vertical)

func initBlock*(
    title = "",
    borders: Borders = {},
    borderType = btPlain,
    borderStyle = defaultStyle(),
    style = defaultStyle(),
    titleAlignment = alLeft,
    titleStyle = defaultStyle(),
    padding = Padding(),
): Block =
  ## Construct a block. With no borders it is just an optional background + padding.
  Block(
    title: title,
    borders: borders,
    borderType: borderType,
    borderStyle: borderStyle,
    style: style,
    titleAlignment: titleAlignment,
    titleStyle: titleStyle,
    padding: padding,
  )

func glyphs(bt: BorderType): tuple[h, v, tl, tr, bl, br: string] =
  case bt
  of btPlain:
    ("─", "│", "┌", "┐", "└", "┘")
  of btRounded:
    ("─", "│", "╭", "╮", "╰", "╯")
  of btDouble:
    ("═", "║", "╔", "╗", "╚", "╝")
  of btThick:
    ("━", "┃", "┏", "┓", "┗", "┛")

func inner*(b: Block, area: Rect): Rect =
  ## The area inside the block's drawn borders and padding.
  var l = area.left + b.padding.left
  var t = area.top + b.padding.top
  var r = area.right - b.padding.right
  var bot = area.bottom - b.padding.bottom
  if sLeft in b.borders:
    inc l
  if sTop in b.borders:
    inc t
  if sRight in b.borders:
    dec r
  if sBottom in b.borders:
    dec bot
  rect(l, t, max(0, r - l), max(0, bot - t))

proc render*(b: Block, area: Rect, buf: var Buffer) =
  ## Draw the block's background, borders, and title into `area`.
  if area.isEmpty:
    return
  fillStyle(buf, area, b.style)
  let g = glyphs(b.borderType)
  let bs = b.borderStyle
  if sTop in b.borders:
    for x in area.left ..< area.right:
      buf.setStringN(x, area.top, g.h, bs, 1)
  if sBottom in b.borders:
    for x in area.left ..< area.right:
      buf.setStringN(x, area.bottom - 1, g.h, bs, 1)
  if sLeft in b.borders:
    for y in area.top ..< area.bottom:
      buf.setStringN(area.left, y, g.v, bs, 1)
  if sRight in b.borders:
    for y in area.top ..< area.bottom:
      buf.setStringN(area.right - 1, y, g.v, bs, 1)
  if {sTop, sLeft} <= b.borders:
    buf.setStringN(area.left, area.top, g.tl, bs, 1)
  if {sTop, sRight} <= b.borders:
    buf.setStringN(area.right - 1, area.top, g.tr, bs, 1)
  if {sBottom, sLeft} <= b.borders:
    buf.setStringN(area.left, area.bottom - 1, g.bl, bs, 1)
  if {sBottom, sRight} <= b.borders:
    buf.setStringN(area.right - 1, area.bottom - 1, g.br, bs, 1)

  if b.title.len > 0 and area.width.int > 2:
    let avail = area.width.int - 2
    let off = alignOffset(b.titleAlignment, avail, b.title.len)
    buf.setStringN(area.left + 1 + off, area.top, b.title, b.titleStyle, avail)
