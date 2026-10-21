# ADR-0002 - State as widget state

- Status: Accepted
- Date: 2026-10-16
- Specs affected: `DS-CONST-05`, `DS-API-*`

## Context

The design declares a `state` axis with five options: default, hover, focus, active,
disabled. Flutter has the same five as states of a widget, resolved from the pointer, the
focus tree and the callback's nullability. A `state` parameter would let a caller describe a
state the widget is not in, and a screenshot taken from it would show something that cannot
happen.

## Decision

State is resolved through `WidgetStateProperty` and the widget's own state, never accepted as
a constructor parameter (`DS-CONST-05`). `loading` is the single exception, because it cannot
be expressed as a widget state, and it stays a property.

The design axis is therefore not an axis of the API: `default` is the resting state, `hover`
comes from a `MouseRegion`, `focus` from the `FocusNode`, `active` from the gesture, `disabled`
from a null callback. Where Material adds a step the design never declared - its default
`pressed` options - the component suppresses it rather than paint it.

## Consequences

### Positive

- A screenshot cannot describe an impossible state, so a review of a state is a review of the widget's behaviour, not of a parameter.
- One code path per state: the resolved colour a test asserts is the one a user sees, because nothing else can set it.
- The design's `state` axis needs no translation table, and a new Flutter state is a compile-time concern rather than an API change.

### Negative

- A caller cannot render an arbitrary state for documentation or a screenshot without driving real input, which is why the test files carry private `_hover` helpers that synthesise a mouse pointer.
- A defect that only appears under hover escapes every assertion that does not hover: OPEN-01, the opaque overlay tint, went unnoticed until it was measured at pixel level.
- Being faithful to the widget's real state meant suppressing the `pressed` step Material adds by default, or the components would paint a state the design never declared - more code, to remove a behaviour.

## Alternatives considered

- **A `state` enum parameter mirroring the design axis literally.** It makes the design file the API, and every screenshot it produces lies the moment the widget is hovered for real.
- **A `state` parameter for tests only.** A test hook on the public constructor is a public constructor: it ships, it gets used, and the widget can still be told a state it is not in.
- **Accept a `WidgetStateProperty` set from the caller.** That moves the mapping, and therefore the correctness of the look, into every application.

## References

- [`02-components/button.md`](../02-components/button.md), [`03-accessibility/keyboard-and-focus.md`](../03-accessibility/keyboard-and-focus.md)
- [`lib/src/components/button/lumiere_button.dart`](../../lib/src/components/button/lumiere_button.dart)
- [`README.md`](../../README.md), section "Component contract"
