# 02 - Tag

## Contract

`DS-COMP-017`. The tag is a compact coloured label: eleven design families, four heights, a
soft and a strong form, an optional leading icon and an optional close action. It mirrors the
`Tag` component set of the design file, whose colour names are the design's own and are kept
untranslated because they are an axis, not prose.

The promise: **a tag renders one family at one measured height, takes its ink and both of its
backgrounds from that family, and names itself and its close action.**

Source: [`lumiere_tag.dart`](../../lib/src/components/tag/lumiere_tag.dart).
Tests: [`lumiere_tag_test.dart`](../../test/lumiere_tag_test.dart),
[`lumiere_tag_golden_test.dart`](../../test/golden/lumiere_tag_golden_test.dart).

## Axes

| Axis | Values | Lives in |
| --- | --- | --- |
| `size` | `large`, `medium`, `small`, `mini` | parameter `LumiereTagSize size` |
| `color` | `neutral`, `romanticRed`, `wildGreen`, `blueTide`, `vitalityOrange`, `lateAutumnRed`, `dusk`, `youthPurple`, `magenta`, `ultimateBlue`, `seaBlue` | parameter `LumiereTagColorName color` |
| `filled` | true, false | parameter `bool filled`, default `true` |
| `bordered` | true, false | parameter `bool bordered`, default `false`, read together with `filled` |
| icon | absent, a widget | parameter `Widget? icon`; decorative |
| close | absent, a callback | parameter `VoidCallback? onClose` plus `closeSemanticLabel` |

The design declares no state axis: a tag is a label, not a control. The colour names map to
palette families by measured hexadecimal value rather than by reading the name, which is why
`lateAutumnRed` is the `orangeRed` ramp, `blueTide` the `cyan` ramp, `seaBlue` the `blue`
ramp, `dusk` the `gold` ramp and `youthPurple` the `pinkPurple` ramp.

## API

| Parameter | Type | Default | Semantics |
| --- | --- | --- | --- |
| `label` | `String` | required | The text and the accessible name. An empty string is legal and yields an unnamed tag. |
| `color` | `LumiereTagColorName` | `neutral` | Selects a family. It is not a `Color`: a caller cannot leave the palette. |
| `size` | `LumiereTagSize` | `small` | The measured height. The design's default is the 24 px step. |
| `filled` | `bool` | `true` | Uses the soft background of the family. `false` moves to the strong one. |
| `bordered` | `bool` | `false` | Draws a `borderDefault` border. It does not on its own change the background. |
| `icon` | `Widget?` | `null` | Decorative glyph before the label, excluded from semantics. `null` draws nothing. |
| `onClose` | `VoidCallback?` | `null` | Shows the close action. `null` draws no close action and needs no name. |
| `closeSemanticLabel` | `String?` | `null` | The name of the close action, in the application's language. Required when `onClose` is set. |

**DS-API-017-01** - The close action MUST require `closeSemanticLabel`, and the caller MUST pass
it at every call site. The guard is an `assert`, so a release build dereferences null and
throws (`OPEN-05`).

**DS-API-017-02** - `label` MUST be required. A tag with no text has no accessible name and the
package cannot derive one (`DS-CONST-06`).

**DS-API-017-03** - `filled` and `bordered` MUST resolve the background exactly as the table in
*Colour resolution* reads. In particular `bordered: true` alone keeps the soft background,
because `filled` defaults to `true`; a caller who wants the strong one MUST pass
`filled: false, bordered: true`.

**DS-API-017-04** - The widget MUST carry no margin, no minimum width and no truncation: it
sizes to its content plus the measured horizontal padding.

## Geometry

Measured from the `Tag` geometry: 91 variants per size, zero variance. The heights live in
`ArcoTag`, a scale of their own, four pixels below the control of the same name.

