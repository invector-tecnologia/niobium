# Specs

TaTUÍ is **spec-first**: behavior is described here before code exists, and each spec is backed by
executable tests (golden snapshots + truth-tables). Specs are derived from the ratatui parity map
(`docs/reference/parity-map.md`).

## Spec template

```markdown
# <Module / Widget> spec

- Parity: <ratatui symbol>  · ADR: <ADR link>  · Tests: tests/<file>

## Purpose
One paragraph: what it is and its role in the pipeline.

## API surface
The public types and procs (signatures), each with intended semantics.

## Behavior
Numbered, testable statements. Each maps to a test case.

## Acceptance criteria
- [ ] Golden snapshots / truth-tables enumerated.
- [ ] Edge cases covered.
```

## Snapshot format

A golden snapshot renders a `Buffer` to `tests/snapshots/<name>.txt`:

- One line per buffer row; a space represents an empty cell.
- Rows are exactly `area.width` columns wide.
- When style is under test, a sibling `<name>.style.txt` maps each cell to a single legend character
  defined in the test.

## Truth-table format

Layout specs enumerate rows of `(area, direction, constraints) -> expected rects`, implemented as
table-driven `unittest` cases.

## Status
Each spec lists its parity status; keep it in sync with the parity map.
