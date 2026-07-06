# Viewport spec

- Parity: `Viewport` · ADR: 0001 · Tests: tests/terminal/test_viewport.nim

## Purpose
Where Niobium draws within the terminal.

## API surface
- `Viewport = enum-like variant`: `Fullscreen`, `Inline(height)`, `Fixed(rect)`.

## Behavior
1. `Fullscreen` uses the whole terminal on the alternate screen.
2. `Inline(height)` reserves `height` rows below the cursor on the main screen, scrolling prior
   content into scrollback; it does not enter the alternate screen.
3. `Fixed(rect)` renders only within `rect`.
4. Resize recomputes the drawable area per mode.

## Acceptance criteria
- [ ] Area computation per mode for a given terminal size.
- [ ] `Inline` reserves the correct number of rows and preserves scrollback.
