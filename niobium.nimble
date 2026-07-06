# Package

version       = "0.0.1"
author        = "Niobium contributors"
description   = "Ergonomic, immediate-mode Terminal User Interface library for Nim (a faithful port of ratatui's architecture)."
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.0.0"

# Tasks

task test, "Run the full test suite under ARC/ORC":
  exec "nim c -r --mm:orc --styleCheck:hint tests/all_tests.nim"

task docs, "Generate API documentation (compiles runnableExamples)":
  exec "nim doc --project --index:on --outdir:htmldocs src/niobium.nim"

task fmt, "Format the codebase with nph":
  exec "nph src tests"

task lint, "Type-check the whole project with strict style checking":
  exec "nim check --styleCheck:error --hints:off src/niobium.nim"

task bench, "Run performance benchmarks":
  exec "nim c -r -d:release benchmarks/bench_render.nim"
