# 02 - Checkbox

## Contract

`DS-COMP-020`. The checkbox is the system's binary and tri-state value control: a
24 x 24 target that reports the value the caller should now hold, with an optional
visible label that shares the target. It mirrors the `checkbox` component set of
the design file, whose `showLabel` and `replaceText` properties the single
nullable `label` parameter collapses into one.

The promise: **a checkbox shows its value geometrically — a tick, a dash or
nothing — announces that value once, and never depends on colour to carry it.**

Source: [`lumiere_checkbox.dart`](../../lib/src/components/checkbox/lumiere_checkbox.dart),
376 lines.

## Axes

| Axis | Values | Lives in |
| --- | --- | --- |
| `checked` | false, true | parameter `checked` |
| `indeterminate` | false, true | parameter `indeterminate` |
| `disabled` | false, true | parameter `disabled`, or a null `onChanged` |
| `hover` | false, true | real widget state |
| `focus` | false, true | real widget state |
| label | absent, a `String` | parameter `label` (`null` = the design's `showLabel = false`) |
| `state` | default, hover, focus, disabled | real widget state |

`checked` and `indeterminate` may both be true, and the dash then wins: the widget
reports the value as mixed (`null` to the mixin) while the caller's `checked` flag
is preserved. Activating the dash selects the box and reports `true`; it does not
clear the group summary the dash stands for.

`hover` and `focus` MUST NOT become parameters (`DS-CONST-05`). `disabled` is a
parameter because a disabled checkbox is a property of the value the application
holds, and the widget MUST also treat a null `onChanged` as disabled, which it
does.

## API

| Parameter | Type | Default | Semantics |
| --- | --- | --- | --- |
| `checked` | `bool` | `false` | The value when the box is a plain checkbox. Ignored for the graphic when `indeterminate` is true. |
| `indeterminate` | `bool` | `false` | Draws the dash and exposes the mixed state; also makes the control tristate. |
| `disabled` | `bool` | `false` | Draws the disabled set and makes the control inert. |
| `label` | `String?` | `null` | Visible text at 14 px, 4 px from the box. `null` hides the text and leaves the accessible name empty; `''` still reserves the 4 px gap and draws an empty `Text`, so it names nothing either. |
| `onChanged` | `ValueChanged<bool>?` | `null` | Called with the next value. `null` disables the control, the same way a null `onPressed` disables the button. |
| `focusNode` | `FocusNode?` | `null` | External focus node; `null` makes the widget own one. |

**DS-API-020-01** - A null callback MUST disable the control, and MUST paint the same
disabled set as `disabled: true`. Two ways to disable that look different would be
two contracts.

**DS-API-020-02** - The widget MUST NOT accept `hovered`, `focused` or `pressed`
parameters (`DS-CONST-05`), and MUST NOT accept a `Color` or a size
(`DS-CONST-02`, `DS-CONST-03`).

**DS-API-020-03** - `checked` and `indeterminate` MUST both be readable, and the
widget MUST NOT normalise the pair: a caller may hold `true` and `true`, and the
dash is what gets drawn.

**DS-API-020-04** - The widget MUST NOT expose a `semanticLabel`. A checkbox without
a visible label therefore has no accessible name (`OPEN-03`), and the name is
declared exactly once, from `label`, when one exists.

## Geometry

| Value | Measured | Source |
| --- | --- | --- |
| Interactive box | 24 x 24 | frames of the component set |
| Visible box | 14 x 14 | layer `group:Frame 672` |
| Tick bounding box | 4 x 7 | layer `shapePath:Combined Shape` |
| Indeterminate dash | 6 x 2, fully rounded ends (radius 1) | the rectangle layer of the indeterminate variant |
| Boundary width | 1 | **not measured**; the kit's control hairline |
| Tick stroke width | 1.5 | **not measured**; keeps the glyph inside the 4 x 7 box |
| Radius of the visible box | 2 | **fallback**: the export lists 0.5 on one layer, off the approved scale, so `ArcoRadius.radiusSm` |
| Radius of the hover background and the ring | 4 | **fallback**: not measured, `ArcoRadius.radiusMd`, the closest approved step to the 24 px box |
| Focus ring width / inset | 2 / 1 | **not measured**; the export has no focus outline for this control |
| Label gap | 4 | **fallback**: the labelled frame measures a 3 px gap; `ArcoSpace.spaceXs` is the closest approved step |
| Label size and line height | 14 / 22 | `ArcoType.size14` and the line height the scale pairs with it |

The tick's shape is two ratios rather than a measurement: it starts halfway down
the left edge, turns at two fifths of the width, and ends at the top right corner.
The two numbers describe the glyph, not the design.

**DS-COMP-020-01** - A checkbox MUST keep a 24 x 24 interactive box even when its
visible box is 14 x 14, and MUST draw the focus indicator inside that box, so
focusing never enlarges the layout (`DS-CONST-08`, `DS-CONST-10`). A measured value
that has no token MUST name its fallback here and in `## Status`
(`DS-CONST-04`).

## Colour resolution

| State | Role | Notes |
| --- | --- | --- |
| unchecked, default | fill none, graphic none, boundary `borderHeavy` | The boundary is what identifies the control; `border.4` is the role the contract reserves for it. |
| unchecked, hover | boundary `accent.normal`, background `fillSubtle` | The 24 x 24 hover style measured on the component set. |
| unchecked, focus | boundary `borderHeavy`, ring `accent.normal` | The ring does not depend on the value: a checked box draws the same ring around its fill. |
| checked, default | fill `accent.normal`, graphic `textOnAccent` | Fill and glyph from one family. |
| checked, hover | fill `accent.hover`, graphic `textOnAccent` | The hover step of the same ramp. |
| checked, pressed | the resting colours | No pressed step exists; see below. |
| checked, disabled | fill `accent.disabled`, graphic `textOnAccent` | No boundary: the fill is the boundary. |
| unchecked, disabled | fill `fillSubtle`, boundary `borderDefault` | The disabled pairing of a neutral surface. |
| label, enabled | `textPrimary` | — |
| label, disabled | `textDisabled` | — |

**DS-COMP-020-02** - Selection MUST NOT be carried by colour alone: a checked box draws
a 4 x 7 tick, an indeterminate box a 6 x 2 dash, and the fill only decorates the
difference (`DS-CONST-07`). The fill and the glyph MUST come from the same
`accent` family (`DS-CONST-11`).

The design declares no `pressed` option, so a press keeps the resting colours
instead of inventing a step. That is deliberate: the tick is a graphic indicator
and is held to 3:1 against its fill, and the dark `active` step measures 2.63:1
against `textOnAccent`, while `normal` and `hover` measure 3.74:1 and 4.34:1. A
pressed step here would be a regression dressed as an interaction.

`fillSubtle` is read for two purposes — the translucent hover tint of an
unchecked box and the opaque fill of a disabled one (`OPEN-13`).

## Accessibility

| Aspect | Today |
| --- | --- |
| Role | Checkbox, implied by the checked and mixed flags on the node. |
| Accessible name | `label` on one `MergeSemantics` node; the visible `Text` is inside `ExcludeSemantics`, so the name is declared once. `null` leaves it empty (`OPEN-03`). |
| States exposed | Checked, mixed, enabled/disabled, focused. The tap action is present when enabled and absent when disabled. |
| Keyboard | Tab reaches the control; Space activates it. A disabled box is not a tab stop. |
| Focus indicator | A 2 px `accent.normal` ring, inset 1 px, drawn inside the 24 px box; its contrast is unmeasured (`OPEN-09`). |

**DS-A11Y-020-01** - Name, role, value, enabled state, focus and the toggle action
MUST arrive on one merged semantics node, and the widget MUST NOT require a
`Semantics` wrapper from the caller (`DS-CONST-06`).

**DS-A11Y-020-02** - The visible label MUST NOT be read twice, and MUST NOT be the
only source of the name when it is excluded from the tree: the name comes from the
`Semantics` node above it.

**DS-A11Y-020-03** - A disabled checkbox MUST expose the disabled state and MUST
offer no tap action.

**DS-A11Y-020-04** - The focus ring MUST reach 3:1 against what it is drawn on. It is
never measured (`OPEN-09`).

## States that do not exist

* `pressed` does not exist, by the decision above: the dark `active` step measures
  2.63:1 against `textOnAccent`, below the 3:1 the tick needs.
* `error`, `invalid` and `warning` do not exist: the design declares no validation
  variant, and the four values of `checked` x `indeterminate` are the whole value
  space.
* `read-only` does not exist. A box the user may not change is a disabled box.
* `hover` changes the label not at all: the label ink is `textPrimary` until the
  control is disabled.

## Verification

| Layer | File | What it asserts |
| --- | --- | --- |
| Behaviour | [`lumiere_checkbox_test.dart`](../../test/lumiere_checkbox_test.dart) | A tap reports `true`; a tap on the label activates the box; a tap on the dash reports `true`; `disabled` and a null `onChanged` block it; every `checked` x `indeterminate` x `disabled` combination renders. |
| Semantics | the same file | The label is the name; checked, unchecked and mixed are exposed; the tap action and the enabled state are present, and absent when disabled; focus reaches the node. |
| Geometry | the same file | The interactive box is 24 x 24. The 14 x 14 visible box, the tick, the dash and the ring are not asserted. |
| Colour resolution | the same file | Every role above, in both themes, by reading the painter: fills, boundaries, graphics, the label ink and the hover background. |
| Golden | [`lumiere_checkbox_golden_test.dart`](../../test/golden/lumiere_checkbox_golden_test.dart) | Two panels, dark then light: each axis, a disabled row, a focused row and the label-less row. |
| Contrast | [`contrast_test.dart`](../../test/accessibility/contrast_test.dart) | `borderHeavy` on the page (5.75:1 dark, 3.24:1 light) and the light accent fill against its white glyph. The dark accent fill against `textOnAccent` is recorded in the dartdoc, not in the table. |

## Status

Measured: the two boxes, the tick, the dash and the label gap from the control
geometry export. Unmeasured and named as such in the widget: the boundary width,
the tick stroke, the two radii and the focus ring. The export lists a 0.5 px radius
on one layer, which is off the approved scale, so `radiusSm` is a fallback rather
than the measured value.

The control is one tab stop with one merged node; the `checked` and
`indeterminate` flags both survive to the tree.

## Open items

* `OPEN-03` - `LumiereCheckbox` has no `semanticLabel`, so a checkbox without a visible label cannot receive an accessible name.
* `OPEN-09` - The focus ring's contrast is never measured.
* `OPEN-12` - Adoption of an external `focusNode`, RTL layout and text scaling are untested for this control.
* `OPEN-13` - `fillSubtle` is both the translucent hover tint and the opaque disabled fill, so one role serves two incompatible purposes.
