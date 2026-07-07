# Pinned ratatui reference snapshot

TaTUÍ is a faithful port of ratatui. To keep RAG deterministic and token-bounded, we vendor a
**pinned** snapshot of only the ratatui modules we are porting — not the whole crate, and never the
live repository.

## Pin

- Upstream: https://github.com/ratatui/ratatui
- Pinned commit: `<SHA — record when the snapshot is vendored>`
- Vendored on: `<YYYY-MM-DD>`

## What to vendor

Copy only the source of modules under active port into `docs/reference/ratatui/<module>/`:

```
buffer/        # Buffer, Cell
layout/        # Rect, Constraint, Layout, solver
backend/       # Backend trait, ansi encoding
terminal/      # Terminal, Frame, Viewport
text/          # Text, Line, Span, Style
widgets/       # per-widget source as each is ported
```

## Update procedure

1. Bump the pinned SHA above.
2. Re-vendor the affected module source.
3. Re-run the parity-map audit (`docs/reference/parity-map.md`) and reconcile diffs.

Do not edit vendored files; they are reference-only.
