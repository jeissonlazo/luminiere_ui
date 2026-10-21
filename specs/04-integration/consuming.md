# 04 - Consuming the package

What an application may depend on, and what the application must supply itself.

This is the section that did not exist before `specs/`: the package was adoptable
only by reading its source. Everything below is a guarantee, not an observation -
the observations that are not guarantees are listed at the end, deliberately.

---

## INT-001 - One import

An application MUST import exactly one library:

```dart
import 'package:lumiere_ui/lumiere_ui.dart';
```

Importing anything under `package:lumiere_ui/src/` is unsupported. Those paths may
be renamed or moved in any release, including a patch, because the barrel is the
only surface `DS-CONST-01` protects.

---

## INT-002 - What is exported, and what is not

**Components.** `LumiereButton`, `LumiereCheckbox`, `LumiereRadio`,
`LumiereRadioGroup`, `LumiereSwitch`, `LumiereTag`, `LumiereDivider`,
`LumiereLoading`, and their enum types.

**Theme.** `LumiereThemeData`.

**Semantic tokens.** `LumiereTokens`, `LumiereColors`, `LumiereStatusColors`,
`LumiereRamp`, `LumiereTagColor`, `LumiereTagColorName`, `LumiereStrokes`.

**Scales.** `ArcoType`, `ArcoSpace`, `ArcoRadius`, `ArcoControl`, `ArcoTag`.

**Not exported, on purpose.** `ArcoPaletteDark`, `ArcoPaletteLight`,
`ArcoSemanticDark`, `ArcoSemanticLight`, `ArcoComponentDark`, `ArcoComponentLight`.
Colour reaches an application through the semantic roles only (`DS-CONST-03`). An
application that needs a colour reads `LumiereTokens.of(context).colors`.

**Not exported, and not API.** The painters (`LumiereSwitchPainter`,
`LumiereCheckboxPainter`, `LumiereRadioPainter`) and `LumiereSwitchMetrics` are
public only so the package's own tests can assert what a component resolved. They
carry no stability promise and MUST NOT be relied on.

---

## INT-003 - Installing

```yaml
dependencies:
  lumiere_ui: ^0.6.0
```

Until the first pub.dev release, consume it from the repository:

```yaml
dependencies:
  lumiere_ui:
    git:
      url: https://github.com/jeissonlazo/luminiere_ui.git
      ref: main
```

A git dependency is pinned in `pubspec.lock`: after new commits, an application
MUST run `flutter pub upgrade lumiere_ui` to pick them up. This surprises everyone
exactly once.

To work on the package and the application at the same time, use
`dependency_overrides` with a local path instead of pushing on every change. The
override MUST NOT be committed to an application that other people build: it is
silently ignored, which turns a local experiment into a mystery on CI.

> The version above is `0.6.0`. The README of the package still says `^0.2.0` -
> **OPEN-19**.

---

## INT-004 - The application supplies the typeface

The package declares `Mark Pro` and redistributes no typeface. The design file also
declares `PingFang SC` as the CJK companion, which is not shipped either.

`Mark Pro` is a **commercial** typeface. The package's own archive carries no font
file and never will, for the obvious reason and for the stated one (`DS-TYPE-005`): a
library that redistributes a licensed font redistributes a liability, and a library
that hard-codes a brand face cannot serve a second brand.

Two ways to satisfy this, and one of them is new in 0.7.0.

**The application owns a licence for the declared family.** Register the faces under
exactly the name the package reads, and nothing else changes:

```yaml
flutter:
  uses-material-design: true   # also required: the tag draws Icons.close

  fonts:
    - family: Mark Pro         # exactly this string, with the space
      fonts:
        - asset: fonts/MarkPro/MarkPro-Book.otf
          weight: 400
        - asset: fonts/MarkPro/MarkPro-Medium.otf
          weight: 500
        - asset: fonts/MarkPro/MarkPro-Bold.otf
          weight: 700
```

**The application has its own family.** Register that one and name it in the theme:

```dart
MaterialApp(
  theme: LumiereThemeData.dark(fontFamily: 'Acme Sans'),
  ...
)
```

The name MUST be the one declared in the application's `pubspec.yaml`, not the name
inside the font file. Every component reads it from `LumiereTokens.fontFamily`, so a
single argument moves the whole system, including the styles the theme builds for
stock Material widgets. This is the path a second product should take.

**The weight axis is not free.** Flutter accepts only nine weight slots and the
declared family has ten cuts with no 600, so the manifest binding is a decision: 400 is
`Book` (the reading weight), 500 is `Medium`, 700 is `Bold`, and a `w600` request - which
is every heading in this design system - is drawn with `Bold`. `OPEN-26` records it and
the gallery's `pubspec.yaml` states the whole table.

