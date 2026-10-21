# 02 - Loading

## Contract

`DS-COMP-012`. The indicator is one indeterminate arc that turns for as long as it is mounted.
It mirrors the `Loading` component of the design file, which declares no axis at all: one
indicator, one 40 x 40 vector, not a family.

The promise: **a loading indicator draws the design's single arc from the theme accent, and it
says nothing to a reader unless the caller gives it words.**

Source: [`lumiere_loading.dart`](../../lib/src/components/loading/lumiere_loading.dart).
Tests: [`lumiere_loading_test.dart`](../../test/lumiere_loading_test.dart),
[`lumiere_loading_golden_test.dart`](../../test/golden/lumiere_loading_golden_test.dart).

## Axes

| Axis | Values | Lives in |
| --- | --- | --- |
| — | one indicator, 40 x 40 | the design declares no axis |
| `size` | any diameter, default 40 | parameter `double size`, because the button draws the same indicator at its own icon size |
| `color` | any colour, default the theme accent | parameter `Color? color` |
| announcement | a label, or nothing | parameter `String? semanticLabel`, the only name source |

No axis is a state. The indicator is never hovered, focused, pressed or disabled, and nothing
in it varies with density, stroke, speed or direction. `size` and `color` are conveniences for
the caller, not options the design file offers.

## API

| Parameter | Type | Default | Semantics |
| --- | --- | --- | --- |
| `size` | `double` | `40` | The diameter, and therefore the box. No padding is added. |
| `color` | `Color?` | `null` | `null` resolves to `accent.normal` of the current theme; any value overrides it. |
| `semanticLabel` | `String?` | `null` | The announcement. `null` makes the indicator decorative rather than unnamed. |

**DS-API-012-01** - `size` MUST be read as a diameter: the box MUST stay square and the arc MUST
stay inside it.

**DS-API-012-02** - A null `color` MUST resolve against the theme in force when the widget builds,
so a theme change re-resolves it. No colour may be cached.

**DS-API-012-03** - The widget MUST NOT expose a `progress`, `value`, `duration` or `stroke`
parameter. There is no determinate form, no motion token and no measured stroke step to
describe one with.

**DS-API-012-04** - The widget MUST take no icon, child or trailing slot. A label beside the
indicator belongs to the caller's layout.

## Geometry

| Value | Measured | Source |
| --- | --- | --- |
| Box | `size` x `size`, default 40 x 40 | the design's single vector |
| Arc sweep | 270 degrees | three quarters of a turn; the gap is what reads as movement |
| Stroke cap | round | drawn with `StrokeCap.round` |
| Stroke width | `size / 10` | 2 at the default size; **not measured**: the exact value is pending against the design's own glyph |
| Arc box | the square deflated by half the stroke width | keeps the stroke inside the box |

**DS-COMP-012-01** - The widget MUST draw one arc inside its box and MUST NOT pad, shrink or
overflow it (`DS-CONST-10`). The stroke ratio is the one value in this file whose exact figure
the design does not settle, and it MUST be recorded as pending (`DS-CONST-04`).

## Colour resolution

| State | Role | Notes |
| --- | --- | --- |
| default | `accent.normal` | Re-resolved from the current theme on every build. |
| caller colour | the colour passed | The caller may leave the palette; the design offers no second colour of its own. |

**DS-COMP-012-02** - The default colour MUST come from the accent ramp and not from a literal
(`DS-CONST-02`, `DS-CONST-03`). The arc is graphical information, so 3:1 applies
([`contract.md`](../03-accessibility/contract.md), `DS-A11Y-002`): on the page the accent
measures 4.79 in the dark theme and 5.19 in the light one. That pair is not a row of the
contract's table, so no test asserts the ratio; it is measured here only.

## Accessibility

| Aspect | Today |
| --- | --- |
| Role | With a label, one labelled semantics container. Without one, nothing at all. |
| Accessible name | `semanticLabel`, or absent. The package supplies no name and no word. |
| States exposed | None: no value, no progress and no busy flag. |
| Keyboard | None. The indicator is not focusable and has no action. |
| Focus indicator | None, and none is required, because nothing can focus it. |
| Indicator geometry | Not applicable. |

**DS-A11Y-012-01** - With `semanticLabel`, the indicator MUST be one labelled container and MUST
add no state, value or role of its own.

**DS-A11Y-012-02** - Without `semanticLabel`, the indicator MUST produce no semantics node.
Decoration that speaks is a defect.

**DS-A11Y-012-03** - The package MUST NOT contain the string it announces. "Loading", "please
wait" and a percentage are the application's words in the application's language
(`DS-CONST-09`).

The division of responsibility reaches one component further: an indicator that announces
itself is the caller's decision, and a button that swaps its label for this indicator loses its
accessible name. That gap belongs to the button ([`button.md`](button.md), `OPEN-04`).

## States that do not exist

* Determinate progress, a percentage or a remaining time: no such variant exists.
* Hover, pressed, focused and disabled: the indicator is not interactive.
* A size axis, a density axis or a stroke axis: `size` is a caller convenience.
* Reduced motion: the rotation MUST be skipped when the platform asks for it, and it is not
  (`OPEN-11`).
* A text label inside or beside the arc: the label is the announcement or nothing.
* An error, stalled or finished state: the caller unmounts the indicator.

## Verification

| Layer | File | What it asserts |
| --- | --- | --- |
| Behaviour | [`lumiere_loading_test.dart`](../../test/lumiere_loading_test.dart) | The default 40 x 40 box, and the square box at four other sizes. |
| Colour resolution | the same file | The accent role by default, and a caller colour when given. |
| Motion | the same file | The rotation advances between two pumped frames without input. |
| Semantics | the same file | Decorative without a label, one labelled container with one. |
| Integration | the same file | A loading button mounts this indicator and not Material's. |
| Geometry | — | The arc, the sweep and the stroke ratio are asserted by no test. |
| Golden | [`lumiere_loading_golden_test.dart`](../../test/golden/lumiere_loading_golden_test.dart) | Six sizes per panel, both panels. The frame is pinned at 150 ms because the rotation never ends. |
| Contrast | — | Absent. The accent-on-page pair is not a row of the contract. |

A widget test that mounts this component MUST pump frames and MUST NOT wait for the tree to
settle: the rotation never ends, so `pumpAndSettle` never returns.

## Status

Measured: the box, the 270 degree sweep and the round cap. Pending: the stroke ratio and the
900 ms duration, both placeholders because the design declares no motion values (`DS-CONST-04`).
The rotation ignores `MediaQuery.disableAnimations`, and no motion token exists to fix that
against (`OPEN-11`).

The golden paints its light panel with `ColoredBox(light.surfaceBase)` under a dark `Theme` and
passes the light accent explicitly, so the arc there really is the light one, while a call that
omitted `color` on the same surface would resolve the dark theme's accent (`OPEN-08`).

## Open items

* `OPEN-08` - The loading golden renders its "light" panel under a dark `Theme`, so any colour the indicator resolves from the theme there is the dark theme's.
* `OPEN-11` - `LumiereLoading` ignores reduced motion (`MediaQuery.disableAnimations`) and no motion token exists.
* `OPEN-23` - The stroke ratio (`size / 10`) and the 900 ms duration are placeholders no design value covers, and no register entry held them.
