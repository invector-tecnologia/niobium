## Where Niobium draws inside the terminal (ADR-0001).

import ../core/rect

type
  ViewportKind* = enum
    vkFullscreen
    vkInline
    vkFixed

  Viewport* = object
    case kind*: ViewportKind
    of vkFullscreen: discard
    of vkInline: height*: int
    of vkFixed: area*: Rect

func fullscreen*(): Viewport =
  ## Use the whole terminal (on the alternate screen).
  Viewport(kind: vkFullscreen)

func inline*(height: int): Viewport =
  ## Reserve `height` rows at the bottom of the main screen.
  Viewport(kind: vkInline, height: height)

func fixed*(area: Rect): Viewport =
  ## Draw only within `area`.
  Viewport(kind: vkFixed, area: area)

func viewportArea*(v: Viewport, sz: Size): Rect =
  ## Resolve the drawable rectangle for a given terminal size.
  case v.kind
  of vkFullscreen: rect(0, 0, sz.width.int, sz.height.int)
  of vkInline: rect(0, 0, sz.width.int, min(v.height, sz.height.int))
  of vkFixed: v.area
