# ADR-0005 - Icon and typeface agnostic

- Status: Accepted
- Date: 2026-10-16
- Specs affected: `INT-*`, `DS-COMP-017`

## Context

The design declares `Nunito Sans` and uses Lucide for icons. A package that ships a typeface
must keep it, version it, defend its licence and load it before the first paint; a package
that ships an icon set has to follow that set's renames and deprecations. The application
already resolves both, and it is the only thing that can decide which weight a surface needs.

## Decision

The package redistributes neither icons nor a typeface. It declares `Nunito Sans` as the
family and draws no glyph of its own except the geometry it must paint. Icons arrive from the
application as widgets; the gallery passes Lucide (MIT) exactly as the product does. The one
exception is the tag's close glyph, which is `Icons.close` from Material and is therefore a
dependency on `uses-material-design`.

## Consequences

### Positive

- The archive is a library and nothing else: 122 KB, no font asset, no licence text to redistribute, nothing to load before the first frame.
- The application owns its icon set and its version, so an icon upgrade is an application change rather than a package release.
- Changing the typeface is a `ThemeData` change on the consumer side, not a new version of the package.

### Negative

- Until the application adds the typeface, every component renders in the platform default, and a design review of type is impossible without that extra step.
- The package's own goldens therefore test layout and scale but never the declared typeface: the family they register is a substitute.
- A consumer who forgets the font gets a system that looks approximately right, which is the worst kind of wrong - wrong enough to ship, close enough that nobody files it.
- The tag's Material close glyph means one component already depends on `uses-material-design`, contradicting the rule this ADR is meant to illustrate.

## Alternatives considered

- **Bundle `lucide_icons_flutter` and the four `Nunito Sans` static instances.** The components look right out of the box, and the package owns two asset sets, their licences and their version cadence.
- **Depend on `google_fonts`.** Fewer bytes in the repository, a network fetch at runtime, and a rendering dependency that fails offline - for a desktop product.
- **Draw every glyph as a path.** Total control of the close cross, and a font renderer written by hand for every icon the design will ever add.

## References

- [`01-foundations/typography.md`](../01-foundations/typography.md), [`02-components/tag.md`](../02-components/tag.md)
- [`04-integration/consuming.md`](../04-integration/consuming.md), [`pubspec.yaml`](../../pubspec.yaml)
- [`README.md`](../../README.md), section "Licence"
