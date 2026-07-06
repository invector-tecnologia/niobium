# Parity map: ratatui → Niobium

The single source of truth for architectural fidelity. Every public Niobium symbol that mirrors
ratatui must appear here. The `ratatui-parity` skill governs updates.

**Status legend:** `planned` · `in-progress` · `mirrored` · `diverged` (with rationale).

## Core

| ratatui | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `buffer::Buffer` | `core/buffer.Buffer` | planned | ADR-0003, specs/core/buffer.spec.md |
| `buffer::Cell` | `core/cell.Cell` | planned | ADR-0003, specs/core/cell.spec.md |
| `layout::Rect` | `core/rect.Rect` | planned | specs/core/rect.spec.md |
| `style::Style` | `core/style.Style` | planned | ADR-0005, specs/core/style.spec.md |
| `style::Color` | `core/color.Color` | planned | ADR-0005, ADR-0012 |
| `style::Modifier` | `core/style.Modifier` (`set[Modifier]`) | planned | ADR-0005 |
| `text::{Span,Line,Text}` | `core/text.{Span,Line,Text}` | planned | ADR-0005, ADR-0006 |

## Layout

| ratatui | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `layout::Constraint` | `layout/constraint.Constraint` | planned | ADR-0004 |
| `layout::Layout` | `layout/solver` | planned | ADR-0004, specs/layout/layout.spec.md |
| `layout::Direction` | `layout/constraint.Direction` | planned | ADR-0004 |

## Backend & terminal

| ratatui | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `backend::Backend` (trait) | `backend/backend.Backend` (concept) | planned | ADR-0002, specs/backend/backend.spec.md |
| `backend::CrosstermBackend` | `backend/ansi.AnsiBackend` | planned | ADR-0007, ADR-0008 |
| `backend::TestBackend` | `backend/test_backend.TestBackend` | planned | ADR-0011 |
| `Terminal` | `terminal/terminal.Terminal[B]` | planned | ADR-0001, ADR-0002 |
| `Frame` | `terminal/frame.Frame` | planned | specs/terminal/frame.spec.md |
| `Viewport` | `terminal/viewport.Viewport` | planned | specs/terminal/viewport.spec.md |

## Events

| ratatui / crossterm | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `event::Event` | `event/event.Event` | planned | ADR-0007 |
| `event::KeyEvent` | `event/event.KeyEvent` | planned | ADR-0007 |
| `event::MouseEvent` | `event/event.MouseEvent` | planned | ADR-0007 |

## Widgets

| ratatui | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `widgets::Block` | `widgets/block.Block` | planned | specs/widgets/block.spec.md |
| `widgets::Paragraph` | `widgets/paragraph.Paragraph` | planned | specs/widgets/paragraph.spec.md |
| `widgets::List` + `ListState` | `widgets/list` | planned | specs/widgets/list.spec.md |
| `widgets::Table` + `TableState` | `widgets/table` | planned | specs/widgets/table.spec.md |
| `widgets::Tabs` | `widgets/tabs.Tabs` | planned | specs/widgets/tabs.spec.md |
| `widgets::Clear` | `widgets/clear.Clear` | planned | specs/widgets/clear.spec.md |
| `widgets::Gauge` / `LineGauge` | `widgets/gauge` | planned | specs/widgets/gauge.spec.md |
| `widgets::BarChart` | `widgets/bar_chart.BarChart` | planned | specs/widgets/bar_chart.spec.md |
| `widgets::Sparkline` | `widgets/sparkline.Sparkline` | planned | specs/widgets/sparkline.spec.md |
| `widgets::Chart` | `widgets/chart.Chart` | planned | specs/widgets/chart.spec.md |
| `widgets::Scrollbar` + state | `widgets/scrollbar` | planned | specs/widgets/scrollbar.spec.md |
| `widgets::canvas::Canvas` | `widgets/canvas` | planned (v0.2 candidate) | specs/widgets/canvas.spec.md |
