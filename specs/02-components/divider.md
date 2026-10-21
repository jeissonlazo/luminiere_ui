# 02 - Divider

## Contract

`DS-COMP-018`. The divider is a separator: one hairline, optionally dashed, optionally
labelled, and optionally placed. It mirrors the `Divider` component set of the design file,
with `orientation`, `dashed`, a label and an `align` that says where the label sits.

The promise: **a divider draws one hairline in one direction from one role, adds no spacing of
its own, and stays out of the accessibility tree except for its label.**

Source: [`lumiere_divider.dart`](../../lib/src/components/divider/lumiere_divider.dart).
Tests: [`lumiere_divider_test.dart`](../../test/lumiere_divider_test.dart),
[`lumiere_divider_golden_test.dart`](../../test/golden/lumiere_divider_golden_test.dart).

## Axes

| Axis | Values | Lives in |
| --- | --- | --- |
| `orientation` | `horizontal`, `vertical` | parameter `LumiereDividerOrientation orientation` |
| `dashed` | false, true | parameter `bool dashed` |
| label | absent, a `String` | parameter `String? label` |
| `align` | `start`, `center`, `end`, `none` | parameter `LumiereDividerAlign align` |

The design declares no state axis and the widget has none: no hover, no focus, no disabled and
no pressed. `align` is not a state either; it is a layout choice, and it only places a label
that already exists. `start` and `end` put one short line on the side the label sits, `center`
gives two equal lines, and `none` gives no line at all.

## API

| Parameter | Type | Default | Semantics |
| --- | --- | --- | --- |
| `orientation` | `LumiereDividerOrientation` | `horizontal` | The direction. It selects the axis that is measured and the one that is unbounded. |
| `label` | `String?` | `null` | Text in the line. `null` and `''` both mean absent: no `Text` is built and no line is split. |
| `align` | `LumiereDividerAlign` | `center` | Where the label sits, and therefore which side carries the short line. |
| `dashed` | `bool` | `false` | Draws a dash pattern instead of a solid box. It applies to both orientations and to both lines of a labelled divider. |

**DS-API-018-01** - The widget MUST expose exactly these four parameters. A colour, thickness,
inset, margin or child parameter would let a caller describe a separator the design does not
declare (`DS-CONST-03`).

**DS-API-018-02** - A divider MUST carry no margin. The space around a separator belongs to the
layout that places it; a component that adds its own padding cannot be composed into a column
of mixed content.

**DS-API-018-03** - A vertical divider MUST ignore `label` and `align`. The design declares no
labelled vertical variant, and the build returns before the label is read, so a caller MUST NOT
expect one.

**DS-API-018-04** - The widget MUST be a leaf: no children, no `Semantics` wrapper and no gesture
recogniser.

## Geometry

| Value | Measured | Source |
| --- | --- | --- |
| Thickness | 1 | `LumiereStrokes.hairline`; the design draws its separators as one pixel |
| Dash and gap | 4 and 3 | `LumiereStrokes.dash` / `.gap`; **not measured**: the design declares no dash metrics |
| Gap around a label | 8 on each side | `ArcoSpace.spaceSm` |
| Short line, `start` and `end` | 20 | `ArcoSpace.spaceXl`; **fallback**: the file measures 21 and 20 is the approved step |
| Label size | 14 | `ArcoType.size14` |
| Length, horizontal | fills the width it is given | the `SizedBox` takes the offered width |
| Length, vertical | fills the height of the row | infinite length, so the parent row decides |

**DS-COMP-018-01** - A horizontal divider MUST fill the width it is given and therefore needs a
bounded parent: a caller MUST wrap it in a `SizedBox` or an `Expanded`, exactly as Flutter
requires of a stretched box. A vertical divider MUST stretch to the height of the row it belongs
to, and that row MUST have a bounded height (`DS-CONST-10`).

The dashed metrics are not declared anywhere in the design. They are the values the button's
dash painter already used, kept consistent and recorded as pending; no `OPEN-nn` covers them.
The pattern is one segment of `dash` every `dash + gap`, drawn with butt caps from the leading
edge, with the last segment clamped to the available length.

## Colour resolution

| Part | Role | Notes |
| --- | --- | --- |
| Line, either orientation, dashed or solid | `borderDefault` | The separator role, never a control boundary. |
| Label | `textTertiary` | Normal text at 14 px. |

