# Text spec

- Parity: `text::{Span,Line,Text}` · ADR: 0005, 0006 · Tests: tests/test_core.nim
- Status: mirrored

## Purpose
Structured styled text: the input to text-rendering widgets (Paragraph, List, Table cells).

## API surface
- `Span = object { content: string, style: Style }`.
- `Line = object { spans: seq[Span], alignment: Alignment }`.
- `Text = object { lines: seq[Line], style: Style }`.
- Constructors: `span(s, style)`, `line(spans, align = Left)`, `text(lines)`.
- `width(span|line): int` — sum of grapheme display widths.
- `styled(t, s): Text` — apply a base style beneath existing spans.

## Behavior
1. `width` uses grapheme display width (ADR-0006), not code-point or byte count.
2. A `Line`'s width is the sum of its spans' widths; empty line width is 0.
3. Applying a base style does not override per-span styles (patch beneath).
4. `Alignment` ∈ { Left, Center, Right } and is honored by rendering widgets, not by `Text` itself.

## Acceptance criteria
- [ ] Width correctness for mixed ASCII/CJK/emoji spans.
- [ ] Base-style application preserves per-span overrides.
