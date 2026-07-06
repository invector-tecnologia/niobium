---
name: ansi-escape-codes
description: "Use when working on Niobium's ANSI backend or event parser: SGR styling, cursor movement, raw mode, alt screen, mouse capture, or decoding input escape sequences. Triggers: ANSI, escape sequence, SGR, CSI, termios, raw mode, alt screen, cursor move, color degradation, mouse, bracketed paste."
---

# ANSI escape codes

Only `src/niobium/backend/` and the event `reader` emit/decode escape sequences.

## Output (backend)
- Style via SGR (`CSI ... m`). Reset with `CSI 0 m` only when needed; track current style to avoid
  redundant sequences.
- Move the cursor with absolute positioning (`CSI row ; col H`) only when the next changed cell is
  not adjacent; otherwise let natural advance handle it. Minimize total bytes.
- Color degradation: truecolor (`38;2;r;g;b`) → 256 (`38;5;n`) → 16, chosen by backend capability
  (ADR-0012).
- Lifecycle: enter raw mode (termios) + alt screen (`CSI ? 1049 h`) + optional mouse capture on init;
  restore all on teardown via `defer`/destructor, even on panic (ADR-0008).

## Input (event reader)
- Decode CSI/SS3 sequences into key/mouse/resize/paste events (ADR-0007).
- The parser must be total: malformed or partial sequences yield a best-effort event or are buffered,
  never crash. Fuzzed by `tests/fuzz/ansi_parser_smoke.nim`.

## References
Trimmed ECMA-48 SGR table and xterm ctlseqs subset live in `docs/reference/terminal/`.
