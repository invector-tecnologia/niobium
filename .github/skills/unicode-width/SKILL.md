---
name: unicode-width
description: "Use when handling text, graphemes, or cell width in Niobium: Span/Line/Text, wide (CJK/emoji) characters, the cell skip flag, or grapheme segmentation. Triggers: unicode, grapheme, wide char, CJK, emoji, width, skip flag, combining, ZWJ."
---

# Unicode width & graphemes

Correct cell width is a hard correctness requirement: a wrong width corrupts the diff for the whole
frame.

## Rules
- A cell holds one grapheme cluster, not one code point (combining marks, ZWJ emoji sequences).
- Display width per grapheme is 0, 1, or 2 columns.
- A width-2 grapheme occupies two cells: the first holds the symbol, the second is marked `skip=true`
  and is not independently written or diffed.
- Zero-width graphemes (combining marks) attach to the preceding cell.

## When writing to a buffer
- Advance the cursor by the grapheme's display width.
- Clear the trailing `skip` cell so stale glyph halves cannot leak through the diff.
- Truncation must never split a wide grapheme; pad with a space if only one column remains.

## References
`docs/reference/terminal/` for width tables; ADR-0006 for the chosen segmentation approach.
