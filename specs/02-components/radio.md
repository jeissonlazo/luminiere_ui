# 02 - Radio

## Contract

`DS-COMP-021`. The radio is the system's single-choice value control, in two
widgets: `LumiereRadio<T>` is one option, and `LumiereRadioGroup<T>` makes a set of
them one tab stop with one selection. Both mirror the `components/radio` component
set of the design file, whose axes are `checked`, `disabled`, `icon` and `hover`.

The promise: **a radio shows its selection with a dot, or an icon in its place,
announces the selection once, and inside a group never disagrees with the group's
value.**

Source: [`lumiere_radio.dart`](../../lib/src/components/radio/lumiere_radio.dart),
419 lines.

## Axes

| Axis | Values | Lives in |
| --- | --- | --- |
| `checked` | false, true | parameter `checked` when standalone; the group's `groupValue` inside a group |
| `disabled` | false, true | parameter `disabled` |
| `icon` | absent, a `Widget` | parameter `icon`; the design declares a boolean, and a non-null value turns the variant on |
| `hover` | false, true | real widget state |
| `focus` | false, true | real widget state |
| label | absent, a `String` | parameter `label` |
| group | standalone, member | `LumiereRadioGroup` above the radio |

`checked` is read only when the radio stands alone. Inside a group the value comes
from the group and the parameter is ignored, which is what keeps one tab stop and
one selection consistent.

`hover` and `focus` MUST NOT become parameters (`DS-CONST-05`). `disabled` is a
semantic property of the value and stays a parameter.

## API

| Parameter | Type | Default | Semantics |
| --- | --- | --- | --- |
| `value` | `T` | required | The value this option represents, and the value the group reports. |
| `checked` | `bool` | `false` | Selection when standalone. Ignored inside a group. |
| `disabled` | `bool` | `false` | Draws the disabled set and makes the control inert. |
| `icon` | `Widget?` | `null` | Replaces the dot with an icon inside the circle. `null` draws the dot; the icon is decorative and excluded from the semantics tree. |
| `label` | `String?` | `null` | Visible text at 14 px, 4 px from the circle. `null` hides the text and leaves the accessible name empty. |
| `onChanged` | `ValueChanged<bool>?` | `null` | Called with `true` when a standalone radio is selected. `null` leaves a standalone radio inert and disabled. |
| `focusNode` | `FocusNode?` | `null` | External focus node; `null` makes the widget own one. |

| `LumiereRadioGroup` parameter | Type | Default | Semantics |
| --- | --- | --- | --- |
| `groupValue` | `T?` | required, nullable | The selected value; `null` means nothing is selected. |
| `onChanged` | `ValueChanged<T?>` | required | Called with the value of the radio that was selected. |
| `child` | `Widget` | required | The radios of the group. |

**DS-API-021-01** - The radio MUST be built on the SDK's `RawRadio` and a
`RadioGroupRegistry`, never on the deprecated `groupValue` / `onChanged` properties
of `Radio`. A standalone radio MUST supply a private registry that registers no
clients: there is no group to navigate.

**DS-API-021-02** - Inside a group, `checked` MUST be ignored and the group MUST
decide; a caller MUST NOT be able to select a radio the group has not selected
(`DS-CONST-05`).

**DS-API-021-03** - The widget MUST NOT accept `hovered`, `focused`, `pressed`, a
`Color` or a size (`DS-CONST-02`, `DS-CONST-03`, `DS-CONST-05`).

**DS-API-021-04** - `icon` MUST be a widget rather than a boolean, because the design
declares the axis and the instance supplies the glyph. A non-null icon MUST turn
the variant on and MUST suppress the dot.

**DS-API-021-05** - The widget MUST NOT expose a `semanticLabel`; a radio without a
visible label has no accessible name (`OPEN-03`).

## Geometry

| Value | Measured | Source |
| --- | --- | --- |
| Interactive box | 24 x 24 | layer `group:Radio/basic/default` |
| Visible circle | 14 x 14 | layer `rectangle:Rectangle Copy 80` |
| Dot | 4 x 4 | the measured inner element of the radio |
| Icon of the `icon` variant | 10 | **fallback**: not measured; `ArcoType.size10` is the closest type step that stays inside the 14 px circle |
| Boundary width | 1 | **not measured**; the kit's control hairline, drawn on a radius of 6.5 so the stroke stays inside the 14 px circle |
| Radius of the hover background and the ring | 4 | **fallback**: not measured, `ArcoRadius.radiusMd`, the closest approved step to the 24 px box |
| Focus ring width / inset | 2 / 1 | **not measured**; the export has no focus outline for this control |
| Label gap | 4 | **fallback**: the labelled frame measures 62 x 24 for a 37 px label; `ArcoSpace.spaceXs` is the closest approved step |
| Label size and line height | 14 / 22 | `ArcoType.size14` and the line height the scale pairs with it |

**DS-COMP-021-01** - A radio MUST keep a 24 x 24 interactive box around a 14 x 14
visible circle, and MUST draw its focus indicator inside that box so focus never
enlarges the layout (`DS-CONST-08`, `DS-CONST-10`). A value with no measurement
MUST name the token it fell back to (`DS-CONST-04`).

## Colour resolution

