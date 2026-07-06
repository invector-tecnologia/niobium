## Niobium — an ergonomic, immediate-mode Terminal User Interface library for Nim.
##
## This is the umbrella module. During Stage 1 (infra-first) it exposes only the package
## version; product modules under `niobium/` are added in Stage 2 in dependency order
## (core → backend → layout → terminal → event → widgets). See `AGENTS.md` and `specs/`.

const NiobiumVersion* = "0.0.1"
  ## The Niobium package version.

runnableExamples:
  doAssert NiobiumVersion.len > 0