| Value | Measured | Source |
| --- | --- | --- |
| Height, `large` / `medium` / `small` / `mini` | 32 / 28 / 24 / 20 | `ArcoTag.heightLarge … heightMini` |
| Horizontal padding | 8 | `ArcoSpace.spaceSm` |
| Radius | 2 | `ArcoRadius.radiusSm` |
| Label size, `large` / `medium` / `small` | 14, on a 22 line height | `ArcoType.size14`; the 24 px tag carries 14 px text |
| Label size, `mini` | 12 | `ArcoType.size12`; **not measured**: a fallback inside the declared scale |
| Gaps around the icon and the close action | 4 each | `ArcoSpace.spaceXs` |
| Close glyph | half the tag height: 12 in a 24 tag | `Icons.close` at `height * 0.5`, measured on the design's close variant |
| Close target | the glyph box, 12 in a 24 tag | the widget tree: the `InkWell` wraps the glyph and has no minimum size; no test asserts it |

**DS-COMP-017-01** - Every height, radius and gap MUST come from a scale and not from Material
(`DS-CONST-10`). The `mini` text size is the one value that is not measured; it MUST stay
`ArcoType.size12` and MUST be recorded as a fallback (`DS-CONST-04`).

The close glyph is defined as a ratio of the height rather than as a size step, because it is the
tallest thing in the `mini` and `small` steps. Its hit area is not expanded: the `InkWell`'s only
child is the glyph, so the target is the glyph box. The class dartdoc states that the target is
the full tag height; the widget tree does not implement that, and no test measures either.

## Colour resolution

Each family supplies three roles: `subtle` (palette step 1), `strong` (step 2) and `ink`
(step 6). `neutral` is the exception on the role side: it reads `fill.2`, `fill.3` and
`text.1`, because it is the neutral family and not a ramp.

| State | Role | Notes |
| --- | --- | --- |
| `filled` only | background `subtle`, ink `ink` | The default. |
| `filled` and `bordered` | background `subtle`, border `borderDefault`, ink `ink` | The border is not part of the family. |
| `bordered` only | background `strong`, border `borderDefault`, ink `ink` | Reached with `filled: false, bordered: true`. |
| neither | no background, no border, ink `ink` | The only form with no surface. |
| icon | `ink` of the family | Decoration; it never gets a second colour. |
| close glyph | `ink` of the family, focus highlight `fillStrong` | The `InkWell`'s focus colour, which is the only focus indication in a tag. |

**DS-COMP-017-02** - Background, border and ink MUST come from one `LumiereTagColor`, read through
`LumiereColors.tag(name)`, and MUST NOT be chosen separately (`DS-CONST-03`, `DS-CONST-11`).
The pairing "filled uses the soft background, bordered the strong one" is an inference from how
the design's variants split between the two forms, not a statement in the design file
(`OPEN-18`).

### Label contrast, light theme

Normal text requires 4.5:1 ([`contract.md`](../03-accessibility/contract.md), `DS-A11Y-002`).
The ink of every family is step 6; the backgrounds are steps 1 and 2.

| Family | on `subtle` | on `strong` |
| --- | --- | --- |
| `neutral` | 14.53 | 12.94 |
| `romanticRed` | 3.25 | 2.60 |
| `wildGreen` | 2.63 | 2.11 |
| `blueTide` | 2.04 | 1.73 |
| `vitalityOrange` | 2.41 | 2.08 |
| `lateAutumnRed` | 2.60 | 2.20 |
| `dusk` | 1.70 | 1.57 |
| `youthPurple` | 3.57 | 2.59 |
| `magenta` | 3.11 | 2.40 |
| `ultimateBlue` | 4.62 | 3.63 |
| `seaBlue` | 2.92 | 2.46 |

Only `neutral` is compliant in both forms; `ultimateBlue` passes on the soft background and
fails on the strong one, so nine families fail on the soft background and ten on the strong
one. In the dark theme `wildGreen` 4.32 and `youthPurple` 4.40 fail on the soft background, and
seven fail on the strong one: `romanticRed` 3.94, `wildGreen` 3.06, `blueTide` 3.93,
`vitalityOrange` 4.31, `youthPurple` 3.27, `magenta` 3.54, `ultimateBlue` 3.91.

The package MUST NOT repair these values. The tag colours belong to the design file, and the
contrast contract does not carry the tag families at all, so nothing fails when the palette
moves (`OPEN-06`).

## Accessibility

