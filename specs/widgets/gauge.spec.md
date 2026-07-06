# Gauge spec

- Parity: `widgets::Gauge`, `widgets::LineGauge` · Tests: tests/test_widgets.nim
- Status: mirrored

## Purpose
Show progress as a filled bar (`Gauge`, block-based) or a single line (`LineGauge`).

## API surface
- `Gauge` with `ratio: float (0..1)` or `percent: uint16`, `label: Option[Line]`, `block`,
  `gaugeStyle`, `useUnicode: bool`.
- `LineGauge` with `ratio`, `label`, `filledStyle`, `unfilledStyle`, `block`.

## Behavior
1. `Gauge` fills `ratio * width` columns; with `useUnicode`, sub-cell resolution via eighth blocks.
2. The label is centered over the bar; text over the filled region uses the inverted style.
3. `ratio` is clamped to `[0, 1]`; `percent` maps to `ratio/100`.
4. `LineGauge` renders one row: filled/unfilled runs with a label prefix.

## Acceptance criteria
- [ ] Goldens: 0%, 50%, 100%; unicode sub-cell fill; centered label; LineGauge variants.
