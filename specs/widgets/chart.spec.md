# Chart spec

- Parity: `widgets::Chart` · Tests: tests/test_widgets.nim
- Status: mirrored

## Purpose
A minimal X/Y plot with one or more datasets and line or scatter rendering.

## API surface
- `Dataset = object { name, data: seq[(float,float)], marker, graphType, style }`.
- `Chart` with `datasets`, `xBounds`, `yBounds`, `blk`.
- `dataset(name, data, marker = mkDot, graphType = gtScatter, style = defaultStyle())` and
  `chart(datasets, xBounds, yBounds, blk = none(Block))` constructors.

## Behavior
1. Data coordinates map to the plotting rect via the explicit `xBounds`/`yBounds` (linear scale).
2. Markers render with the dataset's marker set (Dot/Block); lines interpolate between
   consecutive points.
3. Points outside bounds are clipped.

## Acceptance criteria
- [ ] Goldens: single line dataset; scatter; clipping.
