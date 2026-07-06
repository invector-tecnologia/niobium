# BarChart spec

- Parity: `widgets::BarChart` · Tests: tests/widgets/test_bar_chart.nim

## Purpose
Vertical (or horizontal) bars for labeled values, optionally grouped.

## API surface
- `Bar = object { value: uint64, label: Option[Line], textValue: Option[string], style }`.
- `BarGroup = object { label, bars: seq[Bar] }`.
- `BarChart` with `data: seq[BarGroup]`, `barWidth`, `barGap`, `groupGap`, `barStyle`, `valueStyle`,
  `labelStyle`, `max: Option[uint64]`, `direction`, `block`.

## Behavior
1. Bar height scales to `value / max` (max defaults to the largest value) using eighth-block glyphs
   for sub-cell resolution.
2. Value labels render inside/atop bars; group/bar labels render on the baseline.
3. `barWidth`, `barGap`, `groupGap` control spacing; overflow bars are clipped.

## Acceptance criteria
- [ ] Goldens: single group; multiple groups; explicit max; horizontal direction; sub-cell heights.
