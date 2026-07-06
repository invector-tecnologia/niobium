## Text styling: modifiers and the composable `Style` (ADR-0005).
##
## A `Style` carries optional foreground/background/underline colors plus modifier bits to add or
## remove. Unset colors mean "leave unchanged", which is what makes styles composable via `patch`.

import std/options

import ./color

type
  Modifier* = enum
    mBold
    mDim
    mItalic
    mUnderlined
    mSlowBlink
    mRapidBlink
    mReversed
    mHidden
    mCrossedOut

  Style* = object
    fg*: Option[Color]
    bg*: Option[Color]
    underlineColor*: Option[Color]
    addMods*: set[Modifier]
    subMods*: set[Modifier]

func defaultStyle*(): Style =
  ## An empty style: no color changes, no modifiers.
  Style()

func style*(fg = none(Color), bg = none(Color), mods: set[Modifier] = {}): Style =
  ## Construct a style from optional colors and a modifier set.
  runnableExamples:
    import std/options
    import niobium/core/color
    let s = style(fg = some(Red), mods = {mBold})
    doAssert s.addMods == {mBold}
  Style(fg: fg, bg: bg, addMods: mods)

func fg*(s: Style, c: Color): Style =
  ## Return a copy of `s` with the foreground color set.
  result = s
  result.fg = some(c)

func bg*(s: Style, c: Color): Style =
  ## Return a copy of `s` with the background color set.
  result = s
  result.bg = some(c)

func add*(s: Style, m: Modifier): Style =
  ## Return a copy of `s` that adds modifier `m`.
  result = s
  result.addMods.incl m
  result.subMods.excl m

func remove*(s: Style, m: Modifier): Style =
  ## Return a copy of `s` that removes modifier `m`.
  result = s
  result.subMods.incl m
  result.addMods.excl m

func patch*(base, over: Style): Style =
  ## Overlay the set fields of `over` onto `base` (patch semantics).
  runnableExamples:
    import std/options
    import niobium/core/color
    let merged = defaultStyle().fg(Red).patch(defaultStyle().bg(Blue))
    doAssert merged.fg == some(Red) and merged.bg == some(Blue)
  result = base
  if over.fg.isSome: result.fg = over.fg
  if over.bg.isSome: result.bg = over.bg
  if over.underlineColor.isSome: result.underlineColor = over.underlineColor
  result.addMods = (base.addMods - over.subMods) + over.addMods
  result.subMods = (base.subMods - over.addMods) + over.subMods
