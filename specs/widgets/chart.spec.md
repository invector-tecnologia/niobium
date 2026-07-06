# Chart spec

- Parity: `widgets::Chart` · Tests: tests/widgets/test_chart.nim

## Purpose
An X/Y chart with labeled axes and one or more datasets (line/scatter/bar markers via braille or
block markers).

## API surface
- `Axis = object { title: Option[Line], bounds: (float, float), labels: seq[Span], style }`.
- `Dataset = object { name, data: seq[(float,float)], marker, graphType, style }`.
- `Chart` with `datasets`, `xAxis`, `yAxis`, `block`, `legendPosition`, `hiddenLegendConstraints`.

## Behavior
1. Data coordinates map to the plotting rect via axis `bounds` (linear scale).
2. Markers render with the dataset's marker set (Braille/Dot/Block); lines interpolate between
   consecutive points.
3. Axis labels render along each axis within bounds; the legend renders per `legendPosition` unless
   it violates `hiddenLegendConstraints`.
4. Points outside bounds are clipped.

## Acceptance criteria
- [ ] Goldens: single line dataset; scatter; two datasets + legend; axis labels; clipping.