| State | Role | Notes |
| --- | --- | --- |
| unselected, default | fill none, dot none, boundary `borderHeavy` | The boundary identifies the control; `border.4` is the role the contract reserves for it. |
| unselected, hover | boundary `accent.normal`, background `fillSubtle` | The 24 x 24 hover style measured on the component set. |
| unselected, focus | boundary `borderHeavy`, ring `accent.normal` | The ring does not depend on the value: a selected radio draws the same ring around its fill. |
| selected, default | fill `accent.normal`, dot `textOnAccent` | Fill and dot from one family. |
| selected, hover | fill `accent.hover`, dot `textOnAccent` | The hover step of the same ramp. |
| selected, pressed | the resting colours | No pressed step exists; see below. |
| selected, disabled | fill `accent.disabled`, dot `textOnAccent` | No boundary: the fill is the boundary. |
| unselected, disabled | fill none, boundary `borderDefault` | A weaker boundary and no hover background. |
| icon, selected | `textOnAccent` | The icon sits on the accent fill. |
| icon, unselected | `textSecondary` | The icon sits on the page. |
| icon, disabled and unselected | `textDisabled` | — |
| label, enabled | `textPrimary` | — |
| label, disabled | `textDisabled` | — |

**DS-COMP-021-02** - Selection MUST NOT be carried by colour alone: a selected radio
draws a 4 x 4 dot, or the icon in its place, and the fill only decorates the
difference (`DS-CONST-07`). The fill and the dot MUST come from the same `accent`
family (`DS-CONST-11`).

The design declares no `pressed` option, so a press keeps the resting colours. That
is deliberate: the dot is a graphic indicator and is held to 3:1 against its fill,
and the dark `active` step measures 2.63:1 against `textOnAccent`, while `normal`
and `hover` measure 3.74:1 and 4.34:1.

`fillSubtle` is the translucent hover tint of an unselected radio, and the opaque
disabled fill of a checkbox, so one role serves two incompatible purposes
(`OPEN-13`).

## Accessibility

| Aspect | Today |
| --- | --- |
| Role | Radio. The group is a `radioGroup` node around its radios. |
| Accessible name | `label` on one `MergeSemantics` node; the visible `Text` is inside `ExcludeSemantics`, so the name is declared once. `null` leaves it empty (`OPEN-03`). |
| States exposed | Checked, enabled/disabled, focused, and membership of a mutually exclusive group. The checked state and the group role come from the raw radio. |
| Keyboard | One tab stop per group, at the selected radio; the arrow keys move and select, wrapping at the ends, and skip a disabled radio. Space selects the focused radio. A standalone radio answers Tab and Space. |
| Focus indicator | A 2 px `accent.normal` ring, inset 1 px, inside the 24 px box; its contrast is unmeasured (`OPEN-09`). |

**DS-A11Y-021-01** - Name, role, value, enabled state, focus and the select action
MUST arrive on merged semantics, and the widget MUST NOT require a `Semantics`
wrapper (`DS-CONST-06`).

**DS-A11Y-021-02** - A group MUST be one tab stop, MUST expose the group role, and
MUST move the selection with the arrow keys, so a keyboard user reaches the group
once rather than once per option.

**DS-A11Y-021-03** - A disabled radio MUST report the disabled state, MUST offer no
tap action, and MUST be skipped by the arrow keys.

**DS-A11Y-021-04** - The inherited `toggleable` behaviour MUST stay off: a selected
radio cannot be deselected by activating it again.

**DS-A11Y-021-05** - The focus ring MUST reach 3:1 against what it is drawn on. It is
never measured (`OPEN-09`).

## States that do not exist

* `pressed` does not exist, by the decision recorded above: the dark `active` step
  measures 2.63:1 against `textOnAccent`.
* A deselecting activation does not exist on either widget: a group always has a
  selection once one was made, and `groupValue: null` is the only empty state.
* `error`, `invalid` and `warning` do not exist; the design declares no validation
  variant.
* `hover` changes neither the label ink nor the icon of an unselected radio beyond
  the boundary and background above.

## Verification

| Layer | File | What it asserts |
| --- | --- | --- |
| Behaviour | [`lumiere_radio_test.dart`](../../test/lumiere_radio_test.dart) | A standalone radio reports `true`; a selected one is not cleared by a tap; the label activates it; `disabled` blocks it; every `checked` x `disabled` x `icon` combination renders. |
| Semantics | the same file | The label is the name; checked and unchecked are exposed with group membership; the group node has the `radioGroup` role; a disabled radio exposes the state and no tap action; focus reaches the node. |
| Geometry | the same file | The interactive box is 24 x 24. The circle, the dot, the icon and the ring are not asserted. |
| Colour resolution | the same file | Every role above, in both themes, by reading the painter; the label ink; the hover step of the ramp; the icon colour of the selected variant. |
| Group behaviour | the same file | One tab stop; arrows move and select and wrap; Space selects the focused radio; a disabled radio is skipped. |
| Golden | [`lumiere_radio_golden_test.dart`](../../test/golden/lumiere_radio_golden_test.dart) | Two panels, dark then light: checked, disabled, the icon variant, focus, the label-less row and a group. |
| Contrast | [`contrast_test.dart`](../../test/accessibility/contrast_test.dart) | `borderHeavy` on the page (5.75:1 dark, 3.24:1 light) and the light accent fill against its white dot. The dark accent fill against `textOnAccent` is recorded in the dartdoc, not in the table. |

## Status

Measured: the two boxes, the dot and the label gap from the control geometry
export. Unmeasured and named as such: the icon size, the boundary width, the two
radii and the focus ring. The group delegates navigation to the SDK's `RadioGroup`,
so the arrow behaviour and the group role are the SDK's, and this package asserts
them rather than implements them.

## Open items

* `OPEN-03` - `LumiereRadio` has no `semanticLabel`, so a radio without a visible label cannot receive an accessible name.
* `OPEN-09` - The focus ring's contrast is never measured.
* `OPEN-12` - `LumiereRadioGroup(groupValue: null)`, adoption of an external `focusNode`, RTL layout and text scaling are untested.
* `OPEN-13` - `fillSubtle` is a translucent tint here and an opaque fill elsewhere, so one role serves two incompatible purposes.
