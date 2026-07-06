## Structured styled text: `Span` -> `Line` -> `Text` (ADR-0005, ADR-0006).
##
## Widths use grapheme display width, not byte or code-point counts.

import std/strutils

import ./style
import ./unicodewidth

type
  Alignment* = enum
    alLeft
    alCenter
    alRight

  Span* = object
    content*: string
    style*: Style

  Line* = object
    spans*: seq[Span]
    alignment*: Alignment
    style*: Style

  Text* = object
    lines*: seq[Line]
    style*: Style

func span*(content: string, style = defaultStyle()): Span =
  ## A styled string fragment.
  Span(content: content, style: style)

func width*(s: Span): int =
  ## Display width of the span's content.
  displayWidth(s.content)

func line*(spans: openArray[Span], alignment = alLeft, style = defaultStyle()): Line =
  ## A line composed of spans.
  Line(spans: @spans, alignment: alignment, style: style)

func line*(s: string, style = defaultStyle()): Line =
  ## A single-span line from a plain string.
  Line(spans: @[span(s, style)], style: style)

func width*(l: Line): int =
  ## Sum of the widths of the line's spans.
  runnableExamples:
    doAssert line("abc").width == 3
  for s in l.spans:
    result += s.width

func text*(lines: openArray[Line], style = defaultStyle()): Text =
  ## Multi-line styled text.
  Text(lines: @lines, style: style)

func text*(s: string, style = defaultStyle()): Text =
  ## Text from a plain string, split on newlines.
  var ls: seq[Line]
  for chunk in s.split('\n'):
    ls.add line(chunk, style)
  Text(lines: ls, style: style)

func width*(t: Text): int =
  ## Width of the widest line.
  for l in t.lines:
    result = max(result, l.width)

func height*(t: Text): int =
  ## Number of lines.
  t.lines.len
