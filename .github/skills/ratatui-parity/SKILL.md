---
name: ratatui-parity
description: "Use when porting any widget, layout, buffer, or backend behavior from ratatui to TaTUÍ. Covers the parity-map workflow, semantic-diff checks, and which Rust idioms NOT to copy (traits, lifetimes, CompactString, macros). Triggers: port, parity, ratatui equivalent, faithful, mirror behavior."
---

# ratatui parity

TaTUÍ mirrors ratatui's behavior. This skill governs how to port a construct faithfully.

## Workflow
1. Find the ratatui source in the pinned snapshot: `docs/reference/ratatui/` (commit SHA recorded in
   `docs/reference/ratatui/PINNED.md`).
2. Locate or add the row in `docs/reference/parity-map.md`:
   `ratatui symbol → tatui symbol → status → ADR/spec link`.
3. Port the *behavior*, not the Rust idiom. Capture behavior as a spec + golden snapshot first.
4. Set status: `planned → in-progress → mirrored` (or `diverged` with a note explaining why).

## Rust idioms to translate, not copy
- `trait Backend` → Nim `concept` + generic `Terminal[B]` (see ADR-0002).
- Lifetimes / borrows (`&mut Buffer`) → `var Buffer` parameters.
- `CompactString` cell symbol → TaTUÍ's SSO rune storage (ADR-0003); keep the API, not the type.
- Bitflags `Modifier` → Nim `set[Modifier]`.
- Builder chains → Nim named-argument constructors or fluent procs returning `var`/value.
- Cassowary solver → greedy solver now, linear later (ADR-0004).

## Divergence policy
Divergence is allowed when Nim offers a clearer idiom, but must be recorded in the parity-map with a
one-line rationale so fidelity gaps are auditable.
