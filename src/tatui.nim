## TaTUÍ — an ergonomic, immediate-mode Terminal User Interface library for Nim.
##
## This umbrella module re-exports the public API: core primitives, the layout engine, backends,
## the terminal tick driver, events, and widgets. See `AGENTS.md` and `specs/` for the design.

import ./tatui/[core, layout, terminal, event, widgets]
import ./tatui/backend/[backend, ansi, test_backend]
export core, layout, terminal, event, widgets
export backend, ansi, test_backend

const TatuiVersion* = "0.2.0" ## The TaTUÍ package version.

runnableExamples:
  doAssert TatuiVersion.len > 0
