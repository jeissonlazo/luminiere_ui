# 02 - Switch

## Contract

`DS-COMP-022`. The switch is the system's binary control: one measured box per variant, one
merged semantics node, and a value carried by where the handle sits. It mirrors the `switch`
component set of the design file, with three track types, two sizes, `on`, `disabled`,
`handleIcon`, `trackContent` and a `state` axis whose only option is `hover`.

The promise: **a switch keeps the measured box of its variant, resolves every fill from a
semantic role, and expresses its value by the position of the handle, never by colour alone.**

Source: [`lumiere_switch.dart`](../../lib/src/components/switch/lumiere_switch.dart). Tests:
[`lumiere_switch_test.dart`](../../test/lumiere_switch_test.dart),
[`lumiere_switch_golden_test.dart`](../../test/golden/lumiere_switch_golden_test.dart).

## Axes

| Axis | Values | Lives in |
| --- | --- | --- |
| `type` | `circle`, `rectangle`, `line` | parameter `LumiereSwitchType type` |
| `size` | `standard`, `small` | parameter `LumiereSwitchSize size`; the design calls the first one `default`, which is a Dart keyword |
| `on` | on, off | parameter `bool value`; the design names the axis `on` |
| `disabled` | enabled, disabled | parameter `bool disabled`, the semantic property the design declares |
| `handleIcon` | absent, an icon | parameter `Widget? handleIcon` |
| `trackContent` | `none`, `icon`, `text` | parameter `LumiereSwitchTrackContent trackContent` |
| `state` | resting, `hover` | real widget state, resolved through `ToggleableStateMixin` |

`state` MUST NOT become a parameter (`DS-CONST-05`); the design declares no `pressed` option,
so a press keeps the resting colours instead of inventing a step. `disabled` is the permitted
exception: it is a semantic property of the control, and a null `onChanged` MUST disable it
as well, so the parameter can never disagree with the callback. `trackContent` is the one axis
the widget collapses: `icon` draws `trackIcon` inside the track, while `text` is recorded and
the label is drawn beside the track (see *Colour resolution*).

## API

| Parameter | Type | Default | Semantics |
| --- | --- | --- | --- |
| `value` | `bool` | `false` | The state. The widget never owns it and reports the next one through `onChanged`. |
| `type` | `LumiereSwitchType` | `circle` | Selects one of the six measured boxes. |
| `size` | `LumiereSwitchSize` | `standard` | The other half of that selection. |
| `disabled` | `bool` | `false` | Paints the disabled roles and makes the control inert, with or without a callback. |
| `handleIcon` | `Widget?` | `null` | Drawn inside the handle at the handle icon size. `null` draws nothing. The icon is decorative. |
| `trackContent` | `LumiereSwitchTrackContent` | `none` | Declares what the track carries. `text` does not move the label into the track. |
| `trackIcon` | `Widget?` | `null` | Drawn only when `trackContent` is `icon`. `null` draws nothing, and the axis then renders as `none`. |
| `label` | `String?` | `null` | Visible text beside the track and the primary source of the accessible name. |
| `semanticLabel` | `String?` | `null` | Name used when there is no visible label. With neither, the control has no name. |
| `onChanged` | `ValueChanged<bool>?` | `null` | The action. `null` is also a way to disable the control. |
| `focusNode` | `FocusNode?` | `null` | An external node. The widget owns and disposes one when this is null. |

**DS-API-022-01** - The control MUST be enabled only when `onChanged != null && !disabled`.
The two paths MUST be indistinguishable in paint and in semantics.

**DS-API-022-02** - The constructor MUST reject `type: line` with a `trackContent` other than
`none`, and `type: line` with a `handleIcon`. The design pairs the line type with an empty
track and a plain handle. Both guards are `assert`s, so a release build accepts the
combinations; the constraint is debug-only, the same class of guard as `OPEN-05`.

**DS-API-022-03** - A non-null `label` MUST be drawn beside the track, never inside it, and
MUST be excluded from the semantics tree so the name is declared once.

**DS-API-022-04** - The accessible name MUST be `label ?? semanticLabel`. A switch with neither
has none; the caller MUST supply one (`DS-CONST-06`).

**DS-API-022-05** - `LumiereSwitchMetrics` and `LumiereSwitchPainter` are public so the tests
can assert the resolved geometry and colour. They MUST NOT be exported by
[`lib/lumiere_ui.dart`](../../lib/lumiere_ui.dart) (`DS-CONST-01`).

