# Control sequences — trimmed reference

Subset of xterm/ECMA-48 control sequences used by Niobium. `CSI` = `ESC [`, `SS3` = `ESC O`.

## Cursor & screen (output)

| Sequence | Effect |
|---|---|
| `CSI <row> ; <col> H` | move cursor to absolute 1-based position |
| `CSI ? 25 l` / `CSI ? 25 h` | hide / show cursor |
| `CSI 2 J` | clear entire screen |
| `CSI K` | clear to end of line |
| `CSI ? 1049 h` / `l` | enter / leave alternate screen |
| `CSI ? 1000 h` / `l` | enable / disable mouse (X10/normal tracking) |
| `CSI ? 1006 h` / `l` | enable / disable SGR mouse encoding |
| `CSI ? 2004 h` / `l` | enable / disable bracketed paste |

## Input (event reader, ADR-0007)

| Sequence | Event |
|---|---|
| single byte `0x20–0x7E` | printable key |
| `0x01–0x1A` | Ctrl+letter |
| `ESC` (lone) | Esc key |
| `CSI A/B/C/D` | Up/Down/Right/Left |
| `CSI H` / `CSI F` | Home / End |
| `CSI <n> ~` | Insert/Delete/PgUp/PgDn/F-keys (by `n`) |
| `SS3 P/Q/R/S` | F1–F4 |
| `CSI < b ; x ; y M/m` | SGR mouse press/release |
| `CSI 200~ ... CSI 201~` | bracketed paste start/end |

## Parser contract
The decoder must be total: partial sequences are buffered, malformed ones yield a best-effort event
or are dropped — never a crash. Verified by `tests/fuzz/ansi_parser_smoke.nim`.
