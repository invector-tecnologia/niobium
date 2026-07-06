# 0012. Color degradation

- Status: accepted
- Date: 2026-07-06

## Context
Not all terminals support truecolor. Emitting 24-bit color to a 256- or 16-color terminal produces
wrong colors or garbage.

## Decision
- The **backend** degrades color based on detected terminal capability: truecolor → nearest 256 →
  nearest 16. The text/style model always stores the author's intended color unchanged.
- Capability is detected from environment (`COLORTERM`, `TERM`) with a manual override.
- Degradation mapping lives in the backend, keeping the core color-model pure.

## Consequences
- Correct-looking output across terminal capabilities without changing widget code.
- Nearest-color mapping is approximate; document the tables and allow override.

## Alternatives considered
- Always emit truecolor: rejected — breaks on limited terminals.
- Degrade in the style model: rejected — loses author intent and couples model to backend concerns.
