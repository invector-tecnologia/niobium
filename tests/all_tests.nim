## Aggregated test entry point. Every test suite is imported here and run via `nimble test`.
## Stage 2 adds `import core/..., layout/..., backend/..., widgets/...` suites in dependency order.

import std/unittest

import ../src/niobium

suite "scaffold":
  test "package version is present":
    check NiobiumVersion.len > 0
