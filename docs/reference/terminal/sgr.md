# SGR (Select Graphic Rendition) — trimmed reference

Subset used by the Niobium ANSI backend. Sequence form: `CSI <params> m` where `CSI` = `ESC [`.

## Attributes

| Code | Effect | Niobium `Modifier` |
|---|---|---|
| 0 | reset all | — |
| 1 | bold | `Bold` |
| 2 | dim | `Dim` |
| 3 | italic | `Italic` |
| 4 | underline | `Underlined` |
| 5 | slow blink | `SlowBlink` |
| 6 | rapid blink | `RapidBlink` |
| 7 | reverse | `Reversed` |
| 8 | hidden | `Hidden` |
| 9 | crossed out | `CrossedOut` |
| 22 | normal intensity (clears 1,2) | — |
| 23 | not italic | — |
| 24 | not underlined | — |
| 25 | not blinking | — |
| 27 | not reversed | — |
| 28 | reveal (not hidden) | — |
| 29 | not crossed out | — |

## Colors

| Form | Foreground | Background |
|---|---|---|
| 16-color | `30–37`, bright `90–97` | `40–47`, bright `100–107` |
| 256-color | `38;5;<n>` | `48;5;<n>` |
| truecolor | `38;2;<r>;<g>;<b>` | `48;2;<r>;<g>;<b>` |
| default | `39` | `49` |

## Degradation (ADR-0012)
truecolor → nearest 256 → nearest 16, chosen by backend capability. Emit the richest form the
terminal supports.
