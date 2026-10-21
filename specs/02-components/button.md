# 02 - Button

## Contract

`DS-COMP-019`. The button is the system's action control: one labelled target that
reports one press, in five visual weights, four semantic colours, four proportions
and four heights. It mirrors the `Button` component set of the design file, whose
option names map to the enums below in `design/variables/terminology.json`. The
promise: **a button keeps the measured height of its size, resolves the colour of
its `type` and `kind` from the token layer, and never lets a caller describe a
state it is not in.**

Source: [`lumiere_button.dart`](../../lib/src/components/button/lumiere_button.dart),
364 lines.

## Axes

| Axis | Values | Lives in |
| --- | --- | --- |
| `type` | `primary`, `secondary`, `dashed`, `outline`, `text` | parameter `LumiereButtonType type` |
| `kind` | `standard`, `danger`, `warning`, `success` | parameter `LumiereButtonKind kind` |
| `shape` | `rectangle`, `pill`, `square`, `circle` | parameter `LumiereButtonShape shape` |
| `size` | `large`, `medium`, `small`, `mini` | parameter `LumiereButtonSize size` |
| `state` | `default`, `hover`, `focus`, `active`, `disabled` | real widget state, through `WidgetStateProperty` |
| `loading` | present, absent | parameter `isLoading` |

`shape` decides two things at once: the corner radius, and whether the box is
free-width or square. `rectangle` and `pill` are free-width; `square` and `circle`
are icon-only boxes of `height x height`. A free-width circle is not expressible,
which is a property of the design file, not a gap in the widget.

`state` MUST NOT become a parameter (`DS-CONST-05`). `loading` stays a property
because no Material widget state expresses it: a loading button counts as not
enabled, so it is inert, draws no label, and shows the indicator in place of its
content.

## API

| Parameter | Type | Default | Semantics |
| --- | --- | --- | --- |
| `label` | `String` | required | Visible text and the accessible name. `''` is legal and hides the text; with no visible text the button then has no accessible name (`OPEN-03`), and the box centres its icon alone. |
| `onPressed` | `VoidCallback?` | `null` | The action. `null` is the only way to disable the button: it paints the disabled set and reports no tap. |
| `type` | `LumiereButtonType` | `primary` | Visual weight; selects the background and foreground rules below. |
| `kind` | `LumiereButtonKind` | `standard` | Selects the ramp: `standard` uses `LumiereRamp.accent`, the other three their own. |
| `shape` | `LumiereButtonShape` | `rectangle` | Corner radius and proportion together. |
| `size` | `LumiereButtonSize` | `medium` | Control height and horizontal padding together. |
| `leadingIcon` | `Widget?` | `null` | Decorative icon before the label. `null` draws nothing; a non-null icon is excluded from the semantics tree. |
| `trailingIcon` | `Widget?` | `null` | The same, after the label. |
| `isLoading` | `bool` | `false` | Replaces the whole content with a `LumiereLoading` at the icon size and blocks activation. |
| `isFullWidth` | `bool` | `false` | Stretches a free-width button to the offered width. Ignored by `square` and `circle`, which keep the measured box. |

**DS-API-019-01** - A disabled button MUST be a null callback; the widget MUST NOT
accept a `disabled` parameter, because a flag that disagrees with the callback
produces a control that looks inert and still presses.

**DS-API-019-02** - Every state MUST be resolved from the widget, `isLoading` alone
excepted. No parameter may name a state.

**DS-API-019-03** - Colour MUST NOT be configurable: `type` and `kind` are closed
enums, and no parameter takes a `Color`, a height or a radius (`DS-CONST-02`,
`DS-CONST-03`).

**DS-API-019-04** - The name MUST have one source, `label`; the widget MUST NOT
expose a second name parameter (`DS-CONST-06`). An icon-only shape therefore has
no name today (`OPEN-03`).

## Geometry

| Value | Measured | Source |
| --- | --- | --- |
| Height, large / medium / small / mini | 36 / 32 / 28 / 24 | `ArcoControl.heightLarge … heightMini` |
| Horizontal padding, large / medium / small / mini | 20 / 16 / 16 / 12 | `ArcoControl.paddingLarge … paddingMini` |
| Radius, `rectangle` and `square` / `pill` and `circle` | 2 / 999 | `ArcoRadius.radiusSm` / `.radiusFull` |
| Box, `square` and `circle` | `height x height`, horizontal padding 0 | `SizedBox` in the widget |
| Label, `large` / the rest | size 16 / 14 at weight 400, line height 24 / 22 | `ArcoType` and the type scale's pairing |
| Icon size, `large` / the rest | 20 / 16 | `ArcoType.size20` / `size16` |
| Gap between an icon and the label | 4 | `ArcoSpace.spaceXs`; omitted when `label` is `''` |
| Minimum size | `(0, height)` | pinned on the `TextButton` style |
| Dashed border radius handed to the painter | `height / 2` when the radius exceeds the height, else the radius | derived in the widget |
| Dash, gap, stroke of the dashed border | 4 / 3 / 1 | private literals, **not** tokens - `OPEN-02` |

