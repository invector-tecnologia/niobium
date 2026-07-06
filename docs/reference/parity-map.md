# Parity map: ratatui → Niobium

The single source of truth for architectural fidelity. Every public Niobium symbol that mirrors
ratatui must appear here. The `ratatui-parity` skill governs updates.

**Status legend:** `planned` · `in-progress` · `mirrored` · `diverged` (with rationale).

## Core

| ratatui | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `buffer::Buffer` | `core/buffer.Buffer` | mirrored | ADR-0003, specs/core/buffer.spec.md |
| `buffer::Cell` | `core/cell.Cell` | mirrored | ADR-0003, specs/core/cell.spec.md |
| `layout::Rect` | `core/rect.Rect` | mirrored | specs/core/rect.spec.md |
| `style::Style` | `core/style.Style` | mirrored | ADR-0005, specs/core/style.spec.md |
| `style::Color` | `core/color.Color` | mirrored | ADR-0005, ADR-0012 |
| `style::Modifier` | `core/style.Modifier` (`set[Modifier]`) | mirrored | ADR-0005 |
| `text::{Span,Line,Text}` | `core/text.{Span,Line,Text}` | mirrored | ADR-0005, ADR-0006 |

## Layout

| ratatui | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `layout::Constraint` | `layout/constraint.Constraint` | mirrored | ADR-0004 |
| `layout::Layout` | `layout/solver` | mirrored | ADR-0004, specs/layout/layout.spec.md |
| `layout::Direction` | `layout/constraint.Direction` | mirrored | ADR-0004 |

## Backend & terminal

| ratatui | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `backend::Backend` (trait) | `backend/backend.Backend` (concept) | mirrored | ADR-0002, specs/backend/backend.spec.md |
| `backend::CrosstermBackend` | `backend/ansi.AnsiBackend` | mirrored | ADR-0007, ADR-0008 |
| `backend::TestBackend` | `backend/test_backend.TestBackend` | mirrored | ADR-0011 |
| `Terminal` | `terminal/terminal.Terminal[B]` | mirrored | ADR-0001, ADR-0002 |
| `Frame` | `terminal/frame.Frame` | mirrored | specs/terminal/frame.spec.md |
| `Viewport` | `terminal/viewport.Viewport` | mirrored | specs/terminal/viewport.spec.md |

## Events

| ratatui / crossterm | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `event::Event` | `event/event.Event` | mirrored | ADR-0007 |
| `event::KeyEvent` | `event/event.KeyEvent` | mirrored | ADR-0007 |
| `event::MouseEvent` | `event/event.MouseEvent` | mirrored | ADR-0007 |

## Widgets

| ratatui | Niobium | Status | ADR / Spec |
|---|---|---|---|
| `widgets::Block` | `widgets/blocks.Block` | mirrored | specs/widgets/block.spec.md |
| `widgets::Paragraph` | `widgets/paragraph.Paragraph` | mirrored | specs/widgets/paragraph.spec.md |
| `widgets::List` + `ListState` | `widgets/list` | mirrored | specs/widgets/list.spec.md |
| `widgets::Table` + `TableState` | `widgets/table` | mirrored | specs/widgets/table.spec.md |
| `widgets::Tabs` | `widgets/tabs.Tabs` | mirrored | specs/widgets/tabs.spec.md |
| `widgets::Clear` | `widgets/clear.Clear` | mirrored | specs/widgets/clear.spec.md |
| `widgets::Gauge` / `LineGauge` | `widgets/gauge` | mirrored | specs/widgets/gauge.spec.md |
| `widgets::BarChart` | `widgets/bar_chart.BarChart` | mirrored | specs/widgets/bar_chart.spec.md |
| `widgets::Sparkline` | `widgets/sparkline.Sparkline` | mirrored | specs/widgets/sparkline.spec.md |
| `widgets::Chart` | `widgets/chart.Chart` | mirrored | specs/widgets/chart.spec.md |
| `widgets::Scrollbar` + state | `widgets/scrollbar` | mirrored | specs/widgets/scrollbar.spec.md |
| `widgets::canvas::Canvas` | `widgets/canvas` | planned (v0.2 candidate) | specs/widgets/canvas.spec.md |
