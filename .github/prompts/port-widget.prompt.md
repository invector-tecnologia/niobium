---
description: "Port one ratatui widget to TaTUÍ spec-first, running the full TDD parity loop."
name: "Port Widget"
argument-hint: "The widget name (e.g. paragraph, list, gauge)"
agent: "Port Widget"
---
Port the named widget to TaTUÍ.

- Read `specs/widgets/<name>.spec.md`, the cited ADRs, and the parity-map row.
- Write failing tests + golden snapshots first, then implement the minimal widget.
- Follow the render-path and Nim-style instructions; keep the render path allocation-free.
- Run the quality gates in [AGENTS.md](../../AGENTS.md) until green.
- Update the parity-map status to `mirrored` (or `diverged` with a rationale).
