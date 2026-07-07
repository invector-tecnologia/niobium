# TaTUÍ — Copilot Instructions

TaTUÍ is an ergonomic, **immediate-mode** Terminal User Interface (TUI) library for Nim.
It is a faithful architectural port of [ratatui](https://github.com/ratatui/ratatui) (Rust),
adapted to Nim's metaprogramming and ARC/ORC memory model.

## Mental model

- **Immediate mode at the widget/API layer** — the UI is rebuilt every tick from application
  state; widgets hold no rendering state.
- **Retained mode at the cell-buffer layer** — the back buffer *is* persistent state. It is what
  makes diffing possible. Never "optimize away" the buffer.

## The three architectural pillars (never violate)

1. **Double buffering + diffing.** Widgets write cells into an in-memory `Buffer`. At the end of a
   tick, TaTUÍ diffs the new buffer against the previous one and emits only the minimal set of
   cell updates.
2. **Backend agnosticism.** Spatial/drawing logic knows nothing about the OS or the terminal
   library. All output flows through the `Backend` concept.
3. **Constraint-based layout.** No absolute coordinates. `Rect`s are split by constraints
   (Length, Percentage, Ratio, Min, Max, Fill).

## Hard invariants (enforced by CI and review)

- **Allocation-free steady state.** The render path (`draw` → diff → dispatch) must not allocate on
  the heap once buffers are sized. Reuse buffers and `swap` them each tick; never reallocate.
- **Backend-only output.** No code outside `src/tatui/backend/` may write to the terminal or emit
  escape sequences. Everything goes through the `Backend` concept.
- **`--mm:orc` only.** No `--mm:refc`, no manual `alloc`/`dealloc`.
- **Every public symbol** has a doc comment and, where it renders or computes, a `runnableExamples`.
- **Parity rule.** Every widget/behavior must cite the ratatui construct it mirrors and have an
  entry in `docs/reference/parity-map.md`.

## Platform scope (v1)

Linux and macOS only, via pure ANSI escape sequences + termios raw mode. No Windows console API.

## Conventions

- Nim ≥ 2.0, 2-space indent, 100-column lines, formatted with `nph`.
- Error handling: `Result`-style for I/O and fallible operations; exceptions only at the public API
  boundary (see `docs/adr/0009-error-handling.md`).
- Prefer value types and `seq`-backed flat arrays over `ref` in the hot path.

## Workflow

Read `AGENTS.md` for the required reasoning loop and Definition of Done before making changes.
This project is **spec-first**: write/adjust the spec in `specs/`, add a failing test, then
implement.
