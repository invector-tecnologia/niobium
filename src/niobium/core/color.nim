## Colors for the styling model (ADR-0005, ADR-0012).
##
## The model stores the author's intended color unchanged; the backend degrades it to the
## terminal's capability (truecolor -> 256 -> 16). `Reset` means "the terminal default".

type
  ColorKind* = enum
    ckReset      ## Terminal default color.
    ckIndexed16  ## One of the 16 ANSI colors (0..15).
    ckIndexed256 ## An 8-bit palette color (0..255).
    ckRgb        ## A 24-bit true color.

  Color* = object
    case kind*: ColorKind
    of ckReset: discard
    of ckIndexed16: idx16*: uint8
    of ckIndexed256: idx256*: uint8
    of ckRgb: r*, g*, b*: uint8

func `==`*(a, b: Color): bool =
  ## Structural equality for the variant `Color` type.
  if a.kind != b.kind: return false
  case a.kind
  of ckReset: true
  of ckIndexed16: a.idx16 == b.idx16
  of ckIndexed256: a.idx256 == b.idx256
  of ckRgb: a.r == b.r and a.g == b.g and a.b == b.b

func indexed*(n: int): Color =
  ## An 8-bit palette color.
  Color(kind: ckIndexed256, idx256: n.uint8)

func rgb*(r, g, b: int): Color =
  ## A 24-bit true color.
  runnableExamples:
    let c = rgb(255, 128, 0)
    doAssert c.kind == ckRgb
  Color(kind: ckRgb, r: r.uint8, g: g.uint8, b: b.uint8)

# The 16 standard ANSI colors.
const
  Reset* = Color(kind: ckReset)
  Black* = Color(kind: ckIndexed16, idx16: 0)
  Red* = Color(kind: ckIndexed16, idx16: 1)
  Green* = Color(kind: ckIndexed16, idx16: 2)
  Yellow* = Color(kind: ckIndexed16, idx16: 3)
  Blue* = Color(kind: ckIndexed16, idx16: 4)
  Magenta* = Color(kind: ckIndexed16, idx16: 5)
  Cyan* = Color(kind: ckIndexed16, idx16: 6)
  Gray* = Color(kind: ckIndexed16, idx16: 7)
  DarkGray* = Color(kind: ckIndexed16, idx16: 8)
  LightRed* = Color(kind: ckIndexed16, idx16: 9)
  LightGreen* = Color(kind: ckIndexed16, idx16: 10)
  LightYellow* = Color(kind: ckIndexed16, idx16: 11)
  LightBlue* = Color(kind: ckIndexed16, idx16: 12)
  LightMagenta* = Color(kind: ckIndexed16, idx16: 13)
  LightCyan* = Color(kind: ckIndexed16, idx16: 14)
  White* = Color(kind: ckIndexed16, idx16: 15)
