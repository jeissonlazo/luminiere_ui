# Changelog

All notable changes to this package are documented here.
Format based on Keep a Changelog; versioning follows Semantic Versioning.

## 0.7.0

### Changed (breaking)

- The declared family is `Mark Pro`, not `Nunito Sans`. `ArcoType.fontFamily` names
  it, so every component and every style the theme builds for Material changed
  typeface at once. The change was applied by hand to the generated token file,
  because the generator is not in this repository (`OPEN-07`); regenerating without
  carrying it reverts it, and the constant says so where it lands.
- The family is now theme-scoped instead of a compile-time constant.
  `LumiereTokens` carries a `fontFamily` field and `LumiereThemeData.dark()` and
  `.light()` take an optional `fontFamily` whose default is `ArcoType.fontFamily`.
  An application that registers another family no longer has to fork the package:
  it passes the name and every component follows. Existing calls are unchanged.
- The scale's `w600` no longer resolves to a semibold face. Mark Pro has ten cuts -
  250 to 900 - and no 600, so `FontWeight.w600`, which is every heading in
  `ArcoType.weights` and in the `TextTheme` mapping, is drawn with Bold (700). The
  weight map keeps the design's requests and says what happens to them.

### Added

- `LumiereTokens.fontFamily`, with `copyWith`, `lerp`, `==` and `hashCode`, and
  `test/lumiere_theme_test.dart`: the default, the override, the path from the theme
  to the glyph a button paints, and each of the four members above.
- The gallery declares and bundles the family, with the weight binding written down
  in `showcase/pubspec.yaml`; its baselines are regenerated with the real typeface
  instead of a substitute.

### Notes

- The typeface is licensed and is redistributed with neither this package nor its
  archive: the gallery keeps its own copy outside the published files, and every
  consumer supplies its own. See `specs/04-integration/consuming.md`.
- The line heights were not re-measured. The scale pairs each size with an absolute
  value measured against the previous family; Mark Pro asks for 1.268 em of leading
  of its own, which is tighter than 56/64 and looser than 10/18. Recorded as
  `OPEN-27` rather than presented as a verified pairing.
- 400 is bound to `Book` (the family's reading weight, 450 in its own table) and not
  to the face named `Regular`, which is lighter. The binding is one line in the
  gallery's `pubspec.yaml` and is recorded as `OPEN-26`.

## 0.6.0

### Added

- `LumiereDivider`: the orientation, dashed, label and alignment axes of the
  `Divider` component. The alignment keeps a line on both sides of the label, with
  the short one of 20 px on the side the label sits, which is what the file
  measures. It carries no margin on purpose: the space around a separator belongs
  to the layout that places it, not to the separator.
- `LumiereLoading`: the `Loading` component, a single 40 by 40 vector with no axis
  of its own. The size is a parameter because the button draws it smaller.
- `LumiereStrokes`: the hairline, the dash and the gap the components read instead
  of writing a literal. The hairline is measured; the dash metrics are the values
  the button already used and are recorded as pending.

### Changed (breaking)

- The button no longer borrows Material's `CircularProgressIndicator`: its loading
  state draws `LumiereLoading`, so its look no longer follows Material's.
- The small switch handle is 12 px and not 10, measured in the project file. Its
  travel and its inset follow from that: the inset is half of what the height
  leaves.
- The tag draws its close glyph at half its height, measured at 12 in a 24 tag, and
  its small step uses the 14 px text the file declares rather than 12.
- `lib/lumiere_ui.dart` publishes the token layer with an explicit show list, so
  what the design system exposes is stated rather than implied.

### Notes

- Every value above comes from a measurement in the project file, taken with the
  API quota of this round. The alignment semantics of the divider, which were an
  interpretation in the previous version, are confirmed: only `none` carries no
  lines. What is still unmeasured is recorded in the pending list.

## 0.5.0

### Changed (breaking)

- `LumiereStatusColors` gains `onSubtle`, the ink of a family for text that sits
  on its own subtle background. It is deliberately separate from `normal`, which
  is the decorative fill: those fills measure 2.41 to 3.25 in the light theme,
  below the 4.5:1 the accessibility contract requires of normal text.
- The light `text.3` token is darkened from the exported `#86909C` to `#6A7583`,
  the smallest change of the declared pair that reaches the threshold: 4.68:1 on
  the light surfaces, with `text.2` still at 7.10 and `text.1` at 16.13, so the
  hierarchy survives.

### Added

- The token generator applies declared overrides from
  `design/variables/overrides.json` and marks the generated constant with the
  rule that requires it, so a difference from the design file is visible in the
  output instead of living in a comment somebody has to remember.
- `test/accessibility/status_ink_test.dart`: asserts that every family declares an
  ink, that the ink reaches 4.5:1 on its subtle background, that the values are the
  measured ones, and that darkening `text.3` preserved the hierarchy of the scale.

### Notes

- `AE-08` and `AE-11` of the accessibility contract are implemented. The contract
  has no open entry left: what remains is decided, accepted, or permanent by
  design.

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
