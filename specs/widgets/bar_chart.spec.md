# BarChart spec

- Parity: `widgets::BarChart` · Tests: tests/test_widgets.nim
- Status: mirrored

## Purpose
Vertical bars for labeled values using eighth-block glyphs for sub-cell resolution.

## API surface
- `Bar = object { value: int, label: string, style }`.
- `BarChart` with `bars`, `barWidth`, `barGap`, `max: Option[int]`, `barStyle`, `labelStyle`,
  `blk`.
- `bar(value, label = "", style = defaultStyle())` and `barChart(bars, barWidth = 1, barGap = 1,
  max = none(int), barStyle = defaultStyle(), blk = none(Block))` constructors.

## Behavior
1. Bar height scales to `value / max` (max defaults to the largest value) using eighth-block glyphs
   for sub-cell resolution.
2. When any bar has a label, the bottom row is reserved for labels; labels are centered within the
   bar width and truncated to fit.
3. `barWidth` and `barGap` control spacing; overflow bars are clipped.

## Acceptance criteria
- [ ] Goldens: multiple bars; explicit max; labels; sub-cell heights.
