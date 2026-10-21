# 01 - Tokens

One value, one owner. Every visual value in the package sits in exactly one of three
layers, and a layer is read only from above it: a component reads a role or a scale,
never a primitive, and a primitive is read only by the hand-written mapping.

| Layer | Defined in | Generated | Read by |
| --- | --- | --- | --- |
| 1 - Primitives | [`tokens.g.dart`](../../lib/src/tokens/tokens.g.dart) | yes | layer 2, and white-box by the accessibility tests |
| 2 - Semantic roles | [`lumiere_tokens.dart`](../../lib/src/tokens/lumiere_tokens.dart) | no | components and applications |
| 3 - Scales | `tokens.g.dart` and `lumiere_tokens.dart` | partly | components and applications |

## Layer 1 - primitives

Generated from the Figma variables export of "Arco Design System lumimier", file
`E6OUz1aF3tykVnr341r6fl`, by the command its header records:
`node design/tools/build-tokens.mjs` ([header](../../lib/src/tokens/tokens.g.dart#L1-L10)).
Nothing in this layer is authored in this repository.

| Class | Constants per mode | Content |
| --- | --- | --- |
| `ArcoPaletteDark` / `ArcoPaletteLight` | 142 | 14 hue families at steps 1 to 10, plus black and white |
| `ArcoSemanticDark` / `ArcoSemanticLight` | 47 | `bg`, `text`, `border`, `fill` and four status ramps at steps 1 to 7 |
| `ArcoComponentDark` / `ArcoComponentLight` | 9 | per-component colours, the disabled button fills among them |

396 colour constants in total. The component class has no consumer: no semantic role
maps it, so nothing reads it.

Declared overrides are applied by the generator and annotated where they land. The
light `text3` carries its note on the same line as the value
([`tokens.g.dart:405`](../../lib/src/tokens/tokens.g.dart#L405)) and the class closes
with `// Overrides applied in this class: text3 (AE-08).`
([`tokens.g.dart:417`](../../lib/src/tokens/tokens.g.dart#L417)).

## Layer 2 - semantic roles

Hand-written, one mapping per mode, following the descriptions the design file
attaches to each token rather than an interpretation of its name. `LumiereColors`
carries the roles, `LumiereStatusColors` the nine fields of one family,
`LumiereTagColor` the three colours of one tag family. See
[`colour.md`](colour.md) for the roles themselves.

## Layer 3 - scales

Mode-independent, therefore plain constants rather than extension fields:
`ArcoType`, `ArcoSpace`, `ArcoRadius`, `ArcoControl` and `ArcoTag` from the generated
file, and [`LumiereStrokes`](../../lib/src/tokens/lumiere_tokens.dart#L124-L131) from
the hand-written one, because no scale governs a hairline. The barrel exports these
five classes and `LumiereStrokes`, and no colour class
([`lumiere_ui.dart:33`](../../lib/lumiere_ui.dart#L33-L34)).

## Rules

**DS-TOK-001 - Three layers, one owner.** A visual value `MUST` be defined in exactly
one layer. A component `MUST` read layer 2 or layer 3. A value `MUST NOT` be copied
between layers to avoid writing a mapping.

**DS-TOK-002 - The generated file is never hand-edited.** `tokens.g.dart` `MUST NOT`
be changed by hand. Its header states it, and a change made there is a defect in the
pull request, not a fix.

**DS-TOK-003 - A new value arrives through the generator.** A new colour `MUST` enter
the package as a change to the design file, exported and regenerated. It `MUST NOT`
be introduced by adding a constant to `tokens.g.dart`. While the generator is absent
from this repository (OPEN-07) a change to the generated file `MUST` be declared as
unregenerated in the pull request, together with the design change that requires it.

**DS-TOK-004 - An override is annotated where it lands.** A declared override `MUST`
appear twice: on the constant it replaces, with its register identifier, and in the
class-level summary line the generator emits. An override with one annotation and not
the other `MUST` be read as an undocumented edit.

**DS-TOK-005 - No component reads a primitive.** A component `MUST NOT` reference
`ArcoPalette*`, `ArcoSemantic*` or `ArcoComponent*`. Adding one of those classes to
the `show` list of the barrel `MUST NOT` happen without an ADR: it converts a
generated internal into a published contract.

**DS-TOK-006 - The extension is mandatory.** The theme `MUST` publish `LumiereTokens`
as a `ThemeExtension`, and `LumiereTokens.of` `MUST` be the only way a component
reaches colour ([`lumiere_tokens.dart:580`](../../lib/src/tokens/lumiere_tokens.dart#L580-L590)).
The debug `assert` on its absence `MUST` stay. The release fallback to
`LumiereColors.dark` is a documented wiring mistake and `MUST NOT` be treated as a
supported state or relied on by a test.

**DS-TOK-007 - Mode decides the home of a value.** A value that changes with
`Brightness` `MUST` live in `LumiereColors`, `LumiereStatusColors` or
`LumiereTagColor`. A value that does not `MUST` be a `static const` on an `Arco*`
class or on `LumiereStrokes`, and `MUST NOT` travel through the extension.

**DS-TOK-008 - Material does not resize a control.** `ThemeData.visualDensity` `MUST`
stay at Material's default, and control geometry `MUST` come from the scales
([`lumiere_theme.dart:12`](../../lib/src/theme/lumiere_theme.dart#L12-L14)). A theme-level
density `MUST NOT` be introduced to fix a size: it shrinks every token-driven control
in the package at once.

**DS-TOK-009 - A field is threaded through every member.** A colour field `MUST` be
added to its class's constructor, `_lerp`, `==`, `hashCode`, and to both the `dark`
and the `light` constant in the same change; a field on `LumiereTokens` `MUST` also
reach `copyWith`. A field missing from any of them is invisible to theme animation
and compares equal to a different palette.

## Status

Measured: every colour in layer 1 comes from the export, and 396 constants are
accounted for by the three class pairs. The layer boundary is enforced by the barrel
and not only by review: the colour classes are not exported. The extension's presence
is asserted by [`lumiere_button_test.dart:166`](../../test/lumiere_button_test.dart#L166-L170)
and the role-to-primitive mapping by
[`lumiere_button_test.dart:172`](../../test/lumiere_button_test.dart#L172-L182).

Not measured: whether the generated file still matches the design file. Neither
`design/` nor the generator exists in this repository, so the file can be read but
not regenerated or diffed (OPEN-07). The nine component colours per mode are
unreferenced, so nothing proves them correct. DS-TOK-004 is unenforced beyond the one
instance it happens to describe.

The specification matches the code today, with two exceptions: the generated file is
not the output of the current `dart format` and cannot be reformatted without
violating DS-TOK-002 (OPEN-15), and `fill1..4` carry opaque values in the light theme
and translucent ones in the dark theme under one name (OPEN-13).

## Open items

- OPEN-07 - The generator and `design/` are absent, so `tokens.g.dart` cannot be
  regenerated from this repository; DS-TOK-003 and DS-TOK-004 are review-only.
- OPEN-13 - `fill1..4` are opaque in the light theme and translucent in the dark one,
  so one role serves a surface fill and an overlay tint.
- OPEN-15 - The generated file is not `dart format` output and cannot be reformatted
  by hand without breaking DS-TOK-002.
