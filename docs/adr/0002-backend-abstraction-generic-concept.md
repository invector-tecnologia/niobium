# 0002. Backend abstraction via generic + concept

- Status: accepted
- Date: 2026-07-06

## Context
Spatial/drawing logic must be independent of the OS and terminal library (pillar 2). ratatui uses a
`Backend` trait with a generic `Terminal<B: Backend>` (static dispatch, monomorphized).

## Decision
We will define a `Backend` **concept** and a generic `Terminal[B]` constrained by it, giving static
dispatch and a zero-cost hot path. A dynamic (`ref object` + `method` vtable) backend may be added
later for runtime-plugged backends, without changing the concept.

## Consequences
- Zero-overhead dispatch on the render path; backends are swappable at compile time.
- `TestBackend` and `AnsiBackend` satisfy the same concept, enabling deterministic tests.
- Concepts are still evolving in Nim; keep the required surface small and well-tested.

## Alternatives considered
- `method`-based dynamic dispatch only: rejected for v1 — per-call vtable cost in the hot path.
- Closures/function tables: rejected — less ergonomic, weaker type checking than a concept.
