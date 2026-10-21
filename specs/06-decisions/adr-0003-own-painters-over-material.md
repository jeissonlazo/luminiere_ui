# ADR-0003 - Own painters over Material

- Status: Accepted
- Date: 2026-10-16
- Specs affected: `DS-COMP-020`, `DS-COMP-021`, `DS-COMP-022`, `DS-COMP-012`

## Context

The measured geometry is not a configuration of anything Material draws: a 14 x 14 visible
box inside a 24 x 24 interactive box, a 4 x 7 tick, a 6 x 2 dash, a 40 x 24 track with a 16
handle, a 36 x 6 line track. Material's `Checkbox`, `Radio` and `Switch` expose `fillColor`,
`side` and a few sizes, and paint their own box, glyph and handle regardless. The focus ring
must also be drawn inside the measured box, not added outside it (`DS-CONST-08`), and a look
that no longer follows Material's must not change shape when Material changes.

## Decision

`LumiereCheckbox`, `LumiereRadio`, `LumiereSwitch` and `LumiereLoading` are drawn with a
`CustomPainter`; Material's widgets of those four names are not constructed at all. The button
is the exception and remains a `TextButton` restyled, with its geometry pinned explicitly by
`visualDensity: VisualDensity.standard` and `tapTargetSize: MaterialTapTargetSize.shrinkWrap`
rather than inherited (`DS-CONST-10`).

The 0.6.0 breaking change that removed `CircularProgressIndicator` from the button's loading
state is this decision being enforced: the button had been borrowing a look that follows
Material's.

## Consequences

### Positive

- The geometry is exactly the measurement, including the parts Material does not expose: the tick's 4 x 7, the 6 x 2 dash, the visible box inside its interactive one.
- The focus ring is drawn where the design measures it, inside the box, so focusing a control moves nothing.
- A Flutter upgrade cannot repaint these components; what changes when the toolkit changes is what this package chose to change.
- The button keeps Material's text rendering and ink, the part of Material this package does not want to own.

### Negative

- Roughly 1,400 lines of component code the Flutter team would otherwise maintain.
- Every state, semantics node, keyboard interaction and focus ring is ours to get right and ours to break; a Material upgrade that fixes one of those fixes nothing here.
- The painters are public - `LumiereCheckboxPainter`, `LumiereRadioPainter`, `LumiereSwitchPainter` - only so tests can assert resolved colours, a test-driven widening of the API surface.
- The button, being a Material widget, is the one component where Material can still inject a colour nobody chose: OPEN-01, the opaque overlay tint.

## Alternatives considered

- **Configure the Material widgets through `ThemeData`.** No widget code to own; it cannot produce the measured box, and a theme override is global where the design is per component.
- **Fork the Material widgets and override.** The same maintenance as owning them, plus a fork to re-merge on every Flutter release.
- **Accept Material's geometry.** The components would be Material's, at sizes the design file does not declare, and the goldens would record someone else's decision.

## References

- [`02-components/checkbox.md`](../02-components/checkbox.md), [`radio.md`](../02-components/radio.md), [`switch.md`](../02-components/switch.md), [`loading.md`](../02-components/loading.md)
- [`lib/src/components/checkbox/lumiere_checkbox.dart`](../../lib/src/components/checkbox/lumiere_checkbox.dart)
- [`CHANGELOG.md`](../../CHANGELOG.md), 0.6.0
