# Canvas spec (v0.2 candidate)

- Parity: `widgets::canvas::Canvas` · Tests: tests/widgets/test_canvas.nim
- Status: **deferred to v0.2** unless promoted (see plan Further Considerations).

## Purpose
A coordinate-space drawing surface using braille/block markers for sub-cell resolution: lines,
points, rectangles, and predefined shapes (map, world).

## API surface
- `Canvas` with `xBounds`, `yBounds`, `marker`, `block`, and a `paint: proc(ctx: var Context)`.
- `Context` drawing ops: `draw(shape)`, `print(x, y, span)`, `layer()`.
- Shapes: `Line`, `Points`, `Rectangle`, `Map`, `Circle`.

## Behavior
1. World coordinates map to the grid via bounds; the marker set determines sub-cell resolution.
2. `layer()` flushes current shapes to the buffer so later shapes overwrite earlier ones.
3. Out-of-bounds geometry is clipped.

## Acceptance criteria
- [ ] Goldens: line; points; rectangle; layered composition; braille vs block markers.