The heights and paddings are measured on the Arco control geometry, 30 variants per
size with zero variance. The four heights are asserted; the padding, the radius and
the icon size are read from tokens and asserted by no test.

**DS-COMP-019-01** - A button MUST take its height and its padding together from the
`ArcoControl` step of its `size`, and MUST pin `tapTargetSize` to `shrinkWrap` and
`visualDensity` to `standard`, so Material never decides the box (`DS-CONST-10`).

## Colour resolution

`kind` selects the ramp before any state is resolved: `standard` maps to
`LumiereRamp.accent`, and `danger`, `warning` and `success` to the ramp of the same
name. Every row below is a role of that ramp; the overlay row is the defect
measured after the table.

| State | Role | Notes |
| --- | --- | --- |
| `primary`, default | fill `solidFill`, ink `solidLabel` | The pair, from one ramp (`DS-CONST-11`). |
| `primary`, hover | fill `hover` | Overpainted by `fillDefault`; measured below. |
| `primary`, focus | fill `solidFill` plus the overlay | Material paints the same overlay as for hover. No ring is drawn. |
| `primary`, pressed | fill `active` | The ink stays `solidLabel`; there is no pressed ink step. |
| `primary`, disabled | fill `disabled`, ink `textOnAccent` | The ink does not change when the fill does. |
| `secondary`, default | fill `fillDefault`, ink `normal` | Neutral surface fill. |
| `secondary`, hover | fill `fillStrong`, ink `hover` | Overpainted by an opaque `fillDefault`. |
| `secondary`, pressed | fill `fillHeavy`, ink `normal` | No pressed ink step. |
| `secondary`, disabled | fill `fillSubtle`, ink `textDisabled` | Weaker than the resting fill. |
| `dashed`, `outline`, `text`, enabled | background `transparent`, ink `normal` on default and pressed, `hover` on hover | The state of these three types is carried by the ink only. |
| the same three, disabled | background `transparent`, ink `textDisabled` | — |
| `outline` side, `dashed` border | `normal`, `disabled` when disabled | One hairline; the dash painter keeps its own stroke width (`OPEN-02`). |
| Icons, every type | `normal`, `textDisabled` when not enabled | Set through an `IconTheme` merge, so on a `primary` button the glyph takes the ramp's `normal` step, not `solidLabel`. |
| Loading indicator | `textDisabled` | A loading button is not enabled, so the indicator takes that step. |

**DS-COMP-019-02** - A solid button MUST take its fill and its ink from the
`solidFill` / `solidLabel` pair of one ramp, and MUST NOT mix families
(`DS-CONST-11`). The resting `primary` state does this; hover and pressed keep the
design's own ramp steps and are not documented as usable pairs: the label measures
3.65:1 on the light hover, 3.74:1 on the dark `normal`, 4.34:1 on the dark hover and
2.63:1 on the dark `active` — above 3:1 as a graphic indicator, below the 4.5:1
normal text needs, and below both on the dark pressed step. The widget's dartdoc
cites `AE-12` to `AE-15` for these combinations; the
[exception register](../03-accessibility/exception-register.md) holds no such
entries, so the citation is unresolved there.

### The rule the overlay breaks (`OPEN-01`)

**DS-COMP-019-03** - A state MUST be painted by the background colour resolved for it.
`overlayColor` MUST be transparent, so Material's hover, focus and press
highlights cannot composite over that fill.

It is set unconditionally to `fillDefault`. In the light theme that role is
opaque, so it replaces the fill; in the dark theme it is white at `20/255` alpha,
so it tints the fill and moves the ratio. Measured on a `primary`, standard button:

| Theme | Resolved fill | Overlay | Rendered | Label | Ratio |
| --- | --- | --- | --- | --- | --- |
| light | `accent.hover` | `fillDefault`, opaque | `#F2F3F5` | `accent.solidLabel` | 1.11:1 |
| dark | `accent.hover` = `#306FFF` | `fillDefault`, white at `20/255` | `#407AFF` | `accent.solidLabel` | 3.86:1, against 4.34:1 without the overlay |
| light, `secondary` | `fillStrong` | `fillDefault`, opaque | `#F2F3F5` | `accent.normal` | renders the resting fill |

The last row is the second half of the defect: the resting `secondary` background
is that same `fillDefault`, so an opaque overlay renders hover identically to rest
and the secondary button loses its hover feedback. Material paints the same overlay
for `focused`, so the light theme's focus indication is that 1.11:1 surface.

The `Rendered` column is measured output, not a role. It is the one place this
specification names a hexadecimal value, because the defect is the gap between the
token and what reaches the screen, and that gap has no role to name.

