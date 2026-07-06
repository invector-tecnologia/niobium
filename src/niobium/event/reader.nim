## The ANSI input decoder + poller (ADR-0007).
##
## `decodeAll` is a total parser: any byte stream yields best-effort events and never crashes;
## a trailing partial escape sequence is simply left unconsumed. `pollEvent` reads stdin under raw
## mode (Linux/macOS) and returns the next decoded event, if any.

import std/[options, strutils, unicode]

import ./event

when defined(posix):
  import std/posix

type DecodeResult = object
  event: Option[Event]
  consumed: int ## Bytes consumed; 0 means "need more input".

func isFinalCsi(c: char): bool =
  (c >= 'A' and c <= 'Z') or (c >= 'a' and c <= 'z') or c == '~'

proc parseCsi(buf: string, start: int): DecodeResult =
  ## Parse a CSI sequence beginning at `buf[start]` == '['. `start-1` is ESC.
  var i = start + 1
  var params = ""
  while i < buf.len and not isFinalCsi(buf[i]):
    params.add buf[i]
    inc i
  if i >= buf.len:
    return DecodeResult(consumed: 0) # incomplete
  let final = buf[i]
  let consumed = i - (start - 1) + 1
  var ev: Option[Event]

  if params.len > 0 and params[0] == '<':
    # SGR mouse: <b;x;y M/m
    let body = params[1 .. ^1]
    let fields = body.split(';')
    if fields.len == 3:
      try:
        let b = parseInt(fields[0])
        let x = parseInt(fields[1])
        let y = parseInt(fields[2])
        var me = MouseEvent(col: x - 1, row: y - 1)
        if (b and 64) != 0:
          me.kind = if (b and 1) != 0: mkScrollDown else: mkScrollUp
        elif final == 'm':
          me.kind = mkUp
        else:
          me.kind = mkDown
        me.button = case (b and 3)
          of 0: mbLeft
          of 1: mbMiddle
          of 2: mbRight
          else: mbNone
        ev = some(Event(kind: evMouse, mouse: me))
      except ValueError:
        discard
    return DecodeResult(event: ev, consumed: consumed)

  case final
  of 'A': ev = some(keyEvent(kcUp))
  of 'B': ev = some(keyEvent(kcDown))
  of 'C': ev = some(keyEvent(kcRight))
  of 'D': ev = some(keyEvent(kcLeft))
  of 'H': ev = some(keyEvent(kcHome))
  of 'F': ev = some(keyEvent(kcEnd))
  of 'Z': ev = some(keyEvent(kcBackTab, {kmShift}))
  of 'I': ev = some(Event(kind: evFocusGained))
  of 'O': ev = some(Event(kind: evFocusLost))
  of '~':
    var n = 0
    try:
      if params.len > 0: n = parseInt(params.split(';')[0])
    except ValueError: n = 0
    ev = case n
      of 1, 7: some(keyEvent(kcHome))
      of 2: some(keyEvent(kcInsert))
      of 3: some(keyEvent(kcDelete))
      of 4, 8: some(keyEvent(kcEnd))
      of 5: some(keyEvent(kcPageUp))
      of 6: some(keyEvent(kcPageDown))
      of 11, 12, 13, 14, 15: some(functionEvent(n - 10))
      of 17, 18, 19, 20, 21: some(functionEvent(n - 11))
      of 23, 24: some(functionEvent(n - 12))
      else: none(Event)
  else: discard
  DecodeResult(event: ev, consumed: consumed)

proc decodeOne(buf: string, start: int): DecodeResult =
  ## Decode a single event starting at `buf[start]`. `consumed == 0` means more input is needed.
  let c = buf[start]
  case c
  of '\e':
    if start + 1 >= buf.len:
      return DecodeResult(consumed: 0)
    case buf[start + 1]
    of '[': parseCsi(buf, start + 1)
    of 'O':
      if start + 2 >= buf.len: return DecodeResult(consumed: 0)
      let f = buf[start + 2]
      let ev = case f
        of 'P': some(functionEvent(1))
        of 'Q': some(functionEvent(2))
        of 'R': some(functionEvent(3))
        of 'S': some(functionEvent(4))
        else: none(Event)
      DecodeResult(event: ev, consumed: 3)
    else:
      # Alt + next byte.
      DecodeResult(event: some(charEvent(buf[start + 1], {kmAlt})), consumed: 2)
  of '\r', '\n': DecodeResult(event: some(keyEvent(kcEnter)), consumed: 1)
  of '\t': DecodeResult(event: some(keyEvent(kcTab)), consumed: 1)
  of '\x7f', '\b': DecodeResult(event: some(keyEvent(kcBackspace)), consumed: 1)
  of '\x01' .. '\x07', '\x0b', '\x0c', '\x0e' .. '\x1a':
    # Ctrl + letter (Enter/Tab/Backspace handled above).
    let letter = Rune(ord('a') + (c.ord - 1))
    DecodeResult(event: some(charEvent(letter, {kmCtrl})), consumed: 1)
  else:
    # A (possibly multi-byte) UTF-8 rune.
    if (c.ord and 0x80) == 0:
      DecodeResult(event: some(charEvent(c)), consumed: 1)
    else:
      let need =
        if (c.ord and 0xE0) == 0xC0: 2
        elif (c.ord and 0xF0) == 0xE0: 3
        elif (c.ord and 0xF8) == 0xF0: 4
        else: 1
      if start + need > buf.len:
        return DecodeResult(consumed: 0)
      var r: Rune
      var idx = start
      fastRuneAt(buf, idx, r, true)
      DecodeResult(event: some(charEvent(r)), consumed: max(1, idx - start))

proc decodeAll*(data: string): tuple[events: seq[Event], consumed: int] =
  ## Decode as many events as possible from `data`. Never raises. Returns the events and the number
  ## of bytes consumed (a trailing partial sequence is left for the next call).
  var i = 0
  while i < data.len:
    let r = decodeOne(data, i)
    if r.consumed == 0:
      break
    if r.event.isSome:
      result.events.add r.event.get
    i += r.consumed
  result.consumed = i

# --- Live polling ---------------------------------------------------------------------------------

var pending {.threadvar.}: string
var queue {.threadvar.}: seq[Event]

proc pollEvent*(timeoutMs = 100): Option[Event] =
  ## Read stdin (raw mode) and return the next decoded event, or `none` on timeout.
  ## The caller is expected to have put the terminal into raw mode via the backend.
  if queue.len > 0:
    result = some(queue[0])
    queue.delete(0)
    return
  when defined(posix):
    var fds: TFdSet
    FD_ZERO(fds)
    FD_SET(cint(0), fds)
    var tv = Timeval(tv_sec: posix.Time(timeoutMs div 1000),
                     tv_usec: Suseconds((timeoutMs mod 1000) * 1000))
    if select(cint(1), addr fds, nil, nil, addr tv) > 0:
      var buf: array[64, char]
      let n = read(cint(0), addr buf[0], 64)
      for k in 0 ..< n:
        pending.add buf[k]
    if pending.len > 0:
      let r = decodeAll(pending)
      if r.consumed > 0:
        pending = pending[r.consumed .. ^1]
      for e in r.events:
        queue.add e
      if queue.len > 0:
        result = some(queue[0])
        queue.delete(0)
  else:
    result = none(Event)
