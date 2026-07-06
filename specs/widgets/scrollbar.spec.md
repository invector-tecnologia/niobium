# Scrollbar spec

- Parity: `widgets::Scrollbar` + `ScrollbarState` · Tests: tests/widgets/test_scrollbar.nim

## Purpose
A vertical or horizontal scrollbar reflecting content position, rendered alongside a scrollable area.

## API surface
- `ScrollbarState = object { contentLength, position, viewportContentLength: int }`.
- `Scrollbar` with `orientation` (Vertical{Left,Right}/Horizontal{Top,Bottom}), `thumbStyle`,
  `trackStyle`, `beginSymbol`, `endSymbol`, `thumbSymbol`, `trackSymbol`.
- `render(scrollbar, area, buf, state)`.

## Behavior
1. Thumb length ∝ `viewportContentLength / contentLength`; thumb offset ∝ `position / contentLength`.
2. Optional begin/end arrow symbols occupy the track ends.
3. When content fits the viewport, the track is full (or the bar is hidden per config).
4. Orientation selects axis and side placement.

## Acceptance criteria
- [ ] Goldens: top/middle/bottom positions; short/long content; with/without arrows; horizontal.
