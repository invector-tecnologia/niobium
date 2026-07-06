# Event spec

- Parity: `event::{Event,KeyEvent,MouseEvent}` · ADR: 0007 · Tests: tests/test_event.nim, tests/fuzz/ansi_parser_smoke.nim
- Status: mirrored

## Purpose
Decode terminal input bytes into structured events for the application loop.

## API surface
- `Event` variant: `Key(KeyEvent)`, `Mouse(MouseEvent)`, `Resize(w,h)`, `Paste(string)`,
  `FocusGained`, `FocusLost`.
- `KeyEvent = object { code: KeyCode, mods: set[KeyModifier] }` where `KeyCode` covers chars, F-keys,
  arrows, Home/End/PgUp/PgDn, Enter, Tab, Backspace, Esc, Delete/Insert.
- `MouseEvent = object { kind, button, col, row, mods }`.
- `pollEvent(timeout): Option[Event]` — non-throwing; returns `none` on timeout.

## Behavior
1. Printable bytes → `Key(char)`; `0x01–0x1A` → `Ctrl+letter`.
2. CSI/SS3 sequences map per `docs/reference/terminal/ctlseqs.md`.
3. SGR mouse (`CSI < b;x;y M/m`) → `MouseEvent`; bracketed paste → `Paste`.
4. `SIGWINCH` surfaces as `Resize` on the next poll.
5. The parser is **total**: partial sequences are buffered; malformed input yields best-effort or is
   dropped — never a crash (fuzzed).

## Acceptance criteria
- [ ] Table-driven decode cases for keys, arrows, F-keys, mouse, paste.
- [ ] Fuzz smoke: random/truncated byte streams never crash and are fully consumed.
