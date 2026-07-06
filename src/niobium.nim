## Niobium — an ergonomic, immediate-mode Terminal User Interface library for Nim.
##
## This umbrella module re-exports the public API: core primitives, the layout engine, backends,
## the terminal tick driver, events, and widgets. See `AGENTS.md` and `specs/` for the design.

import ./niobium/[core, layout, terminal, event, widgets]
import ./niobium/backend/[backend, ansi, test_backend]
export core, layout, terminal, event, widgets
export backend, ansi, test_backend

const NiobiumVersion* = "0.0.1"
  ## The Niobium package version.

runnableExamples:
  doAssert NiobiumVersion.len > 0