**What else to know.**

- The family name is the only lever the package exposes; the sizes, weights and line
  heights stay the design's. An application that wants a different type *scale* is
  asking for a different design system.
- A missing family does not error: the engine falls back to the platform default and
  the layout stays correct while the letterforms are wrong. An application SHOULD
  assert the family it registered in its own test, because nothing here will.
- An application SHOULD NOT patch the family through `ThemeData.fontFamily`: that
  reaches the Material widgets and not `LumiereTokens.text()`, so the components and
  the stock widgets would disagree.
- After the change, `flutter pub get` and a full restart: hot reload does not
  re-register font assets.

---

## INT-005 - The application supplies the icons

The package is icon-agnostic: `LumiereButton` takes `leadingIcon`/`trailingIcon` as
widgets, `LumiereSwitch` takes `handleIcon`/`trackIcon`, `LumiereCheckbox` takes
none, and `LumiereTag` takes `icon`. The application passes whatever set it uses;
the gallery passes Lucide (MIT), as the product does.

One exception, recorded because it contradicts the rule it illustrates: the tag's
close action draws `Icons.close` from Material
([lumiere_tag.dart:167](../../lib/src/components/tag/lumiere_tag.dart)), so an
application MUST keep `uses-material-design: true` in its `pubspec.yaml` even if it
uses a different icon family everywhere else.

---

## INT-006 - Wiring the theme

```dart
MaterialApp(
  theme: LumiereThemeData.dark(),
  home: const MyPage(),
)
```

The theme MUST be a `LumiereThemeData`. Components read `LumiereTokens` from
`Theme.of(context).extension<LumiereTokens>()`; if the extension is missing, every
component asserts in a debug build with a message naming the mistake, and in a
release build falls back to the dark tokens rather than crashing.

Consequence worth knowing: a component mounted under a theme that is not
`LumiereThemeData` renders in the dark palette in release. It is a wiring decision,
not a visual one, and `LumiereThemeData.light()` is the only way to opt out.

---

## INT-007 - The application supplies every user-visible string

The package ships no word a user reads (`DS-CONST-09`). Concretely:

| Need | Who provides it |
| --- | --- |
| A control's accessible name | `label` where the component has a visible label; `semanticLabel` on the switch and the loading indicator |
| The tag's close action name | `closeSemanticLabel`, required when `onClose` is set |
| A loading announcement | `semanticLabel` on `LumiereLoading`; without it the indicator is decorative |

An application with more than one locale MUST pass every one of those per locale.
The package has no `Localizations` delegate and no intent of adding one.

Known gap: `LumiereButton` in an icon-only shape, `LumiereCheckbox` and
`LumiereRadio` without a visible label accept no name at all - **OPEN-03**.

---

## INT-008 - The platform floor

| Requirement | Value |
| --- | --- |
| Dart SDK | `^3.13.5` |
| Flutter | `>=3.47.0` |

The radio depends on `RawRadio`, `RadioGroupRegistry` and `RadioClient`, which
arrive with `package:flutter/material.dart` and therefore appear in no version
constraint. A Flutter upgrade can break this package without any dependency moving
(see [ADR-0006](../06-decisions/adr-0006-raw-radio-from-the-sdk.md)). An
application SHOULD run the package's tests against a Flutter upgrade before
adopting it.

---

## INT-009 - What is explicitly not guaranteed

- Internal paths, painters and metrics (INT-002).
- The `Arco` prefix. It is the name the design tool uses and it survives here for
  traceability; a rename is possible and would be breaking.
- Colour values. They are measured from a design file this repository does not
  contain (**OPEN-07**), and the design file is free to move them.
- Any contrast guarantee for the tag's label in the light theme (**OPEN-06**).
- Hover and pressed rendering, which currently differs from the resolved token in
  both themes (**OPEN-01**).

---

## Status

Installation, the entry point, theming, strings and the platform floor are all
verifiable today and are exercised by `example/` and by the gallery, which consume
the package through the same single import an application does.

The gaps are documentation-and-guarantee gaps, not wiring gaps: one stale version
number in the README, three components with no way to receive an accessible name,
and a hover state that renders a colour no token states.

## Open items

- **OPEN-01** - Hover and pressed fills do not match the tokens in either theme; the light primary button renders an unreadable label.
- **OPEN-03** - The button in an icon-only shape, the checkbox and the radio cannot receive an accessible name.
- **OPEN-06** - No contrast guarantee for the tag label in the light theme.
- **OPEN-07** - The token source and its generator are not in this repository.
- **OPEN-19** - The README pins `^0.2.0` while the package is `0.6.0`.
