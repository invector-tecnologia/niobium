# 0006. Unicode width and grapheme handling

- Status: accepted
- Date: 2026-07-06

## Context
Wide (CJK, emoji) glyphs occupy two terminal columns; combining marks and ZWJ sequences form single
grapheme clusters. Incorrect width corrupts the diff for the entire frame.

## Decision
- A cell holds one **grapheme cluster**, not one code point.
- Display width is computed per grapheme (0/1/2 columns) using a width table in
  `docs/reference/terminal/`.
- A width-2 grapheme occupies two cells; the trailing cell is marked `skip = true` and is not
  independently written or diffed.
- Writers advance the cursor by display width and clear the trailing `skip` cell. Truncation never
  splits a wide grapheme (pad with a space if one column remains).

## Consequences
- Correct rendering of international text and emoji; stable diffs.
- Requires a grapheme segmentation routine and a width table (bundled reference, no heavy runtime
  dependency).

## Alternatives considered
- Code-point cells: rejected — breaks combining marks and wide glyphs.
- Ignoring width: rejected — corrupts layout and diffing.
