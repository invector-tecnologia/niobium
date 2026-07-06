# Sparkline spec

- Parity: `widgets::Sparkline` · Tests: tests/test_widgets.nim
- Status: mirrored

## Purpose
A compact single-line trend using eighth-block glyphs.

## API surface
- `Sparkline` with `data: seq[int]`, `max: Option[int]`, `style`, `blk`.
- `sparkline(data, max = none(int), style = defaultStyle(), blk = none(Block))` constructor.

## Behavior
1. Each datum maps to one column; height uses one of eight block glyphs scaled to `value / max`.
2. `max` defaults to the data maximum; zero max renders empty.
3. More data than width clips from the left, keeping the most recent values visible.

## Acceptance criteria
- [ ] Goldens: rising/falling series; explicit max; overflow clipping.
