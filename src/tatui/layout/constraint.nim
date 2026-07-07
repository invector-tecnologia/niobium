## Layout constraints and direction (ADR-0004). No absolute coordinates: a `Rect` is split into
## segments described by these constraints.

type
  Direction* = enum
    Horizontal
    Vertical

  ConstraintKind* = enum
    conLength
    conPercentage
    conRatio
    conMin
    conMax
    conFill

  Constraint* = object
    case kind*: ConstraintKind
    of conLength: length*: int
    of conPercentage: percent*: int
    of conRatio: num*, den*: int
    of conMin: minVal*: int
    of conMax: maxVal*: int
    of conFill: weight*: int

func length*(n: int): Constraint =
  ## A fixed number of cells.
  Constraint(kind: conLength, length: n)

func pct*(p: int): Constraint =
  ## A percentage (0..100) of the available extent.
  Constraint(kind: conPercentage, percent: p)

func ratio*(num, den: int): Constraint =
  ## A `num/den` fraction of the available extent.
  Constraint(kind: conRatio, num: num, den: den)

func minSize*(n: int): Constraint =
  ## A minimum number of cells.
  Constraint(kind: conMin, minVal: n)

func maxSize*(n: int): Constraint =
  ## A maximum number of cells.
  Constraint(kind: conMax, maxVal: n)

func fill*(weight = 1): Constraint =
  ## Take leftover space, split proportionally to `weight`.
  Constraint(kind: conFill, weight: weight)
