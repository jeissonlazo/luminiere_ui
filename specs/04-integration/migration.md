# 04 - Migration

Every breaking change, what it replaced, and what an application must do. One
section per release, newest first. A release with no breaking change says so, and
nothing else.

This file is the other half of `INT-018`: a `Changed (breaking)` line in the
CHANGELOG announces that something moved, and this file says what to type.

---

## 0.7.0

The typeface changed, and the family stopped being a constant.

| What moved | Before | Now | Why |
| --- | --- | --- | --- |
| The declared family | `Nunito Sans` | `Mark Pro` | The design adopted it |
| The family's home | `ArcoType.fontFamily`, read directly | `LumiereTokens.fontFamily`, defaulting to that constant | So a product can own its typeface without forking (ADR-0007) |
| `LumiereThemeData.dark()` / `.light()` | No parameters | Optional `fontFamily` | The override |
| `w600` headings | A real semibold face | Bold (700) | The family has no 600 (`OPEN-26`) |
| Body text at 400 | Nunito Sans regular | Mark Pro `Book` | The family's reading weight |

**What to change.**

1. **If you own a licence for Mark Pro**, register the faces under exactly
   `Mark Pro` and nothing else changes; the previous release already rendered in the
   platform default if you supplied nothing, and it still does. The registration
   snippet and the weight binding are in
   [`consuming.md`](consuming.md#int-004---the-application-supplies-the-typeface).
2. **If you do not**, either own the rendering with a family of your own -
   `LumiereThemeData.dark(fontFamily: 'Acme Sans')`, with that family declared in your
   `pubspec.yaml` - or accept the platform default. What you MUST NOT do is keep a
   `Nunito Sans` registration and expect it to be used: the package no longer asks
   for it, so the file you registered is now dead weight in your archive.
3. **If you had compensated for Nunito Sans metrics** - a manual `height:` on a
   `Text`, an adjusted `SizedBox` under a wrapped paragraph - re-check it. The scale's
   line heights did not change, and the new family's own leading is 1.268 em, so the
   tight steps (48/56 and the display sizes) are the ones that move visibly.
4. **Every heading is heavier than it was.** Nothing in your code caused it and
   nothing in your code fixes it: the design's `w600` now resolves to Bold. If that is
   wrong for the product, the fix is in the design decision recorded as `OPEN-26`, not
   in a local override.
5. **Regenerate your own baselines** if you keep any. Nothing in this package's
   goldens is yours, but every golden of yours that renders a Lumiere component now
   renders a different typeface.

`LumiereThemeData.dark()` with no arguments still compiles and still returns a
complete theme; the breaking part is the rendering, not the signature.

---

## 0.6.0

Four breaking changes. Three of them move a measured value; the fourth removes
symbols from the barrel.

| What moved | Before | Now | Why |
| --- | --- | --- | --- |
| The button's loading glyph | Material's `CircularProgressIndicator` | `LumiereLoading`, drawn by the package | The button's look must not follow Material's (ADR-0003) |
| The small switch handle | 10 px | 12 px | Measured in the project file; the upstream kit showed 10 |
| The tag's close glyph | A 12 px icon in every size | Half the tag height: 12 in a 24 tag, 16 in a 32 tag | Measured |
| The tag's small step text | 12 px | 14 px | The design declares 14 |

**What to change.**

1. If you styled `CircularProgressIndicator` in your `ThemeData` expecting it to
   reach the button, it no longer does. The indicator takes its colour from the
   button's ramp; there is no per-button override.
2. If you compensated for the 10 px handle with padding or an overlay, remove the
   compensation. The handle grows **and** its travel and inset follow from their own
   measurement, so the track geometry is unchanged at 28x16
   (`_SwitchGeometry.metrics`).
3. If you positioned content over the tag's close action, expect it 4 px larger,
   and expect the label of a `mini` tag to be 2 px smaller relative to the old
   layout.
4. **The barrel now names what it exports.** Anything you imported from
   `package:lumiere_ui/lumiere_ui.dart` that is not in the `show` list of
   [`lib/lumiere_ui.dart`](../../lib/lumiere_ui.dart) is a compile error. The
   imports that survive are listed in
   [`consuming.md`](consuming.md#int-002---what-is-exported-and-what-is-not). If you
   were importing a primitive palette class, switch to a semantic role
   (`DS-CONST-03`); the raw classes are not coming back.

Also added, no migration: `LumiereDivider`, `LumiereLoading`, `LumiereStrokes`.

---

## 0.5.0

| What moved | Before | Now | Why |
| --- | --- | --- | --- |
| `LumiereStatusColors` fields | Eight | Nine, with `onSubtle` | A family's step-6 fill measures 2.41 to 3.25 on its own subtle background, so it cannot be the ink for text on it |
| The light `text.3` token | `#86909C` (3.89:1) | `#6A7583` (4.68:1) | Normal text requires 4.5:1 |

**What to change.**

1. `onSubtle` is a required constructor parameter. Any code constructing a
   `LumiereStatusColors` literal - including a test fixture or a custom theme - must
   pass it. The value is the palette step closest to step 6 that reaches 4.5:1 on
   that family's subtle background: `primary.6`, `green.8`, `orange.8`, `red.7`.
2. If you hard-coded `#86909C`, or copied the light tertiary text colour into your
   own styles, update it. `text.3` on `bg.1` is now darker and the hierarchy holds:
   `text.2` at 7.10, `text.1` at 16.13.

Also added, no migration: the generator's declared-override mechanism, and
`test/accessibility/status_ink_test.dart`.

---

## 0.4.0

No breaking change. `LumiereCheckbox`, `LumiereRadio`, `LumiereRadioGroup`,
`LumiereSwitch`, `LumiereTag`, `ArcoTag` and the tag colour roles were added, along
with the level-1 accessibility tests.

If you were waiting on form controls, this is the version that has them; nothing
existing needed to move.

---

## 0.3.0

| What moved | Before | Now | Why |
| --- | --- | --- | --- |
| The spacing scale | 4 / 8 / 16 / 24 | 4 / 8 / 12 / 16 / 20 | 12 and 20 are the measured control paddings, and every step is divisible by two |
| `ArcoSpace.spaceMd` | 16 | 12 | The names keep their positions on the new scale |
| `ArcoSpace.spaceLg` | 24 | 16 | Same |
| The button's horizontal padding | 16 / 16 / 8 / 8 by size | 20 / 16 / 16 / 12 by size | Measured from the control geometry, 30 variants per size, zero variance |

**What to change.**

1. This one is easy to miss because nothing fails to compile: every `spaceMd` and
   every `spaceLg` in your application now renders a different number of pixels. If
   you used them for layout around a Lumiere control, the layout converges on the
   design; if you used them elsewhere, audit it.
2. `ArcoSpace.spaceXl` did not exist before. The value that used to be 24 is now
   `spaceXl` 20 - there is no 24 in the scale, on purpose.
3. The button's padding is no longer derived from the spacing scale. Changing a
   spacing token no longer resizes a button, which is the point; the two scales are
   independent by design (`DS-CONTROL-001`).

---

## 0.2.0

The largest change in the package's history: the token layer was rebuilt from the
real design file instead of provisional placeholder values.

| What moved | Before | Now |
| --- | --- | --- |
| Token values | Provisional | 396 constants generated from the Figma variables export |
| Type scale | Placeholder | `Nunito Sans` 10, 12, 13, 14, 16, 20, 24, 36, 48, 56 with paired line heights |
| Spacing scale | — | 4 / 8 / 16 / 24 |
| Radius scale | — | 2 / 4 / 8 plus full rounding |
| The token carrier | `LumiereTheme` | `LumiereTokens`, a `ThemeExtension` carrying the semantic roles and the brightness |
| The button's API | A single variant enum | Five axes: `type`, `kind`, `shape`, `size`, and real widget states |
| Identifier language | Spanish | English |

**What to change.**

1. Rename `LumiereTheme` to `LumiereTokens` and read it with
   `LumiereTokens.of(context)` rather than as a `ThemeExtension` you construct
   yourself.
2. Replace every use of the button's variant enum with the axis that expresses the
   intent: what it *looks* like is `type`, what it *means* is `kind`, its corner and
   proportion is `shape`, its height is `size`.
3. Do not replace `LumiereDensity`. It was removed and will not return: density is
   decided by the tokens, and Material's `visualDensity` is left at its default so
   it cannot silently resize a token-driven control.
4. Any colour or font size you copied out of the provisional tokens is wrong now.
   Read it from `LumiereTokens.of(context).colors` or from an `Arco*` scale.

---

## 0.1.0

The first version. Nothing to migrate from.

Its token values were explicitly provisional: Figma was not accessible, so they did
not come from the design file. Nothing in `0.1.0` should be used as a reference for
a value.

---

## Status

Every breaking release in the CHANGELOG has a section here, and every section names
the old value, the new one and the reason.

The record is incomplete in one direction: 0.3.0 to 0.6.0 are not tagged in git, so
"which commit is 0.5.0" is answerable only by reading the CHANGELOG - and at least
one shipped change, the light danger pair moving to white, appears in no version at
all (**OPEN-19**).

## Open items

- **OPEN-19** - Releases are not tagged past `v0.2.0` and one shipped change has no CHANGELOG line, so the mapping from version to commit is not reconstructable.
