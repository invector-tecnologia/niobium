## Clear: reset every cell in an area to blank (ratatui `widgets::Clear`).

import ../core/[rect, cell, buffer]

type Clear* = object

proc render*(c: Clear, area: Rect, buf: var Buffer) =
  ## Blank every cell within `area`.
  for y in area.top ..< area.bottom:
    for x in area.left ..< area.right:
      if buf.inside(x, y):
        buf[x, y] = cell(" ")