| Aspect | Today |
| --- | --- |
| Role | None of its own: the tag is a `Container` with a `Text` and, when closable, a `button` node for the close action. |
| Accessible name | The visible label, through the `Text`. The icon is wrapped in `ExcludeSemantics`. |
| States exposed | Only the close action's pressed state. A tag has no selected, checked or disabled state to expose. |
| Keyboard | The close action is reachable and activated by Material's `InkWell`; the tag itself is not focusable. |
| Focus indicator | None drawn. The close action shows the `InkWell` focus highlight in `fillStrong`. |
| Indicator geometry | The highlight follows the glyph's circular border; the tag's box never changes. |

**DS-A11Y-017-01** - The visible label MUST be the tag's accessible name, and the component MUST
NOT require the caller to wrap it in a `Semantics` widget (`DS-CONST-06`).

**DS-A11Y-017-02** - The leading icon MUST NOT enter the semantics tree and MUST NOT be the only
carrier of the difference between two tags.

**DS-A11Y-017-03** - A closable tag MUST expose one named `button` node whose name is
`closeSemanticLabel`. The name MUST NOT be derived from the label, because "remove" in the
wrong language is worse than no action.

**DS-A11Y-017-04** - The close action's target MUST be treated as the glyph box, which is half
the tag height. A caller that needs a larger target MUST add one; the tag does not.

## States that do not exist

* `disabled`: there is no disabled tag. A disabled filter is a different control.
* `hover`, `pressed`, `focused` as parameters: the tag exposes no such surface, and the only
  pointer state in it belongs to the close `InkWell`.
* Selected, checked or pressed: a tag carries no value of its own; selection belongs to the
  component that owns the tags.
* Error, warning or invalid: a tag is not a form control.
* Truncation, maximum width or wrapping: the label lays out at its natural width.
* A dismiss animation: `onClose` calls back and the caller removes the tag.
* A `closable` flag: the presence of `onClose` is the flag.

## Verification

| Layer | File | What it asserts |
| --- | --- | --- |
| Behaviour | [`lumiere_tag_test.dart`](../../test/lumiere_tag_test.dart) | The label renders, the close action calls back, and every one of the eleven families renders. |
| Semantics | the same file | The label is the name, the icon contributes nothing, and the close action is `button` with its own name. |
| Geometry | the same file | The four measured heights; nothing asserts the padding, the radius or the glyph size. |
| Colour resolution | the same file | The soft background, the strong background, the border, the borderless form, and the family ink instead of a global role. |
| API guards | the same file | A closable tag without a name throws through `assert`. |
| Golden | [`lumiere_tag_golden_test.dart`](../../test/golden/lumiere_tag_golden_test.dart) | One dark matrix: the eleven families filled, the four sizes in both forms, then the icon, no-background, close and combined axes. |
| Contrast | — | Absent. The tag families are not rows of [`contrast_test.dart`](../../test/accessibility/contrast_test.dart) (`OPEN-06`). |

The combination `filled: true, bordered: true` is covered by no test (`OPEN-12`), and the light
theme is exercised by one behaviour test that asserts nothing about colour.

## Status

Measured: the four heights, the 8 px padding, the 2 px radius, the 14 px label and the half-height
close glyph. Unmeasured: the `mini` label size, and the `filled`/`bordered` pairing, which is an
inference from the design's variant counts (`OPEN-18`).

The contrast table is the most serious item in this file and it is a property of the design file,
not of the code (`OPEN-06`). The close-action guard is `assert`-only (`OPEN-05`), and its hit
area is glyph-sized while the dartdoc claims the tag height (`OPEN-24`).

## Open items

* `OPEN-05` - `LumiereTag` guards `closeSemanticLabel` with an `assert` only, then dereferences it with `!`, which throws in release builds.
* `OPEN-06` - Tag label contrast: nine of eleven light families fail 4.5:1 on the soft background and ten on the strong one; the tag families are absent from the contrast contract.
* `OPEN-12` - The `filled` + `bordered` combination is covered by no test.
* `OPEN-18` - The `filled`/`bordered` pairing is an inference from the measurement, not a statement in the design file.
* `OPEN-24` - The close action's tap target is the 12 x 12 glyph in a 24 px tag, not the full tag height the dartdoc claims.
