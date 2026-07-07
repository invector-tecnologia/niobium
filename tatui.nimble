# Package

version       = "0.1.2"
author        = "Bernardo Rosmaninho <bernardo@ivector.com.br>"
description   = "Ergonomic, immediate-mode Terminal User Interface library for Nim."
license       = "AGPL-3.0"
srcDir        = "src"

# Dependencies

requires "nim >= 2.0.0"

# Tasks

task test, "Run the full test suite under ARC/ORC":
  exec "nim c -r --mm:orc --styleCheck:hint tests/all_tests.nim"

task docs, "Generate API documentation (compiles runnableExamples)":
  exec "nim doc --project --index:on --outdir:htmldocs src/tatui.nim"

task fmt, "Format the codebase with nph":
  exec "nph src tests"

task lint, "Type-check the whole project with strict style checking":
  exec "nim check --styleCheck:error --hints:off src/tatui.nim"

task bench, "Run performance benchmarks":
  exec "nim c -r -d:release benchmarks/bench_render.nim"
