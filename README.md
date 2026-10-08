# lumiere_ui

Design system and component library for **Lumiere**.

It is independent of the application: it never imports the editor, the viewport,
the domain or `flutter_gpu`. Its only visual input is the token layer and its
only output is widgets.

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

## Token layers

Three layers, each with a different owner:

1. **Primitives** - `ArcoPaletteDark/Light`, `ArcoSemanticDark/Light`,
   `ArcoComponentDark/Light`. Generated from the Figma variables export.
   Components never reference these directly.
2. **Semantic roles** - `LumiereColors` and `LumiereStatusColors`. A hand-written
   mapping from roles to primitives, taken from the descriptions the design file
   itself attaches to each token. This is the only layer components read colours
   from.
3. **Scales** - `ArcoType`, `ArcoSpace`, `ArcoRadius`, `ArcoControl`.
   Mode-independent constants.

Regeneration lives in the Lumiere repository, which owns the design sources:

```powershell
node tools/build-tokens.mjs
```

## Where the values come from

| Layer | Source |
| --- | --- |
| Colour | Variables export of `Arco Design System lumimier` (Figma `E6OUz1aF3tykVnr341r6fl`) |
| Type scale | Figma page `Basic styles` - family `Nunito Sans`, sizes 10 to 56 |
| Spacing | The `Space` component declares 4 / 8 / 16 / 24 |
| Radius | Measured `cornerRadius` usage: 2 dominates, then 8 and 4 - pending confirmation |
| Control heights | Arco's published specification - **pending verification** against the file |

Known open item: the horizontal padding per button size. The variables export
carries no padding tokens, so it is derived from the spacing scale until the
component geometry is extracted.

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

## Licence

MIT. The `Nunito Sans` typeface is **not** bundled: add it to the application
from Google Fonts (SIL Open Font License).