## Geometry

Measured from `design/reference/control-geometry.json`, section `form_controls.Switch`.

| Value | Measured | Source |
| --- | --- | --- |
| Box, `circle` and `rectangle`, `standard` / `small` | 40 x 24 / 28 x 16 | measured frames |
| Box, `line`, `standard` / `small` | 36 x 20 / 28 x 20 | bounding box of bar and handle, not the bar |
| Track, `line`, `standard` / `small` | 36 x 6 / 28 x 4 | measured bar |
| Handle, `circle` and `rectangle` | 16 / 12 | measured `Thumb` layer; 12 is the project-file value, the upstream Sketch showed 10 |
| Handle, `line` | 20 | measured `shapePath:thumb` layer, both sizes |
| Track and handle radius | `radiusFull`; `radiusMd` 4 for `rectangle` | 20 measured on the circle, half the height; **fallback** for `rectangle`, whose radius the export does not record |
| Handle inset | `(box height - handle) / 2` = 4, 2, 0 | derived, never stored |
| `handleLeft`, off / on | 4 / 20, 2 / 14, 0 / 16, 0 / 8 | derived from the box, the handle and the inset |
| Handle icon, `standard` / `small` | 10 / 8 | `ArcoType.size10`; **fallback** to `ArcoSpace.spaceSm` on `small`, because 10 does not fit a 12 px handle |
| Track icon, `standard` / `small` | 12 / 10 | `ArcoType.size12` / `ArcoType.size10` |
| Track content inset | 4 | `ArcoSpace.spaceXs`; **fallback**: the export records the layer, not its padding |
| Label size and gap | 14 (12 on `small`), gap 8 | `ArcoType.size14` / `size12`; the gap is a **fallback** to `ArcoSpace.spaceSm` |
| Focus ring | 2 wide, inset 1, inside the box | **not measured**: component constants; the export records no focus outline |

**DS-COMP-022-01** - The layout box MUST be the interactive box, and the focus ring MUST be drawn
inside it, so focus never moves the control (`DS-CONST-08`). The `line` box MUST remain the
bounding box of the two shapes, because the handle is larger than the bar it rides on.

The small handle MUST be 12 x 12. Three code comments still say 10, carried over from the
upstream Sketch, while the project file and the behaviour test say 12 (`OPEN-16`); this file
records 12. The 2 px ring and its 1 px inset are component constants, not tokens: the export
records no outline for this control, and no stroke token carries a ring width.

## Colour resolution

| State | Role | Notes |
| --- | --- | --- |
| on, resting | track `accent.normal` | — |
| on, hover | track `accent.hover` | — |
| off, resting | track `borderHeavy` | The contract's role for a control boundary. |
| off, hover | track `borderStrong` | The hover step of the same border scale. |
| disabled, on | track `accent.disabled` | — |
| disabled, off | track `fillDefault` | — |
| handle, every state | `textOnAccent` | The label of the accent family, kept even when the track leaves the family. |
| handle icon, enabled / disabled | `accent.normal` / `accent.disabled` | Not `textOnAccent`, which would vanish on the handle. |
| track icon | `textOnAccent` | The only role that reaches 3:1 on both possible track fills. |
| label, enabled / disabled | `textPrimary` / `textDisabled` | Drawn on the page, not on the track. |
| pressed | keeps the resting roles | No pressed option is declared. |

**DS-COMP-022-02** - The off track MUST be a boundary role and not a neutral fill: it has to
identify the control, so it uses `borderHeavy`, whose hover step is `borderStrong`
([`contract.md`](../03-accessibility/contract.md), `DS-A11Y-006`).

| Pair | Dark | Light |
| --- | --- | --- |
| `borderHeavy` on the page | 5.75 | 3.24 |
| Handle on `borderHeavy` | 3.11 | 3.24 |
| Handle on `borderStrong` (hover) | 6.38 | 1.59 |
| `textOnAccent` on `accent.normal` | 3.74 | 5.19 |
| `textPrimary` on the page | 14.58 | 16.13 |

Two consequences are recorded rather than hidden. The hover step drops the white handle to
1.59 in the light theme; hover is transient and the handle position, not its contrast, is
what carries the value. And `trackContent: text` is a deliberate deviation: the design widens
the track to 51 x 24 to hold the label, where text on the accent fill measures 3.74 in the
dark theme, below the 4.5:1 normal text requires, with no darker solid step available. The
label is therefore drawn beside the measured track, where `textPrimary` measures 14.58. A
caller MUST NOT expect the 51 px track.

