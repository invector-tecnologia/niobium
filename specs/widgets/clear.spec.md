# Clear spec

- Parity: `widgets::Clear` · Tests: tests/widgets/test_clear.nim

## Purpose
Reset every cell in an area to blank — used to punch a hole (e.g. behind a popup) before drawing.

## API surface
- `Clear` (unit widget); `render(Clear, area, buf)`.

## Behavior
1. Every cell in `area` is reset to a blank space with default style and `skip = false`.
2. No effect outside `area`.

## Acceptance criteria
- [ ] Golden: pre-filled buffer cleared within a sub-rect leaves surrounding cells untouched.