**DS-COMP-018-02** - The line MUST resolve from the separator role and MUST NOT be chosen per state,
because a divider has no state. `borderDefault` is registered under `AE-10`, so 3:1 is never
required of it: it measures 1.96 on the page in the dark theme and 1.25 in the light one
([`contract.md`](../03-accessibility/contract.md), `DS-A11Y-006`). A divider used as the only
edge of a control is a violation of that section, not a variant of this component.

The label is normal text, so 4.5:1 applies and it is measured: `textTertiary` on the page
measures 4.68 in the light theme and 5.26 in the dark one. The divider paints no background, so
that one pair is the whole colour contract of the component.

## Accessibility

| Aspect | Today |
| --- | --- |
| Role | None. The widget is a `ColoredBox` or a `CustomPaint`, so a line produces no semantics node. |
| Accessible name | None. The label is a plain `Text` and keeps its own text semantics, in reading order. |
| States exposed | None. |
| Keyboard | None: the divider is not focusable. |
| Focus indicator | None, and none is required, because nothing can focus it. |
| Indicator geometry | Not applicable. |

**DS-A11Y-018-01** - The line MUST NOT enter the semantics tree. It carries no information, and
an announced separator interrupts the content it separates.

**DS-A11Y-018-02** - A label MUST keep its own text semantics, so the section it names is
reachable without the line.

**DS-A11Y-018-03** - The divider MUST NOT be focusable and MUST NOT draw a ring. A tab stop on a
separator is a defect in the caller's layout, not a feature of this widget.

## States that do not exist

* Hover, pressed, focused and disabled: a divider has no interaction and no state.
* Emphasis, colour, opacity or thickness variants: one hairline, one role.
* A vertical label, or a labelled vertical divider: the design declares none.
* A label with a line on one side only: `none` removes both lines.
* A `child` or content slot: content between sections belongs to the layout.
* Inset, indent, margin or padding: the widget is exactly as long as its parent allows.
* A marching or animated dash: the pattern is static, and no motion value exists to animate it
  with.

## Verification

| Layer | File | What it asserts |
| --- | --- | --- |
| Behaviour | [`lumiere_divider_test.dart`](../../test/lumiere_divider_test.dart) | A dashed divider paints instead of filling a box; a label renders; an empty label renders no text. |
| Semantics | the same file | The label is in the semantics tree and the line is not. |
| Geometry | the same file | The horizontal hairline height against a 200 px width, and the vertical hairline width against a 120 px row. |
| Colour resolution | the same file | `borderDefault` in both themes, read through the tokens of each. |
| Alignment | the same file | Two lines for the three labelled alignments and none for `none`, and the presence of a `spaceXl` line for `start` and `end`. |
| Golden | [`lumiere_divider_golden_test.dart`](../../test/golden/lumiere_divider_golden_test.dart) | The four alignments, a dashed horizontal line and two vertical dividers. |
| Contrast | [`contrast_test.dart`](../../test/accessibility/contrast_test.dart) | The label's `text.3` row on the page in both themes; `borderDefault` is registered under `AE-10` and never asserted. |

Gaps: for `start` and `end` the test asserts only that a short line exists, not which side of
the label it sits on, and the dashed vertical divider appears in no test other than the golden
(`OPEN-12`).

## Status

Measured: the hairline, the 20 px short line, the 8 px gaps and the 14 px label. Unmeasured: the
dash metrics, which the design does not declare and which stay pending. `align: none` is read as
"label without lines", an interpretation of the design's value and not a measurement
(`OPEN-17`); it is also the only `align` that draws no line.

The golden does not verify a theme. Each panel paints a bare
`ColoredBox(LumiereColors.<theme>.surfaceBase)` while the surrounding `Theme` stays dark, so the
light panel draws the dark `borderDefault` (`#484849`) on white: the baseline measures `#A3A3A4`,
that colour antialiased over the panel, where the light theme's own `#E5E6EB` belongs. The panel
is a hybrid no theme produces (`OPEN-08`).

## Open items

* `OPEN-08` - The divider golden renders its "light" panel with dark tokens, because the divider paints inside a dark `Theme`.
* `OPEN-12` - `align: start` and `end` do not verify which side the short line sits on, and the dashed vertical divider is only visible in a golden.
* `OPEN-17` - `LumiereDivider` `align: none` means "label without lines"; that reading is an interpretation, not a measurement.
* `OPEN-23` - The dash metrics (`4` and `3`) are placeholders the design does not declare, and no register entry held them.
