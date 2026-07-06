# 0005. Text and style model

- Status: accepted
- Date: 2026-07-06

## Context
Widgets render styled text, not raw characters. ratatui models this as `Text → Line → Span`, with
`Style`, `Color`, and bitflag `Modifier`.

## Decision
- `Span` = styled string fragment; `Line` = seq of spans + alignment; `Text` = seq of lines.
- `Style` carries `fg`, `bg`, optional `underlineColor`, and `modifier`.
- `Color` supports 16-color, 256-color, and truecolor (RGB); default/reset is a distinct variant.
- `Modifier` is a Nim `set[Modifier]` (idiomatic bitflags): bold, dim, italic, underlined, blink,
  reversed, hidden, crossedOut.
- Styles compose via patch semantics: applying a style overlays only its set fields.

## Consequences
- Clean, ratatui-faithful text API; `set` gives zero-cost flag math.
- Color degradation is handled at the backend (ADR-0012), not in the model.

## Alternatives considered
- Single flat styled-string type: rejected — no line/wrap structure for widgets.
- Enum of styles instead of `set`: rejected — cannot combine modifiers.
