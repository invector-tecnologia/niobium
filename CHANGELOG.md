# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-07-07

### Changed

- **Renamed the project from Niobium to TaTUÍ.** This is a breaking change for
  existing users.
  - Package renamed: `niobium` → `tatui` (install with `nimble install tatui`).
  - Import path renamed: `import niobium` → `import tatui`.
  - Internal module tree moved: `src/niobium/` → `src/tatui/`.
  - Public version constant renamed: `NiobiumVersion` → `TatuiVersion`.
- Aligned the version constant with the package version (previously drifted at
  `0.0.1` in source vs `0.1.1` in the package definition); both are now `0.2.0`.

[0.2.0]: https://github.com/invector-tecnologia/tatui/releases/tag/v0.2.0
