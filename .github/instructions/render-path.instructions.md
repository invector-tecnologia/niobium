---
applyTo: "src/niobium/{core,terminal,backend}/**"
description: "Render-path rules: allocation-free steady state, buffer swapping, backend-only output."
---

# Render path — Niobium

These files form the hot path (buffer, diff, terminal loop, backend dispatch). Extra rules apply.

## Allocation discipline
- Once buffers are sized to the terminal area, a tick must perform **zero heap allocations**.
- Reuse `currentBuffer` and `nextBuffer`; `swap` them at end of tick. Never reallocate per frame.
- Avoid `string` concatenation and `seq` growth in `diff`/`draw`. Pre-size and index.
- `Buffer.reset` clears content in place; it does not allocate.

## Diffing
- The diff walks `nextBuffer` vs `currentBuffer` and yields only changed cells.
- The encoder minimizes cursor moves and coalesces runs sharing a style before emitting SGR.
- Respect the `skip` flag on cells occupied by the trailing half of a wide (2-column) glyph.

## Backend boundary
- Only `src/niobium/backend/` may emit bytes to the terminal.
- The core/terminal layers describe *what* changed via `BufferPatch`; the backend decides *how* to
  encode it (including color degradation truecolor → 256 → 16).

## Verification
- Any change here must keep `tests/test_alloc_invariant.nim` green (0 steady-state allocations).
