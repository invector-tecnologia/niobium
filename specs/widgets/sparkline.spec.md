# Sparkline spec

- Parity: `widgets::Sparkline` · Tests: tests/widgets/test_sparkline.nim

## Purpose
A compact single-line trend using eighth-block glyphs.

## API surface
- `Sparkline` with `data: seq[uint64]`, `max: Option[uint64]`, `style`, `block`,
  `direction` (LeftToRight/RightToLeft), `absentValueStyle`.

## Behavior
1. Each datum maps to one column; height uses one of eight block glyphs scaled to `value / max`.
2. `max` defaults to the data maximum; zero max renders empty.
3. More data than width clips from the appropriate end per `direction`.
4. Absent values render blank with `absentValueStyle`.

## Acceptance criteria
- [ ] Goldens: rising/falling series; explicit max; overflow clipping; right-to-left.
