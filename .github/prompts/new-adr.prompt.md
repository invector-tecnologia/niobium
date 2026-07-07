---
description: "Create a new Architecture Decision Record for TaTUÍ following the MADR-lite format."
name: "New ADR"
argument-hint: "The decision title and short context"
agent: "agent"
---
Create a new ADR under `docs/adr/` following [the ADR format](../instructions/adr.instructions.md).

- Pick the next `NNNN` number after the highest existing ADR in `docs/adr/`.
- File name: `NNNN-kebab-title.md`.
- Fill Context, Decision, Consequences (including any testable invariant introduced), and
  Alternatives considered.
- Link the relevant spec in `specs/` and any parity-map rows.
- Set status to `proposed` unless told otherwise.
