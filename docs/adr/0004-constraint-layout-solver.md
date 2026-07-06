# 0004. Constraint-based layout solver

- Status: accepted
- Date: 2026-07-06

## Context
Layout uses constraints, not absolute coordinates (pillar 3). ratatui adopted a Cassowary linear
solver (kasuari) plus a thread-local layout cache because mixing `Min`/`Max`/`Ratio`/`Fill` with
integer rounding is subtle and solving repeats every frame.

## Decision
- Commit now to the final `Constraint` API: `Length`, `Percentage`, `Ratio`, `Min`, `Max`, `Fill`.
- Ship a **greedy solver** first, behind that API. A **linear (kasuari-style) solver** can replace it
  later without changing callers.
- Cache solved layouts in a **thread-local LRU** keyed by `(area, direction, constraints, spacing,
  margin)`.
- Rounding remainder is distributed deterministically (left→right / top→bottom); child extents sum
  to the parent extent.

## Consequences
- Callers depend only on the stable API; the solver is an implementation detail.
- Truth-table tests pin behavior so a solver swap is safe.

## Alternatives considered
- Only a simple greedy solver forever: rejected — cannot express all Min/Max/Ratio interactions
  faithfully.
- Full linear solver first: deferred — higher upfront complexity than needed for v1.
