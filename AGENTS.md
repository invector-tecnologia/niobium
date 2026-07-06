# AGENTS.md — Niobium agent operating contract

This file defines how automated agents (and humans) must work in this repository. It complements
`.github/copilot-instructions.md`, which holds the architectural invariants.

## Development philosophy

**Infra-first, then spec-first.** The AI-development operating model (instructions, skills, ADRs,
specs, CI) is established before product code. Each unit of product code is driven by a spec in
`specs/` and a failing test before implementation.

## The reasoning loop (follow for every task)

1. **Plan** — read the relevant ADR (`docs/adr/`), spec (`specs/`), and parity-map entry
   (`docs/reference/parity-map.md`). State the intended change.
2. **Red** — write or update a snapshot/unit test that fails for the right reason.
3. **Implement** — write the minimal code to pass. Respect the hard invariants.
4. **Verify** — run the quality gates below, cheap → expensive. Fix and repeat on failure.
5. **Self-review** — re-check against the restrictions in `.github/instructions/`.
6. **Record** — update the parity-map and any relevant ADR/spec.

## Quality gates (run in this order)

```
nim check --styleCheck:error --hints:off src/niobium.nim   # 1. types + style
nph --check src tests                                       # 2. formatting
nimble test                                                 # 3. unit + snapshot + layout truth-tables (--mm:orc)
nim c -r tests/test_alloc_invariant.nim                     # 4. zero steady-state allocations
nim c -r tests/fuzz/ansi_parser_smoke.nim                  # 5. ANSI parser fuzz smoke
nimble docs                                                 # 6. runnableExamples compile
```

## Definition of Done

- All quality gates pass.
- Render-path changes prove zero steady-state heap allocations.
- Public symbols documented with `runnableExamples`.
- Parity-map updated; the change references its ADR/spec.
- Golden snapshot changes are intentional and acknowledged in the change description.

## Toolchain

- Nim ≥ 2.0.0 (ORC is the default GC).
- Formatter: `nph`. Tests: Nim `unittest` aggregated in `tests/all_tests.nim`.
- Never bypass gates (no `--mm:refc`, no skipping style checks).
