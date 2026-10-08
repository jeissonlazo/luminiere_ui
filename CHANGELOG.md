# Changelog

All notable changes to this package are documented here.
Format based on Keep a Changelog; versioning follows Semantic Versioning.

## 0.2.0

### Changed (breaking)

- Token layer rebuilt from the real design file instead of the provisional
  placeholder values. The generated layer now carries 396 colour constants
  (palette, semantic ramps and component tokens) for both modes.
- Type scale replaced by the one the design declares: `Nunito Sans` at 10, 12,
  13, 14, 16, 20, 24, 36, 48 and 56 px with their paired line heights.
- Spacing scale is now the one the `Space` component declares: 4 / 8 / 16 / 24.
- Radius scale measured from the file: 2 / 4 / 8 plus full rounding.
- `LumiereTheme` was renamed to `LumiereTokens` and now carries the semantic
  colour roles and the brightness.
- `LumiereButton` now mirrors the five axes the design declares (`type`, `kind`,
  `shape`, `size` and real widget states) instead of a single variant enum.
- All identifiers and documentation are in English.

### Added

- `LumiereColors` and `LumiereStatusColors`: semantic roles mapped from the
  descriptions the design file gives to each token.
- `ArcoType`, `ArcoSpace`, `ArcoRadius`, `ArcoControl` as the public,
  mode-independent scales.
- Dashed border support for the `dashed` button type, which Flutter's
  `BorderSide` cannot express.
- `LumiereThemeData.light()`.

### Removed

- The provisional token values and the `LumiereDensity` type. Density is decided
  by the tokens; Material's `visualDensity` is left at its default so it cannot
  silently resize token-driven controls.

## 0.1.0

### Added

- First version of the package: single public entry point, `LumiereTokens` as a
  `ThemeExtension`, `LumiereThemeData.dark()` and a reference `Button`
  component with sizes, variants, leading icon, loading state, visible focus and
  an accessible name.
- Behaviour tests and a golden covering variants, states and sizes.

### Notes

- Token values in this version were **provisional**: Figma was not accessible
  yet, so they did not come from the design file.
