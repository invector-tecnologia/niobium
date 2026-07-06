## Scrollbar: a track + thumb reflecting content position (ratatui `widgets::Scrollbar`).

import ../core/[rect, style, buffer]

type
  ScrollbarOrientation* = enum
    soVerticalRight
    soVerticalLeft
    soHorizontalBottom
    soHorizontalTop

  Scrollbar* = object
    orientation*: ScrollbarOrientation
    thumbStyle*: Style
    trackStyle*: Style
    thumbSymbol*: string
    trackSymbol*: string

  ScrollbarState* = object
    contentLength*: int
    position*: int
    viewportContentLength*: int

func scrollbar*(orientation = soVerticalRight, thumbStyle = defaultStyle(),
                trackStyle = defaultStyle(), thumbSymbol = "█", trackSymbol = "│"): Scrollbar =
  ## Construct a scrollbar.
  Scrollbar(orientation: orientation, thumbStyle: thumbStyle, trackStyle: trackStyle,
            thumbSymbol: thumbSymbol, trackSymbol: trackSymbol)

func isVertical(o: ScrollbarOrientation): bool =
  o in {soVerticalRight, soVerticalLeft}

proc render*(s: Scrollbar, area: Rect, buf: var Buffer, state: ScrollbarState) =
  ## Draw the scrollbar along the appropriate edge of `area`.
  if area.isEmpty or state.contentLength <= 0: return
  let vertical = isVertical(s.orientation)
  let trackLen = if vertical: area.height.int else: area.width.int
  if trackLen <= 0: return

  var thumbLen = max(1, (state.viewportContentLength * trackLen) div max(1, state.contentLength))
  thumbLen = min(thumbLen, trackLen)
  let maxPos = max(1, state.contentLength - state.viewportContentLength)
  var thumbStart = (state.position * (trackLen - thumbLen)) div maxPos
  thumbStart = clamp(thumbStart, 0, trackLen - thumbLen)

  if vertical:
    let x = if s.orientation == soVerticalRight: area.right - 1 else: area.left
    for i in 0 ..< trackLen:
      let y = area.top + i
      let inThumb = i >= thumbStart and i < thumbStart + thumbLen
      buf.setStringN(x, y, (if inThumb: s.thumbSymbol else: s.trackSymbol),
                     (if inThumb: s.thumbStyle else: s.trackStyle), 1)
  else:
    let y = if s.orientation == soHorizontalBottom: area.bottom - 1 else: area.top
    for i in 0 ..< trackLen:
      let x = area.left + i
      let inThumb = i >= thumbStart and i < thumbStart + thumbLen
      buf.setStringN(x, y, (if inThumb: s.thumbSymbol else: s.trackSymbol),
                     (if inThumb: s.thumbStyle else: s.trackStyle), 1)
