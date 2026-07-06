## Display-width and grapheme helpers (ADR-0006).
##
## v1 uses a rune-level approximation: combining marks and other zero-width code points count as 0,
## a curated set of East-Asian-wide and emoji ranges count as 2, everything else counts as 1. This
## is sufficient for correct layout of common Latin/CJK/emoji text; full grapheme clustering is a
## documented follow-up.

import std/unicode

func isZeroWidth(r: Rune): bool =
  let c = r.int32
  # Combining marks and zero-width formatting characters.
  (c >= 0x0300 and c <= 0x036F) or # combining diacritical marks
  (c >= 0x1AB0 and c <= 0x1AFF) or (c >= 0x1DC0 and c <= 0x1DFF) or
    (c >= 0x20D0 and c <= 0x20FF) or (c >= 0xFE20 and c <= 0xFE2F) or c == 0x200B or
    c == 0x200C or c == 0x200D or c == 0xFEFF

func isWide(r: Rune): bool =
  let c = r.int32
  (c >= 0x1100 and c <= 0x115F) or # Hangul Jamo
  (c >= 0x2E80 and c <= 0x303E) or # CJK radicals .. Kangxi
  (c >= 0x3041 and c <= 0x33FF) or # Hiragana .. CJK symbols
  (c >= 0x3400 and c <= 0x4DBF) or # CJK Ext A
  (c >= 0x4E00 and c <= 0x9FFF) or # CJK Unified
  (c >= 0xA000 and c <= 0xA4CF) or # Yi
  (c >= 0xAC00 and c <= 0xD7A3) or # Hangul syllables
  (c >= 0xF900 and c <= 0xFAFF) or # CJK compatibility
  (c >= 0xFE30 and c <= 0xFE4F) or # CJK compatibility forms
  (c >= 0xFF00 and c <= 0xFF60) or # Fullwidth forms
  (c >= 0xFFE0 and c <= 0xFFE6) or (c >= 0x1F300 and c <= 0x1FAFF) or # emoji & symbols
  (c >= 0x20000 and c <= 0x3FFFD) # CJK Ext B+

func runeDisplayWidth*(r: Rune): int =
  ## Display width (0, 1, or 2 columns) of a single rune.
  if isZeroWidth(r):
    0
  elif isWide(r):
    2
  else:
    1

func displayWidth*(s: string): int =
  ## Sum of the display widths of every rune in `s`.
  runnableExamples:
    doAssert displayWidth("ab") == 2
    doAssert displayWidth("世界") == 4
  for r in s.runes:
    result += runeDisplayWidth(r)
