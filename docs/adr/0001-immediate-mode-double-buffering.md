# 0001. Immediate-mode rendering with double buffering

- Status: accepted
- Date: 2026-07-06

## Context
Sequential, uncontrolled terminal writes cause flicker and I/O overhead. ratatui solves this by
rebuilding the UI every tick while diffing against a retained cell buffer.

## Decision
We will render in **immediate mode at the widget/API layer** (widgets are reconstructed every tick
from application state and hold no render state) while keeping a **retained cell buffer** as the diff
baseline. Each tick: build `nextBuffer` → diff against `currentBuffer` → emit minimal cell updates →
`swap` buffers.

## Consequences
- Simple mental model for users; UI is a pure function of state.
- The back buffer is essential persistent state and must never be "optimized away".
- Introduces the testable invariant: the render path allocates zero heap memory in steady state
  (ADR-0010).

## Alternatives considered
- Pure retained-mode scene graph: rejected — more stateful, harder API, diverges from ratatui.
- Direct terminal writes: rejected — flicker and I/O cost, the original problem.
