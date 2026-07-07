# 0007. Input / event model

- Status: accepted
- Date: 2026-07-06

## Context
A TUI is a loop: it must read keyboard, mouse, resize, and paste events. On Linux/macOS these arrive
as bytes/escape sequences on stdin under termios raw mode. ratatui delegates to crossterm; TaTUÍ
has no such dependency and targets pure ANSI/termios (v1 scope: Linux + macOS).

## Decision
- Use **synchronous polling**: `pollEvent(timeout)` reads available stdin bytes (via `select`/read)
  and decodes them with a total escape-sequence parser into `Event` values.
- Events: `Key`, `Mouse`, `Resize`, `Paste`, `FocusGained/Lost`.
- Resize is delivered via `SIGWINCH` surfaced as a `Resize` event on the next poll.
- A threaded/`async` reader is an optional future add-on; the polling API stays the primitive.

## Consequences
- No threading required for basic apps; deterministic and testable.
- The parser must be total (buffer partial sequences, never crash); fuzzed in CI.

## Alternatives considered
- Dedicated reader thread: deferred — adds concurrency complexity not needed for v1.
- Nim `async` stdin: deferred — awkward for raw TTY, marginal benefit for v1.

Follow-up: confirm with maintainer if a threaded reader becomes a v1 requirement.
