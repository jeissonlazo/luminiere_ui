# 01 - Colour

Colour reaches a component only through a semantic role. The primitive classes are
generated and not exported, so a role is the whole public surface: an application can
replace a role, and nothing else in the package moves.

## Roles

Every role points at one primitive of the mode it belongs to. The right-hand column is
the description the design file attaches to the token, which is what the mapping
follows.

| Role | Primitive | Design description |
| --- | --- | --- |
| `surfaceBase` | `bg.1` | Page background |
| `surfaceContainer` | `bg.2` | First container level |
| `surfaceRaised` | `bg.3` | Second container level |
| `surfaceOverlay` | `bg.5` | Dropdown and tooltip background |
| `textPrimary` | `text.1` | Emphasis |
| `textSecondary` | `text.2` | Secondary |
| `textTertiary` | `text.3` | Tertiary |
| `textDisabled` | `text.4` | Disabled |
| `textOnAccent` | `bg.white` | Foreground on an accent fill |
| `borderSubtle` | `border.1` | Subtle separator |
| `borderDefault` | `border.2` | Normal boundary |
| `borderStrong` | `border.3` | Strong boundary, hover |
| `borderHeavy` | `border.4` | Heavy boundary, button outline; the boundary that identifies a control |
| `fillSubtle` | `fill.1` | Subtle fill, disabled overlay |
| `fillDefault` | `fill.2` | Normal overlay |
| `fillStrong` | `fill.3` | Strong overlay |
| `fillHeavy` | `fill.4` | Heavy overlay |
| `accent`, `success`, `warning`, `danger` | four ramps | See below |

`bg.4` is generated and measured by the accessibility tests, and has no role: no
component in this package sits on a fourth container level.

## The nine fields of a family

| Field | Step | Meaning |
| --- | --- | --- |
| `subtle` | 1 | Subtle background of the family |
| `textDisabled` | 2 | Text of a disabled control |
| `disabled` | 3 | Fill of a disabled control |
| `normal` | 6 | Normal fill or decorative foreground |
| `hover` | 5 | Hover |
| `active` | 7 | Pressed |
| `solidFill` / `solidLabel` | pair | Fill of a solid surface and the ink on it |
| `onSubtle` | nearest step to 6 that reaches 4.5:1 | Ink for text on the family's own `subtle` |

Step 4, "special cases", has no field.

## Solid pairs

