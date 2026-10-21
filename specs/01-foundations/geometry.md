# 01 - Geometry

Four scales and one set of strokes. Heights, paddings and gaps are mode-independent
constants; nothing here travels through the theme extension. Material is not allowed
to decide any of it: `ThemeData.visualDensity` stays at its default and the button pins
`tapTargetSize` itself.

## Spacing

| Token | Value |
| --- | --- |
| `spaceXs` | 4 |
| `spaceSm` | 8 |
| `spaceMd` | 12 |
| `spaceLg` | 16 |
| `spaceXl` | 20 |

The approved scale supersedes the 4 / 8 / 16 / 24 that the Space component declares. It
adds 12 and 20 because those are the measured control paddings, and drops 24 in favour
of 20. The names kept their positions rather than their values, so `spaceMd` is 12 and
`spaceLg` is 16. Consumers today: the tag's horizontal padding 8, label gaps 4, the
divider's gap 8 and short line 20, the switch's label gap 8.

## Radius

| Token | Value | Consumer |
| --- | --- | --- |
| `radiusSm` | 2 | Visible box of a control, tag, rectangle button |
| `radiusMd` | 4 | Hover and focus shape of a 24 px control, rectangle switch track |
| `radiusLg` | 8 | None yet |
| `radiusFull` | 999 | Pill and circle button, circle switch track and handle |

## Controls

| Size | Height | Horizontal padding |
| --- | --- | --- |
| `mini` | 24 | 12 |
| `small` | 28 | 16 |
| `medium` | 32 | 16 |
| `large` | 36 | 20 |

Measured from the geometry of the Arco kit: 30 variants per size, zero variance. It is
not the project's Figma file, whose account was rate limited; the provenance is on the
class and the values match the ones the tokens already carried.

| Tag size | Height |
| --- | --- |
| `large` | 32 |
| `medium` | 28 |
| `small` | 24 |
| `mini` | 20 |

91 variants per size, zero variance. The tag is four pixels shorter than the control of
the same name, so it has its own scale instead of borrowing the control one.

## Strokes

| Token | Value | Source |
| --- | --- | --- |
| `hairline` | 1 | Measured: separators are one pixel with a one pixel offset in both files |
| `dash` | 4 | Not declared by the design; the value the button already used, RECORDED pending |
| `gap` | 3 | Same |

