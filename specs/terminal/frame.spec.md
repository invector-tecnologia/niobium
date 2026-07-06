# Frame & Terminal spec

- Parity: `Terminal`, `Frame` · ADR: 0001, 0002, 0008 · Tests: tests/terminal/test_terminal.nim

## Purpose
`Terminal[B]` owns the two buffers and the backend and drives the tick. `Frame` is the per-draw
handle widgets render into.

## API surface
- `Terminal[B]` with `newTerminal(backend, viewport = Fullscreen): Terminal[B]`.
- `draw(t; render: proc(f: var Frame)): Result[void, IoError]`.
- `Frame = object` exposing `area(): Rect`, `renderWidget(w, area)`, `renderStateful(w, area, state)`,
  `setCursor(pos)`, `count(): int`.
- `Widget = concept` with `render(area: Rect, buf: var Buffer)`.
- `StatefulWidget[S] = concept` with `render(area, buf, state: var S)`.
- `resize(t, area)` / autoresize on `Resize`.

## Behavior
1. `draw` builds a `Frame` over `nextBuffer`, runs `render`, diffs vs `currentBuffer`, dispatches
   patches to the backend, flushes, reconciles cursor, then `swap`s buffers and resets `next`.
2. If the user set a cursor via `Frame.setCursor`, it is shown at that position after draw; otherwise
   hidden.
3. On resize, both buffers are resized (allocation permitted) and a full redraw occurs next tick.
4. Steady-state `draw` allocates nothing.

## Acceptance criteria
- [ ] `TestBackend` golden after a `draw` composing Block + Paragraph.
- [ ] Cursor reconciliation (set vs unset).
- [ ] Resize path produces a correct full redraw.
- [ ] Allocation invariant across N draws.
