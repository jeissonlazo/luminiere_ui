# lumiere_ui

Design system and component library for **Lumiere**.

It is independent of the application: it never imports the editor, the viewport,
the domain or `flutter_gpu`. Its only visual input is the token layer and its
only output is widgets.

## Component gallery

The components are documented, live, at
<https://jeissonlazo.github.io/luminiere_ui/>: one page per component with its
variants, its states and its API, plus the token foundations, in both themes.

The gallery is a Flutter web application in `showcase/`, published by
`.github/workflows/pages.yml`. It consumes this package through its single
public entry point, exactly as an application does, so anything it can render an
application can render too. See [`showcase/README.md`](showcase/README.md).

## Install

```yaml
dependencies:
  lumiere_ui: ^0.2.0
```

Until the first release is published on pub.dev, consume it from the repository:

```yaml
dependencies:
  lumiere_ui:
    git:
      url: https://github.com/jeissonlazo/luminiere_ui.git
      ref: main
```

Note that a git dependency is pinned in `pubspec.lock`: after pushing new commits
you need `flutter pub upgrade lumiere_ui` to pick them up. To work on the package
and the application at the same time, use `dependency_overrides` with a local
path instead of pushing on every change.

## Usage

```dart
MaterialApp(
  theme: LumiereThemeData.dark(),
  home: Scaffold(
    body: LumiereButton(
      label: 'Save',
      leadingIcon: const Icon(Icons.save),
      onPressed: _save,
    ),
  ),
)
```

The typeface is the one thing the package asks you to supply. It declares `Mark Pro`
and redistributes no font file, so register your licensed copy - or any family of your
own - in your `pubspec.yaml` and name it:

```dart
theme: LumiereThemeData.dark(fontFamily: 'Mark Pro'),
```

The default is the family the design declares. See
[`specs/04-integration/consuming.md`](specs/04-integration/consuming.md) for the
registration snippet, the weight binding, and what happens when a family is missing.

## Token layers

Three layers, each with a different owner:

1. **Primitives** - `ArcoPaletteDark/Light`, `ArcoSemanticDark/Light`,
   `ArcoComponentDark/Light`. Generated from the Figma variables export.
   Components never reference these directly.
2. **Semantic roles** - `LumiereColors` and `LumiereStatusColors`. A hand-written
   mapping from roles to primitives, taken from the descriptions the design file
   itself attaches to each token. This is the only layer components read colours
   from.
3. **Scales** - `ArcoType`, `ArcoSpace`, `ArcoRadius`, `ArcoControl`, `ArcoTag` and
   `LumiereStrokes`. Mode-independent constants.

The family is the one part of the type scale that travels with the theme rather than
as a constant, so an application can replace it without forking the package.

Regeneration lives in the Lumiere repository, which owns the design sources:

```powershell
node tools/build-tokens.mjs
```

## Where the values come from

| Layer | Source |
| --- | --- |
| Colour | Variables export of `Arco Design System lumimier` (Figma `E6OUz1aF3tykVnr341r6fl`) |
| Type scale | Figma page `Basic styles` - family `Mark Pro`, sizes 10 to 56 |
| Spacing | Approved scale 4 / 8 / 12 / 16 / 20, every step divisible by two |
| Radius | Measured `cornerRadius` usage: 2 dominates, then 4 and 8, plus full rounding |
| Control heights | Measured from the Arco kit geometry: 24 / 28 / 32 / 36 with paddings 12 / 16 / 16 / 20 |

## Component contract

Every component mirrors the axes the design file declares. `Button` has five:

| Axis | Values |
| --- | --- |
| `type` | primary, secondary, dashed, outline, text |
| `kind` | standard, danger, warning, success |
| `shape` | rectangle, pill, square, circle |
| `size` | large, medium, small, mini |
| `state` | default, hover, focus, active, disabled |

State is deliberately **not** a property: default, hover, focus, active and
disabled are real widget states in Flutter, so the component resolves them
internally instead of letting a caller describe a state the widget is not in.
`loading` is the only state that cannot be expressed that way, so it stays a
property.

## Adding a component

1. Confirm it exists in the design file and list its axes and options. If the
   contract is unavailable, mark the API as provisional.
2. Create `lib/src/components/<name>/<name>.dart` using only semantic roles and
   scales - no literals.
3. Cover every state, make focus visible, guarantee keyboard operation and an
   accessible name.
4. Export it from `lib/lumiere_ui.dart`.
5. Add behaviour tests and a **golden per variant and state**. The golden is the
   verification of the design contract, not an extra.
6. Register it in the application gallery.

## Verification

```powershell
flutter analyze
flutter test                  # behaviour + goldens
flutter test --update-goldens # regenerate the baseline and review the diff
```

Goldens depend on the operating system's rasterisation, so they are tagged and
excluded from CI (`--exclude-tags=golden`).

## Specifications

The normative specifications live in [`specs/`](specs/README.md): the twelve
invariants, the token layers, one file per component, the accessibility contract and
its exception register, the guarantees an application may depend on, and the register
of what is still unproven.

They are written for the repository and excluded from the published archive
(`.pubignore`). A consumer reads the guarantees that concern them through
[`specs/04-integration/consuming.md`](specs/04-integration/consuming.md), which the
sections above mirror less formally.

## Licence

MIT, and that covers the code only. `Mark Pro` is a commercial typeface: the package
declares the family name and bundles **no** font file, and neither the repository's
package nor its published archive redistributes one. Each application supplies its own
licensed copy - see
[`specs/04-integration/consuming.md`](specs/04-integration/consuming.md). The gallery
under `showcase/` carries its own copy for its own rendering and stays out of the
published archive.