The focus ring is 2 pixels wide, inset 1 from the edge of the measured interactive box,
and therefore drawn inside it. The constant is declared privately, three times, and
identically: [checkbox](../../lib/src/components/checkbox/lumiere_checkbox.dart#L48-L58),
[radio](../../lib/src/components/radio/lumiere_radio.dart#L38-L48),
[switch](../../lib/src/components/switch/lumiere_switch.dart#L210-L220).

## Measured component geometry

| Component | Interactive box | Visible shape | Parts |
| --- | --- | --- | --- |
| Checkbox | 24 × 24 | 14 × 14 | Tick 4 × 7, dash 6 × 2, border 1, tick stroke 1.5, radius 2, outer 4 |
| Radio | 24 × 24 | 14 × 14 | Dot 4, icon 10, border 1, outer 4 |
| Switch, `circle` and `rectangle` | 40 × 24 | 40 × 24 | Handle 16 |
| Switch, `small` | 28 × 16 | 28 × 16 | Handle 12 |
| Switch, `line` | 36 × 20 | 36 × 6 | 28 × 4 at `small`, handle 20 |
| Tag | by `ArcoTag` | by `ArcoTag` | Padding 8, radius 2 |
| Divider | content | 1 thick | Short line 20, gap 8 |

## Fallbacks

A value the export does not carry falls back to the nearest approved step and names it.

| Value | Falls back to |
| --- | --- |
| Checkbox visible radius, exported as 0.5 | `radiusSm` |
| Checkbox and radio outer radius | `radiusMd` |
| Switch `rectangle` track and handle radius | `radiusMd` |
| Switch track content inset | `spaceXs` |
| Checkbox and radio label gap, measured 3 | `spaceXs` |
| Radio icon in a 14 px circle | `ArcoType.size10` |
| Switch handle icon, 16 px handle | `ArcoType.size10` |
| Switch handle icon, 12 px handle | `spaceSm` — a spacing step used as an icon size |

## Rules already in force

| ID | What it binds | Enforced by |
| --- | --- | --- |
| `DS-SPACE-001` | Every spacing value is one of the five approved steps; the Space component's 4 / 8 / 16 / 24 is superseded | [`lumiere_button_test.dart:204`](../../test/lumiere_button_test.dart#L204-L218) |
| `DS-CONTROL-001` | A control's height and its horizontal padding are read from `ArcoControl` as a pair, and every padding lands on the spacing scale | [`lumiere_button_test.dart:220`](../../test/lumiere_button_test.dart#L220-L248) |

## Rules

**DS-SPACE-002 - A gap is a step.** A gap, inset or margin `MUST` be a value of the
spacing scale. A measured value off the scale `MUST` fall back to the nearest step and
`MUST` name that step where it is declared.

**DS-CONTROL-002 - A control height comes from a control scale.** A control `MUST` read
its height and padding from `ArcoControl`, or from `ArcoTag` where it is a tag. A
private height constant `MUST NOT` be declared for a control a scale covers, and the
tag `MUST NOT` be made to borrow the control scale.

**DS-CONTROL-003 - A private geometry constant names its source.** A component `MAY`
declare a private geometry class only for values no scale covers. Every member of it
`MUST` name the measured layer it came from, and every member that is not measured
`MUST` say so and name the token it falls back to.

**DS-RADIUS-001 - A radius comes from the scale.** A corner radius `MUST` be one of the
four radius tokens. A radius off the scale `MUST NOT` be written even when the export
carries it: the checkbox's 0.5 becomes `radiusSm`.

**DS-RADIUS-002 - A full round reads `radiusFull`.** A shape that must be fully round
`MUST` read `radiusFull`. Where a painter needs half the measured height it `MUST`
derive that from the height where it is used rather than write the result as a literal.

**DS-RADIUS-003 - A fallback radius names its token.** A radius the design does not
carry `MUST` be the closest approved step, named in the field's dartdoc. All three
instances today are in the table above.

**DS-RADIUS-004 - A control owns at most two radii.** The visible shape of a control
and its hover or focus shape are the two radii it may have; a third `MUST NOT` appear
inside one control.

**DS-STROKE-001 - A line weight comes from `LumiereStrokes`.** A separator, border or
dashed line `MUST` read `hairline`, `dash` or `gap`. A component `MUST NOT` write `1`
for a thickness or `4` and `3` for a dash pattern. The recorded exception is OPEN-02.

**DS-STROKE-002 - The hairline is measured, the dash is not.** `hairline` `MUST` stay 1
and keep its measurement citation. `dash` and `gap` `MUST` stay labelled as pending
confirmation wherever they are documented: the design declares no dash pattern, so no
measurement can be cited for them.

**DS-STROKE-003 - The ring stays inside the box.** A focus indicator `MUST` be 2
logical pixels wide, inset 1 from the edge of the measured interactive box, and `MUST`
be drawn inside it so focus does not change the layout (DS-CONST-08). A ring drawn
outside the box `MUST NOT` be added.

**DS-STROKE-004 - One ring, three declarations.** The three private declarations of the
ring `MUST` stay identical in width and inset. A change to one `MUST` change all three
and `MUST` be reported as drift while the value has no single owner.

## Status

Measured: the five spacing steps, four radii, four control heights with their paddings,
four tag heights, `hairline`, both focus ring values, and every number in the component
table. Control padding is asserted to land on the spacing scale, which is what makes
`DS-SPACE-001` and `DS-CONTROL-001` verifiable rather than declarative.

Not measured: `dash` and `gap`, which no design value covers; `radiusLg`, which has no
consumer, so nothing exercises 8; `spaceMd` and `spaceLg`, which only the tests and the
gallery use. Focus ring contrast is never measured in either theme, and the button draws
no ring at all, so DS-STROKE-003 holds for three of the four focusable controls (OPEN-09).

The specification matches the code today, with three exceptions: the button's dashed
painter keeps private 4 / 3 / 1 instead of reading `LumiereStrokes` (OPEN-02); the
switch dartdoc still declares a 10 px small handle while the code draws the measured 12
(OPEN-16); the focus ring is declared three times.

## Open items

- OPEN-02 - The button's dashed painter keeps private 4 / 3 / 1 literals instead of
  reading `LumiereStrokes`, which is the one standing breach of DS-STROKE-001.
- OPEN-09 - Focus-ring contrast, a 2 px accent ring against the surfaces, is never
  measured, and the button draws no ring; DS-STROKE-003 is enforced for three of the
  four focusable controls and for geometry only.
- OPEN-16 - `LumiereSwitch`'s dartdoc still declares a 10 px small handle while the code
  uses the measured 12 recorded above, and its dark-theme contrast figures name the wrong
  pair.
- OPEN-23 - `dash` and `gap` are placeholders no design value covers; until this entry
  existed, the two values labelled RECORDED above broke DS-CONST-04.