**DS-COMP-019-04** - One role MUST NOT serve both as an opaque surface fill and as a
translucent overlay tint; `fillDefault` is opaque in the light theme and
translucent in the dark one, and the checkbox's hover background reads it for the
second purpose (`OPEN-13`).

## Accessibility

| Aspect | Today |
| --- | --- |
| Role | Button, supplied by `TextButton`. |
| Accessible name | `label`, through the `Text` child; `leadingIcon` and `trailingIcon` sit inside `ExcludeSemantics` and contribute nothing. |
| States exposed | Enabled, and the tap action. No checked state. |
| Keyboard | Material's own focus and activation; the widget handles no key. No test here presses a key on a button. |
| Focus indicator | None drawn by the widget. Focus is the `fillDefault` overlay, whose contrast is unmeasured (`OPEN-09`), so `DS-CONST-08`'s ring has no subject here. |

**DS-A11Y-019-01** - The accessible name MUST be the visible `label`, and the button
MUST NOT require the caller to wrap it in a `Semantics` widget (`DS-CONST-06`).

**DS-A11Y-019-02** - A decorative icon MUST NOT contribute to the accessible name.

**DS-A11Y-019-03** - A loading button MUST NOT report a press, and MUST keep its
name; it does not, because the label becomes a `LumiereLoading` inside an
`ExcludeSemantics` (`OPEN-04`).

**DS-A11Y-019-04** - A button with no visible label MUST still receive a name;
`square` and `circle` cannot, because there is no `semanticLabel` (`OPEN-03`).

## States that do not exist

* `pressed` has no ink and no shape of its own: `active` is a ramp step, so a press
  changes the fill of a `primary` button and nothing else. `hover` on a `primary`
  label does not exist either; the ink is `solidLabel` in every enabled state.
* `focus` has no visual of its own: no ring, no offset, no second stroke.
* `loading` is not a state of the design set; it is the one property that behaves
  like one.
* `selected`, `toggled`, `error` and `read-only` do not exist: the button reports
  an action, not a value.

## Verification

| Layer | File | What it asserts |
| --- | --- | --- |
| Behaviour | [`lumiere_button_test.dart`](../../test/lumiere_button_test.dart) | A tap calls `onPressed`; a null callback leaves the `TextButton` without one; `isLoading` blocks the tap and shows a `LumiereLoading`; every `type`, `kind` and `shape` renders without throwing. |
| Semantics | the same file | The label is the accessible name; the two decorative icons do not enter it. |
| Geometry | the same file | The four heights equal `ArcoControl`; `square` and `circle` render a box whose width equals its height. |
| Colour resolution | — | Not covered: no test asserts the resolved background or foreground of any state, which is what `OPEN-12` records for the per-`kind` resolution. |
| Golden | [`lumiere_button_golden_test.dart`](../../test/golden/lumiere_button_golden_test.dart) | One dark panel: one row per `kind` and `type`, then the sizes, the shapes, a disabled button, a loading button and one with an icon. No light and no hover baseline. |
| Contrast | [`contrast_test.dart`](../../test/accessibility/contrast_test.dart) | The accent `solidFill` / `solidLabel` pair and `text.1` on the four overlay roles. The hover and pressed steps are not rows of the table, and no rendered composite is measured anywhere. |

## Status

Measured: heights and paddings from `ArcoControl`, radii from `ArcoRadius`, type
steps from `ArcoType`, the icon-label gap from `ArcoSpace`. 0.6.0 replaces
Material's progress indicator with `LumiereLoading`, breaking for anyone styling
the old one. The committed golden shows the icon ink rule at work: the button with
a leading icon inks its glyph in `ramp.normal` on a `solidFill` surface, so the
glyph barely separates from its background - measured at 1.00:1 in six of the eight
`kind`-and-theme combinations, which is `OPEN-25` and the most severe item in this
file.

## Open items

* `OPEN-01` - The unconditional opaque `overlayColor` composites over the token fill: the light hover renders `#F2F3F5` at 1.11:1 and the dark hover `#407AFF` at 3.86:1, against a recorded `#306FFF` at 4.34:1.
* `OPEN-02` - The dashed painter keeps private `4 / 3 / 1` literals instead of reading `LumiereStrokes.dash`, `.gap` and `.hairline`.
* `OPEN-03` - `square` and `circle` buttons have no `semanticLabel`, so an icon-only button cannot receive an accessible name.
* `OPEN-04` - A button with `isLoading: true` loses its accessible name: the label is replaced by a `LumiereLoading` inside an `ExcludeSemantics`.
* `OPEN-09` - The focus indication is never measured, in either theme.
* `OPEN-12` - `isFullWidth` and the per-`kind` colour resolution are untested, as are RTL and text scaling.
* `OPEN-13` - `fillDefault` serves both as an opaque surface fill and as an overlay tint.
* `OPEN-25` - An icon is inked with `ramp.normal` regardless of `type`, so on a `primary` button it matches the fill: 1.00:1 in six of eight combinations, and an icon-only primary button is a blank rectangle.
