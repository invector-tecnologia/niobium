# Backend spec

- Parity: `backend::Backend` · ADR: 0002, 0007, 0008, 0012 · Tests: tests/test_terminal.nim
- Status: mirrored

## Purpose
The only place bytes reach the terminal. Encodes buffer patches; manages terminal lifecycle.

## API surface (the `Backend` concept)
- `draw(b; patches: openArray[BufferPatch]): Result[void, IoError]`.
- `hideCursor(b)` / `showCursor(b)` / `setCursorPos(b, pos)` / `getCursorPos(b)`.
- `clear(b)` / `size(b): Size` / `flush(b)`.
- `enterRaw(b)` / `leaveRaw(b)` / `enterAltScreen(b)` / `leaveAltScreen(b)`.

## Implementations
- `AnsiBackend` — termios raw mode + ANSI/SGR encoding + color degradation (ADR-0012).
- `TestBackend` — renders patches into an in-memory `Buffer` for assertions (ADR-0011).

## Behavior
1. `draw` emits minimal cursor moves and coalesces runs sharing a style before SGR (render-path
   rules).
2. `AnsiBackend` degrades color per detected capability; `TestBackend` records intended color.
3. Lifecycle toggles are idempotent and always restorable (ADR-0008).
4. No allocation per `draw` in steady state.

## Acceptance criteria
- [ ] `AnsiBackend` byte-output golden for representative patch sets (styles, moves, wide glyphs).
- [ ] Degradation mapping truth-table (truecolor→256→16).
- [ ] `TestBackend` round-trips a known buffer.