A pair is read from one family and measured as a pair. The ratios below are the ones
[`contrast_test.dart:276`](../../test/accessibility/contrast_test.dart#L276-L283)
records; `ink` is `#1D2129`, `text.1` of the light theme.

| Family | Dark: fill + label | Ratio | Light: fill + label | Ratio |
| --- | --- | --- | --- | --- |
| accent | `primary.4` + white | 6.90 | `primary.6` + white | 5.19 |
| success | `success.6` + ink | 6.90 | `success.6` + ink | 5.81 |
| warning | `warning.6` + ink | 7.41 | `warning.6` + ink | 6.29 |
| danger | `danger.6` + ink | 5.50 | `danger.7` + white | 5.43 |

## Asymmetries carried by the export

| Fact | Value |
| --- | --- |
| Brand blue, light mode | `#165DFF`, Arco's original blue |
| Brand blue, dark mode | `#3C7EFF`, customised in the design file |
| Accent solid fill | Step 4 in the dark theme, step 6 in the light one |
| Light `text.3` | `#6A7583` by override, not the exported `#86909C`, to reach 4.68:1 |
| Dark `text.3` | Translucent white at alpha 128, above the threshold at 5.26:1 |
| Light surfaces | `bg.1` to `bg.5` are all `#FFFFFF`, so the container hierarchy exists only in the dark theme |
| Light `danger` pair | `danger.7` with white: dark ink measures 2.97 there, white 5.43 |

## Tag families

Eleven names, kept untranslated because they are an axis of the tag and not prose. The
mapping was verified against measured hex, not against the names: `youthPurple` lands
on the pink-purple family and `ultimateBlue` on the primary ramp.

| Name | Palette family | `subtle` / `strong` / `ink` |
| --- | --- | --- |
| `neutral` | none: `fill.2` / `fill.3` / `text.1` | semantic roles, not a ramp |
| `romanticRed` | red | steps 1 / 2 / 6 |
| `wildGreen` | green | steps 1 / 2 / 6 |
| `blueTide` | cyan | steps 1 / 2 / 6 |
| `vitalityOrange` | orange | steps 1 / 2 / 6 |
| `lateAutumnRed` | orange-red | steps 1 / 2 / 6 |
| `dusk` | gold | steps 1 / 2 / 6 |
| `youthPurple` | pink-purple | steps 1 / 2 / 6 |
| `magenta` | magenta | steps 1 / 2 / 6 |
| `ultimateBlue` | primary | steps 1 / 2 / 6 |
| `seaBlue` | blue | steps 1 / 2 / 6 |

## Rules

**DS-COL-001 - A role is the only colour a component reads.** A component `MUST` take
every colour from `LumiereColors`, `LumiereStatusColors` or `LumiereTagColor`. It `MUST
NOT` name a primitive class, and it `MUST NOT` write a `Color(...)` or a
`Colors.transparent` where a role exists.

**DS-COL-002 - A role follows the design description.** A role `MUST` map to the
primitive the design file describes for that purpose. Re-pointing a role at a
different step `MUST` cite the description that requires it, and the role-to-primitive
mapping `MUST` stay asserted by a test that names both.

**DS-COL-003 - A fill and its label are a pair.** A solid surface `MUST` take both its
fill and its ink from one family's `solidFill` and `solidLabel` (DS-CONST-11). A
component `MUST NOT` fill from one family and label from another, and `MUST NOT`
choose a label by eye.

**DS-COL-004 - `textOnAccent` is the ink of an accent fill.** A foreground on an
accent-ramp fill `MUST` be `textOnAccent`. Where a solid pair exists the pair wins,
because the pair is the measured combination and `textOnAccent` is the general one.

**DS-COL-005 - Every family declares all nine fields.** `LumiereStatusColors` `MUST`
be complete for all four families in both modes: no field optional, no field
transparent, and no family reachable other than through `rampFor`. A new family `MUST
NOT` be added without its nine fields and its measured solid pair.

**DS-COL-006 - A step's meaning is fixed.** `normal` is step 6 and is a decorative
fill or a foreground; it `MUST NOT` be used as the ink for text on its own family's
`subtle` background in the light theme, where it measures 2.41 to 3.25 for success,
warning and danger. Text there `MUST` use `onSubtle`.

**DS-COL-007 - `onSubtle` reaches the text threshold.** `onSubtle` `MUST` measure at
least 4.5:1 against its own `subtle`. It `MUST` be the closest step to 6 that reaches
that, and it `MUST` differ from `normal` only when `normal` fails
([`status_ink_test.dart:62`](../../test/accessibility/status_ink_test.dart#L62-L90)).

**DS-COL-008 - Tag colour is reached by name.** A component `MUST` read a tag family
through `LumiereColors.tag(name)`, never by indexing `tagColors`. The `neutral` entry
`MUST` exist in both modes as the fallback, and `tag` `MUST` keep falling back to it
rather than throwing.

**DS-COL-009 - A tag name is not translated, and its mapping is measured.** The eleven
names `MUST` keep the design's spelling. A new name `MUST` arrive with the measured
hex that identifies its palette family; naming alone `MUST NOT` decide the mapping.

**DS-COL-010 - An overlay role is not an opaque surface.** The `fill` roles are opaque
in the light theme and translucent white in the dark one, so a component `MUST NOT`
treat `fillSubtle` to `fillHeavy` as a surface that a solid colour can be measured
against in both themes; a surface that must be opaque `MUST` come from the `surface`
roles (OPEN-13).

**DS-COL-011 - An override is recorded and pinned.** A change to a generated colour
`MUST` name the register entry it serves and the ratio it fixes, and `MUST` be pinned
to its value by a test. AE-08 is the shape of it: `#6A7583`, 4.68:1, asserted in
[`status_ink_test.dart:158`](../../test/accessibility/status_ink_test.dart#L158-L167).

## Status

Measured: the 17 role mappings, the four ramps and their nine fields, the four solid
pairs at their recorded ratios, the eleven tag families, and the seven asymmetries
above. The solid pairs are asserted as pairs in both themes, so DS-COL-003 is in force
rather than aspirational.

Not measured: tag label contrast against `subtle` and `strong`. Ten of the eleven light
families fail 4.5:1 in at least one form; only `neutral` is compliant in both,
`ultimateBlue` reaches 4.62 on the soft background alone, and the other nine fail both.
In the dark theme `wildGreen` (4.32) and `youthPurple` (4.40) fall short on the filled
form. The families are absent from the contrast contract, so no test covers them
(OPEN-06). The `fill` roles are measured per theme but not for a use that requires an
opaque surface (OPEN-13).

The specification matches the code today. The one role mismatch is the tag label: the
tag draws `ink` on both backgrounds, which is the design's declaration and not a
threshold the register can enforce.

## Open items

- OPEN-06 - The tag label fails 4.5:1 in ten of the eleven light families in at least
  one form, and the families are absent from the contrast contract, so DS-COL-009 and
  the tag ink are outside the measured surface.
- OPEN-13 - `fill1..4` are opaque in the light theme and translucent in the dark one,
  so one role serves two incompatible purposes; DS-COL-010 is unenforceable until they
  are split.