## Accessibility

| Aspect | Today |
| --- | --- |
| Role | One `MergeSemantics` node over `Semantics`, carrying `toggled: value` and `enabled`. No role flag is emitted, so the platform announces state and action rather than a role name. |
| Accessible name | `label ?? semanticLabel`. The visible label is wrapped in `ExcludeSemantics`. |
| States exposed | Toggled, enabled and focus. A disabled switch drops the tap action entirely. |
| Keyboard | Tab reaches an enabled switch and skips a disabled one; Space toggles it. |
| Focus indicator | A 2 px ring inset 1 px inside the measured box, in `surfaceBase` on `circle` and `rectangle` and in `accent.normal` on `line`. |
| Indicator geometry | Drawn on the deflated layout box with the track radius, so the control does not grow or move. |

**DS-A11Y-022-01** - The whole control MUST be one merged semantics node. The name, the state,
the action and the focus belong on it, and the label MUST NOT appear as a second node.

**DS-A11Y-022-02** - Space MUST toggle the control while it holds focus, and Tab MUST NOT
reach a disabled switch.

**DS-A11Y-022-03** - The ring colour MUST be `surfaceBase` where the ring lands on the track
(a knockout) and `accent.normal` where it lands on the page. Its geometry is measured; its
contrast is not asserted (`OPEN-09`).

**DS-A11Y-022-04** - Neither icon may enter the semantics tree or be the only carrier of the
value (`DS-CONST-07`). `handleIcon` and `trackIcon` are decorative.

## States that do not exist

* `pressed`: declared by no design option, so no pressed fill exists.
* `hover` and `focus` as parameters: both are widget states (`DS-CONST-05`).
* Indeterminate or tristate: the state class fixes `tristate` to `false`.
* `loading`, `error`, `read-only` and `invalid`: absent, and out of scope for this control.
* Motion: the handle jumps to its new position. No duration is read, because the design
  declares no motion value and no motion token exists.
* A second ring width, an outer ring or a glow on focus: one ring geometry only.

## Verification

| Layer | File | What it asserts |
| --- | --- | --- |
| Behaviour | [`lumiere_switch_test.dart`](../../test/lumiere_switch_test.dart) | A tap reports the next value; a label tap toggles; `disabled` and a null callback both block interaction; every axis combination renders. |
| Geometry | the same file | The six layout boxes, the track and handle sizes, `radiusFull`, and the six `handleLeft` values, one per end of each variant. |
| API guards | the same file | The line type rejects a track content and a handle icon, both through `assert`. |
| Colour resolution | the same file | The four track roles and the handle role in both themes, and the two label roles. |
| Hover | the same file | Both ends of the track move to their hover step under a mouse. |
| Semantics | the same file | The name from either source, toggled on and off, enabled, focus and the absent tap action when disabled. |
| Keyboard | the same file | Tab reaches the control, Space toggles it, a disabled switch is skipped, and the ring colour is the one each type claims. |
| Golden | [`lumiere_switch_golden_test.dart`](../../test/golden/lumiere_switch_golden_test.dart) | Type and size matrix, disabled, handle icon, both track contents and both focus rings, in both themes. Each panel carries its own `Theme`, so the light panel really resolves light tokens. |
| Contrast | [`contrast_test.dart`](../../test/accessibility/contrast_test.dart) | `borderHeavy` on the page only. The handle-on-track pair is not a row of the table. |
| Coverage | — | The `text` track content in the disabled state, and `focusNode` adoption, are untested (`OPEN-12`). |

## Status

Measured: the six boxes, the handles, the radii, the icon sizes and the label sizes. The ring's
geometry is asserted while its contrast is not (`OPEN-09`); the handle's contrast against the off
track is measured in this file only, because the pair is not in the contract.

The three stale 10 px comments are a documentation defect, not a behaviour one (`OPEN-16`). The
constructor guards are `assert`-only, and the 2 px ring width is a component constant with no
token behind it.

## Open items

* `OPEN-09` - The focus ring's contrast is never measured, in either theme.
* `OPEN-12` - The `text` track content is untested in the disabled state, and `focusNode` adoption is untested.
* `OPEN-16` - The dartdoc of `LumiereSwitch` declares a 10 px small handle in three places while the code uses the measured 12.
