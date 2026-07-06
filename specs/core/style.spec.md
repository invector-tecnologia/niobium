# Style & Color spec

- Parity: `style::{Style,Color,Modifier}` · ADR: 0005, 0012 · Tests: tests/core/test_style.nim

## Purpose
The styling model shared by text and cells. Stores author intent; degradation happens at the backend.

## API surface
- `Modifier = enum` { Bold, Dim, Italic, Underlined, SlowBlink, RapidBlink, Reversed, Hidden,
  CrossedOut }; used as `set[Modifier]`.
- `Color = object` (variant): `Reset`, `Indexed16(n)`, `Indexed256(n)`, `Rgb(r,g,b)`.
- `Style = object { fg, bg, underlineColor: Color, addMods, subMods: set[Modifier] }`.
- `style(...)` constructor with named args; fluent helpers `fg(s,c)`, `bg(s,c)`, `add(s,m)`.
- `patch(base, over): Style` — overlay set fields of `over` onto `base`.

## Behavior
1. `Color.Reset` means "terminal default"; distinct from any indexed/RGB value.
2. `patch` overlays only fields explicitly set in `over`; modifier add/sub sets compose
   (add wins over base, sub removes).
3. Style never performs color degradation; that is the backend's job (ADR-0012).

## Acceptance criteria
- [ ] Patch/compose truth-table (fg/bg/mods add & sub).
- [ ] Color variant round-trips preserve exact author value.
