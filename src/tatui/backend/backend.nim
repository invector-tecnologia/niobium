## The backend boundary (ADR-0002). Only modules in this directory may emit bytes to the terminal.
##
## `Backend` documents the required surface. `Terminal[B]` (see `../terminal`) is generic over any
## type providing these procs; Nim checks the surface structurally at instantiation, matching
## ratatui's `Terminal<B: Backend>`.

import ../core/[rect, buffer]
export rect, buffer

type Backend* = concept b, var m
  ## Structural contract every backend satisfies.
  size(b) is Size
  draw(m, seq[BufferPatch])
  flush(m)
  hideCursor(m)
  showCursor(m)
  setCursorPos(m, Position)
  clear(m)
