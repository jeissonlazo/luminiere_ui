# ADR-0007 - The family is theme-scoped, and Mark Pro is the default

- Status: Accepted
- Date: 2026-10-20
- Specs affected: `DS-TYPE-001`, `INT-004`, `INT-013`, `OPEN-26`, `OPEN-27`

## Context

Until 0.6.0 the family was a single compile-time constant, `ArcoType.fontFamily`,
read from two places: `LumiereTokens.text()`, which every component uses, and the
theme's private style helper, which builds the seven styles the `TextTheme` maps.
The value was `Nunito Sans`, and the package shipped no font file - so the constant
was a *request* the application had to satisfy by registering that family, and the
only way to satisfy it with another typeface was to register a different font under
that name, which the gallery did with Roboto for its goldens.

That worked exactly as long as one typeface served every consumer. The design has now
adopted `Mark Pro`, a licensed family with ten cuts, and the package is meant to serve
more than one product. A constant cannot express either statement: it fixes the
default, forbids the override, and makes every product share one brand face.

## Decision

The family moves from the token constant into the theme extension.

- `LumiereTokens` carries `fontFamily`, defaulting to `ArcoType.fontFamily`.
- `LumiereThemeData.dark()` and `.light()` take an optional `fontFamily`, passed
  through to both the extension and the styles built for Material.
- `ArcoType.fontFamily` stays, as the **default** the design file declares, and its
  value becomes `Mark Pro`.

`Mark Pro` is therefore the package's default font, and any application can replace it
with one argument. The package continues to ship no font file.

## Consequences

### Positive

- A second product gets its own typeface without forking, patching the token file or
  lying about a family name in its manifest.
- The default is still stated in one place, and it is the design file's.
- The family now reaches the styles built for stock Material widgets as well, so a
  `Scaffold` title and a Lumiere component agree - which the constant already did, but
  only because both read the same constant.
- The field is assertable end to end: `lumiere_theme_test.dart` reads the family back
  off a rendered button, not off the tokens.

### Negative

- **The generated file is edited by hand.** The family lives in `tokens.g.dart`, which
  says `DO NOT EDIT`, and the generator is not in this repository (`OPEN-07`). The
  change is annotated where it lands and recorded at the end of the class, following
  the precedent of the `text3` override (`AE-08`), and it will be lost the next time
  the file is regenerated unless the design source carries it.
- **The weight axis did not come with it.** The family has ten cuts and no 600, and
  Flutter accepts nine slots, so every `w600` heading now renders Bold; 400 is bound to
  `Book` rather than the face named `Regular`. Both are decisions recorded as
  `OPEN-26`, not measurements, and they change how the scale looks without changing a
  number in it.
- **The line heights were not re-measured** (`OPEN-27`). The scale's ratios range from
  1.14 to 1.80 depending on size and were taken against the previous family's metrics.
  Mark Pro asks for 1.268 em, which sits inside that range but does not confirm it.
- A `String` field is not interpolable, so `lerp` switches it at the midpoint, as it
  already did for the brightness. A theme animation therefore flips typeface halfway
  through instead of morphing, which is the only sane behaviour and is worth knowing.

## Alternatives considered

- **Keep the constant and ask consumers to alias the family name.** Zero API change,
  and it is what the gallery did for its goldens. It makes every consumer's manifest
  claim a family it is not using, and it cannot express the new default without also
  lying about it.
- **Generate the family from the design source and leave the theme alone.** Correct in
  principle, impossible today: the generator is not in this repository, so the change
  would be a suggestion rather than a diff.
- **Add a full typographic override** - family, sizes, weights and line heights as
  theme fields. Coherent, and the wrong scope: sizes and line heights are the design's,
  and letting each application restate them turns the design system into a styling
  library. The family is the one axis a consumer legitimately owns.
- **Ship the font with the package.** Removes the wiring step and redistributes a
  commercial typeface with a library, which is a licence violation and a liability for
  every consumer. `DS-TYPE-005` forbids it.

## References

- [`specs/01-foundations/typography.md`](../01-foundations/typography.md) -
  `DS-TYPE-001`, `DS-TYPE-005`
- [`specs/04-integration/consuming.md`](../04-integration/consuming.md) - `INT-004`
- [`specs/07-traceability/open-items.md`](../07-traceability/open-items.md) -
  `OPEN-26`, `OPEN-27`
- [`test/lumiere_theme_test.dart`](../../test/lumiere_theme_test.dart)
- `showcase/pubspec.yaml` - the weight binding table
