# 01 - Typography

One family, ten sizes, a line height paired with each. The scale is mode-independent,
so it is a set of plain constants rather than a theme extension field
([`ArcoType`](../../lib/src/tokens/tokens.g.dart#L453-L541)).

## Family

`Nunito Sans`, exposed as `ArcoType.fontFamily` and read from there everywhere. The
design file declares `PingFang SC` as its CJK companion; this package does not ship
either face. The package declares no `fonts:` section, so the application supplies the
family and the licence (SIL Open Font License) with it.

## Scale

| Size | Line height | Ratio `lineHeight / size` | Weights the design uses |
| --- | --- | --- | --- |
| 10 | 18 | 1.80 | 400, 600 |
| 12 | 20 | 1.67 | 400, 500, 600 |
| 13 | 22 | 1.69 | 400, 500, 600 |
| 14 | 22 | 1.57 | 400, 500, 600, 700 |
| 16 | 24 | 1.50 | 400, 500, 600 |
| 20 | 28 | 1.40 | 400, 500, 600 |
| 24 | 32 | 1.33 | 400, 500, 600 |
| 36 | 44 | 1.22 | 400, 500, 600 |
| 48 | 56 | 1.17 | 400, 500, 600 |
| 56 | 64 | 1.14 | 400, 500, 600 |

The weight column is the content of `ArcoType.weights`, keyed `sizeN.wWWW`: w700 exists
at 14 and nowhere else, and 10 has no w500. `ArcoType.lineHeightFor` returns null for
a size that is not on the scale
([`tokens.g.dart:481`](../../lib/src/tokens/tokens.g.dart#L481-L506)).

## The one constructor

`LumiereTokens.text({size, weight})` builds every text style in the package: family
from the scale, `height = lineHeight / size`, colour `textPrimary`, weight defaulting
to w400 ([`lumiere_tokens.dart:596`](../../lib/src/tokens/lumiere_tokens.dart#L596-L605)).
An off-scale size inherits Flutter's default line height, which is the intended
behaviour and not a fallback to be widened.

## Usage

| Where | Size | Weight | Ink |
| --- | --- | --- | --- |
| Button label | 16 at `large`, 14 otherwise | 400 | the solid pair at `primary`, the ramp otherwise |
| Checkbox label | 14 | 400 | `textPrimary`, `textDisabled` when disabled |
| Radio label | 14 | 400 | `textPrimary`, `textDisabled` when disabled |
| Switch label | 14, 12 at `small` | 400 | `textPrimary`, `textDisabled` when disabled |
| Tag label | 14, 12 at `mini` | 400 | the family's `ink` |
| Divider label | 14 | 400 | `textTertiary` |

The tag's `mini` text size is the one size the design does not measure: 12 is the
fallback inside the declared scale, and the component records it as such
([`lumiere_tag.dart:83`](../../lib/src/components/tag/lumiere_tag.dart#L83-L89)).

## Theme mapping

`LumiereThemeData` maps seven Material text styles onto the scale
([`lumiere_theme.dart:54`](../../lib/src/theme/lumiere_theme.dart#L54-L62)):

| Material style | Size | Weight |
| --- | --- | --- |
| `headlineSmall` | 24 | 600 |
| `titleLarge` | 20 | 600 |
| `titleMedium` | 16 | 600 |
| `bodyLarge` | 16 | 400 |
| `bodyMedium` | 14 | 400 |
| `bodySmall` | 13 | 400 |
| `labelMedium` | 12 | 500 |

## Rules

**DS-TYPE-001 - One family, and it is theme-scoped.** A text style `MUST` take its
family from `LumiereTokens.fontFamily`, which defaults to `ArcoType.fontFamily`. A
component `MUST NOT` pass a family name as a string, `MUST NOT` read `ArcoType`
directly for it, and the package `MUST NOT` add a second family without an ADR.

The default is the family the design file declares - `Mark Pro` since 0.7.0. A
consumer replaces it by passing `fontFamily` to `LumiereThemeData.dark()` or `.light()`
and registering that family in its own `pubspec.yaml`; the package ships no font file,
so the name is a request the application fulfils (`INT-004`).

**DS-TYPE-002 - Only the ten sizes.** A text size `MUST` be one of the ten scale
values. An off-scale size `MUST NOT` be introduced: when the design has no size for a
case, the nearest scale size `MUST` be used and named
(`ArcoType.size10` for the radio icon, `ArcoType.size12` for the mini tag).

**DS-TYPE-003 - The line height is the paired one.** A style `MUST` express its line
height as `height = lineHeight / size` from the pair the design declares. A component
`MUST NOT` set `height`, and `MUST NOT` invent a leading for a size on the scale.

**DS-TYPE-004 - Only a weight the design uses.** A style's weight `MUST` be one
`ArcoType.weights` lists for that size. w700 exists at 14 only; using it at another
size `MUST` be treated as a new design value and measured first.

**DS-TYPE-005 - The package ships no font file.** A font asset `MUST NOT` be added to
the package's `pubspec.yaml`. The application supplies `Mark Pro` - or its own family -
and a missing family is an application defect that `MUST NOT` be masked by bundling a
fallback. The gallery is allowed its own copy because it is not the package: it is
excluded from the published archive and it is not what a consumer depends on.

**DS-TYPE-006 - The style comes from the token layer.** A component `MUST` build its
text style with `LumiereTokens.text` and change only the ink, through `copyWith`. It
`MUST NOT` construct a `TextStyle` from `ArcoType` constants by hand, because the line
height pairing would then be duplicated at every call site.

**DS-TYPE-007 - A colour is still a role.** The ink of a text style `MUST` be a
semantic role (see [`colour.md`](colour.md)). `LumiereTokens.text` returns
`textPrimary`; a component replacing it `MUST` pass a role, never a literal.

**DS-TYPE-008 - The Material mapping stays on the scale.** A style added to the
theme's `TextTheme` `MUST` name a scale size and a weight from `ArcoType.weights`. A
mapping `MUST NOT` be removed without recording which Material widget it served.

## Status

Measured: all ten size and line height pairs, the weight set per size, the six
component usages, the seven `TextTheme` mappings, and the family name. The line height
pairing is asserted for 14 and 16, and the off-scale null for 17, in
[`lumiere_button_test.dart:193`](../../test/lumiere_button_test.dart#L193-L202). The
family's two paths - the default and an override - are asserted end to end, down to the
glyph a button paints, in
[`lumiere_theme_test.dart`](../../test/lumiere_theme_test.dart).

Not measured: that the rendered face is `Mark Pro`. The family name is asserted; the
glyphs are not, because the package ships no font file. The `TextTheme` mapping and
DS-TYPE-008 are unenforced by any test today.

Two properties of this scale are assumptions rather than measurements since 0.7.0, and
both are registered: the family has no 600, so every `w600` in the weight map and in
the `TextTheme` renders as Bold (`OPEN-26`), and the line heights were measured against
the previous family and were not re-measured for this one (`OPEN-27`).

The specification matches the code, with one difference in shape: `LumiereTokens.text`
leaves the line height null off-scale, while the theme's private style helper
substitutes `size * 1.4` for the same case
([`lumiere_theme.dart:38`](../../lib/src/theme/lumiere_theme.dart#L38-L45)). Every size
the theme uses is on the scale, so the substitution is unreachable today; it is a
second rule for the same question and should not spread.

## Open items

- **OPEN-26** - The family's ten cuts do not fit Flutter's nine weight slots: there is no 600, so every heading renders Bold, and 400 is bound to Book rather than to the face named Regular.
- **OPEN-27** - The line heights are paired to the previous family's metrics and were not re-measured; the family asks for 1.268 em of leading of its own.
