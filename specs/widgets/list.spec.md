# List spec

- Parity: `widgets::List` + `ListState` · Tests: tests/widgets/test_list.nim

## Purpose
A vertical, scrollable, selectable list. Stateful widget (offset + selection live in `ListState`).

## API surface
- `ListItem = object { content: Text, style: Style }`.
- `List` with `items`, `block`, `style`, `highlightStyle`, `highlightSymbol: string`,
  `repeatHighlightSymbol: bool`, `direction` (TopToBottom/BottomToTop).
- `ListState = object { offset: int, selected: Option[int] }`.
- `render(list, area, buf, state)` (StatefulWidget).

## Behavior
1. Items render top-to-bottom (or reversed) starting at `state.offset`.
2. `state.selected` row is drawn with `highlightStyle` and prefixed by `highlightSymbol`
   (other rows padded to align unless `repeatHighlightSymbol`).
3. Rendering adjusts `state.offset` so the selected item stays visible (scroll-into-view).
4. Multi-line items consume proportional height; partial items at the bottom are clipped.

## Acceptance criteria
- [ ] Goldens: basic list; selection + highlight symbol; scroll-into-view when selection moves off
      screen; bottom-to-top; multi-line items.
