---
applyTo: "docs/adr/**"
description: "Architecture Decision Record format (MADR-lite) for TaTUÍ."
---

# ADR format — TaTUÍ

Use a lightweight MADR structure. One decision per file, named `NNNN-kebab-title.md`.

```markdown
# NNNN. Title

- Status: proposed | accepted | superseded by ADR-XXXX
- Date: YYYY-MM-DD

## Context
What forces are at play? What problem/constraint drives this decision?

## Decision
The choice made, stated in the active voice ("We will ...").

## Consequences
Positive, negative, and follow-up implications. Note the testable invariants it introduces.

## Alternatives considered
Brief list with why they were rejected.
```

Rules:
- Keep it concise; link to the relevant spec in `specs/` and parity-map entries.
- Never delete an ADR; mark it `superseded` and add a new one.
