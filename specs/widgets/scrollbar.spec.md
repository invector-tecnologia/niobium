# Scrollbar spec

- Parity: `widgets::Scrollbar` + `ScrollbarState` · Tests: tests/test_widgets.nim
- Status: mirrored

## Purpose
A vertical or horizontal scrollbar reflecting content position, rendered alongside a scrollable area.

## API surface
- `ScrollbarState = object { contentLength, position, viewportContentLength: int }`.
- `Scrollbar` with `orientation` (Vertical{Left,Right}/Horizontal{Top,Bottom}), `thumbStyle`,
  `trackStyle`, `thumbSymbol`, `trackSymbol`.
- `scrollbar(orientation = soVerticalRight, thumbStyle = defaultStyle(),
  trackStyle = defaultStyle(), thumbSymbol = "█", trackSymbol = "│")` constructor.
- `render(scrollbar, area, buf, state)`.

## Behavior
1. Thumb length ∝ `viewportContentLength / contentLength`; thumb offset ∝ `position / contentLength`.
2. Orientation selects axis and side placement.
3. When content fits the viewport, the thumb expands to fill the track.

## Acceptance criteria
- [ ] Goldens: top/middle/bottom positions; short/long content; horizontal.
