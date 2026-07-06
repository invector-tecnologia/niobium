---
description: "Create a new Niobium module/widget spec following the spec-first template."
name: "New Spec"
argument-hint: "The module or widget name"
agent: "Spec Author"
---
Create a new spec under `specs/` following the template in [specs/README.md](../../specs/README.md).

- Place core specs in `specs/core/`, layout in `specs/layout/`, widgets in `specs/widgets/`, etc.
- Derive behavior from the pinned ratatui reference and cite the relevant ADRs.
- Include a public API surface, numbered testable behavior statements, and acceptance criteria
  (golden snapshots / truth-tables).
- Add or update the row in [docs/reference/parity-map.md](../../docs/reference/parity-map.md).
