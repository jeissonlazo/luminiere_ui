# Changelog

All notable changes to this package are documented here.
Format based on Keep a Changelog; versioning follows Semantic Versioning.

## 0.4.0

### Added

- `LumiereCheckbox`: the `checked`, `indeterminate`, `disabled` and `hover`
  axes of the `checkbox` component set, plus the optional visible label the
  design expresses as `showLabel` and `replaceText`. The 14 x 14 box, the 4 x 7
  tick and the 6 x 2 dash are the measured geometry, inside a 24 x 24
  interactive box.
- `LumiereRadio` and `LumiereRadioGroup`: the `checked`, `disabled`, `icon` and
  `hover` axes of the `components/radio` component set, with the measured 14 x
  14 circle and 4 x 4 dot. The group is a single tab stop and moves the
  selection with the arrow keys; it is built on the `RadioGroup` widget of the
  SDK rather than on the `groupValue` and `onChanged` properties of `Radio`,
  which this SDK marks as deprecated.
- `LumiereSwitch`: the `type` (`circle`, `rectangle`, `line`), `size`
  (`default`, `small`), `on`, `disabled`, `handleIcon` and `trackContent` axes
  of the `switch` component set, with the measured 40 x 24 and 28 x 16 tracks
  with their 16 x 16 and 10 x 10 handles, and the 36 x 6 and 28 x 4 line tracks
  with their 20 x 20 handle.
- `LumiereTag`: the `size`, `color`, `filled`, `bordered`, `closable` and icon
  axes of the `Tag` component set. Its four heights (32, 28, 24 and 20) and the
  three colours of each of its eleven colour names are measured, with zero
  variance over 91 and 32 variants. The colour names are the design's own and
  stay untranslated, because they are an axis.
- `ArcoTag`: the measured tag heights, generated from the declared scales.
- `LumiereTagColorName` and `LumiereTagColor`: the eleven tag colours as
  semantic roles, each with its soft background, its strong background and its
  ink, reached through `LumiereColors.tag(name)`.
- Level-1 accessibility tests: 55 documented colour combinations computed from
  the tokens, with the exception register of the accessibility contract encoded
  so a palette change cannot degrade a combination silently.
- Behaviour tests covering every axis, both themes where colour is resolved,
  the semantics tree, disabled behaviour and keyboard operation, plus one
  golden per component laying out every variant in a labelled matrix.

### Notes

- The tag palette maps each design colour name to a palette family by comparing
  the measured hexadecimal values, not by reading the names: that is how
  `youthPurple` turned out to be the `pinkPurple` family and `ultimateBlue` the
  `primary` one.
- One tag axis pairing is an inference from the measurement and is worth
  confirming: the design gives each colour two backgrounds and the counts split
  evenly, read here as "filled uses the soft one, bordered the strong one".
- The tag label is normal-size text and the light theme does not reach 4.5:1 on
  every family at the declared ink. The component uses the declared colours and
  the combination is registered as exception `AE-11` in the accessibility
  contract, asserted by the level-1 test, rather than hidden.
- The three controls carry their own accessibility: an accessible name, the
  checked, mixed, toggled and disabled states in the semantics tree, keyboard
  activation, and a visible focus ring in both themes. The ring is 2 px and is
  drawn inside the measured interactive box, which the geometry export leaves
  free of any focus outline. Nothing is delegated to the caller.
- Selection is never carried by colour alone: the checkbox shows a tick or a
  dash, the radio a dot or its `icon` variant, and the switch the position of
  its handle.
- The design declares no `pressed` option for these three components, so a
  press keeps the resting colours. In the dark theme the accent `active` step
  measures 2.63:1 against `textOnAccent`, below the 3:1 the accessibility
  contract requires of a graphic indicator, while `normal` and `hover` measure
  3.74:1 and 4.34:1.
- The off track of `LumiereSwitch` uses `borderHeavy`, the role the contract
  reserves for the boundary of a control that needs a visible edge: 3.11:1
  against the page in the dark theme and 3.24:1 in the light theme. Its hover
  step, `borderStrong`, drops the handle to 1.60:1 in the light theme. That
  combination is an open item for the design, recorded in the component, not a
  hidden failure; hover is transient and the position of the handle carries the
  value.
- The `text` track content of `LumiereSwitch` draws the label beside the
  measured track instead of inside the 51 x 24 box the design widens: text on
  the accent fill measures 3.74:1 in the dark theme, below the 4.5:1 normal
  text requires, and the token layer exposes no darker solid step.

## 0.3.0

### Changed (breaking)

- Spacing scale approved as 4 / 8 / 12 / 16 / 20, every step divisible by two. It
  supersedes the 4 / 8 / 16 / 24 that the `Space` component declared: it adds 12
  and 20 because those are the measured control paddings, and drops 24 in favour
  of 20. The names keep their positions, so `ArcoSpace.spaceMd` is now 12 and
  `ArcoSpace.spaceLg` is now 16.
- `LumiereButton` no longer derives its horizontal padding from the spacing scale.
  It uses the measured control padding: large 20, medium 16, small 16 and mini 12,
  instead of 16 for large and medium and 8 for small and mini.

### Added

- `ArcoControl.paddingMini`, `paddingSmall`, `paddingMedium` and
  `paddingLarge`, measured from the control geometry: 30 variants per size with
  zero variance.
- Rule `DS-CONTROL-001`, which fixes control height and horizontal padding
  together, and rule `DS-SPACE-001` now carries the approved scale.

### Notes

- The control heights (24 / 28 / 32 / 36) are no longer marked as pending
  verification: they are measured. The measurement comes from the Arco kit
  geometry rather than from the project's Figma file, whose account is rate
  limited. The provenance is recorded in
  `design/reference/control-geometry.json` and in the rule rationale.
- The golden was regenerated because the button padding changed.

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
