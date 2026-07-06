## Input events decoded from the terminal (ADR-0007).

import std/unicode

type
  KeyCode* = enum
    kcChar
    kcEnter
    kcTab
    kcBackTab
    kcBackspace
    kcEsc
    kcLeft
    kcRight
    kcUp
    kcDown
    kcHome
    kcEnd
    kcPageUp
    kcPageDown
    kcDelete
    kcInsert
    kcFunction
    kcNull

  KeyModifier* = enum
    kmShift
    kmAlt
    kmCtrl

  KeyEvent* = object
    code*: KeyCode
    rune*: Rune ## Valid when `code == kcChar`.
    function*: int ## Valid when `code == kcFunction` (1 = F1).
    mods*: set[KeyModifier]

  MouseKind* = enum
    mkDown
    mkUp
    mkDrag
    mkMoved
    mkScrollUp
    mkScrollDown

  MouseButton* = enum
    mbLeft
    mbMiddle
    mbRight
    mbNone

  MouseEvent* = object
    kind*: MouseKind
    button*: MouseButton
    col*, row*: int
    mods*: set[KeyModifier]

  EventKind* = enum
    evKey
    evMouse
    evResize
    evPaste
    evFocusGained
    evFocusLost

  Event* = object
    case kind*: EventKind
    of evKey: key*: KeyEvent
    of evMouse: mouse*: MouseEvent
    of evResize: width*, height*: int
    of evPaste: text*: string
    of evFocusGained, evFocusLost: discard

func keyEvent*(code: KeyCode, mods: set[KeyModifier] = {}): Event =
  ## A non-character key event.
  Event(kind: evKey, key: KeyEvent(code: code, mods: mods))

func charEvent*(r: Rune, mods: set[KeyModifier] = {}): Event =
  ## A character key event.
  Event(kind: evKey, key: KeyEvent(code: kcChar, rune: r, mods: mods))

func charEvent*(c: char, mods: set[KeyModifier] = {}): Event =
  charEvent(Rune(c.ord), mods)

func functionEvent*(n: int, mods: set[KeyModifier] = {}): Event =
  ## A function-key event (`n` = 1 for F1).
  Event(kind: evKey, key: KeyEvent(code: kcFunction, function: n, mods: mods))
