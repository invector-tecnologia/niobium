# 0008. Terminal lifecycle and raw-mode safety

- Status: accepted
- Date: 2026-07-06

## Context
Entering raw mode, the alternate screen, and mouse capture mutates global terminal state. If not
restored on exit/exception, the user's shell is left broken (no echo, alt screen, mouse noise).

## Decision
- Provide `init`/`restore` that toggle: termios raw mode, alternate screen (`CSI ?1049h/l`), cursor
  visibility, optional mouse capture, and bracketed paste.
- Restoration is guaranteed via `defer` at the call site and/or a `Terminal` destructor (`=destroy`),
  so it runs even on exception or `quit`.
- A global panic/exit hook restores the terminal before the process dies.

## Consequences
- The user's terminal is always left clean, even on crash.
- All lifecycle escape output lives in the backend (pillar 2 preserved).

## Alternatives considered
- Manual cleanup by the user: rejected — fragile, easy to leave a broken terminal.
- `try/finally` only: insufficient against `quit`/signals; combined with hooks instead.
