# 04 - Theming

Two themes, one channel, and how far an application may go in changing them.

---

## INT-010 - Two themes, dark by default

`LumiereThemeData.dark()` and `LumiereThemeData.light()` are the only themes the
package ships. Dark is the product default and the theme the package's goldens are
produced against.

An application MUST NOT build a theme by hand from the `Arco*` classes. It MAY pass
either of the two factories, and it MAY extend the result - but a hand-built
`ThemeData` that omits the `LumiereTokens` extension leaves every component in the
release-mode fallback (INT-006).

---

## INT-011 - The token channel is a `ThemeExtension`

`LumiereTokens` carries `colors` and `brightness`, and it is the only way a
component reads colour:

```dart
final LumiereTokens tokens = LumiereTokens.of(context);
final Color surface = tokens.colors.surfaceBase;
```

Three properties an application can rely on:

- `of(context)` asserts in debug when the extension is missing, with a message that
  names `LumiereThemeData`. The failure is a wiring mistake, and it is reported as
  one rather than as a null.
- In release, a missing extension falls back to `LumiereColors.dark` instead of
  throwing. A component therefore never crashes for this reason - and never tells
  you either.
- `lerp` interpolates every colour, so an animated theme transition crosses the
  palettes smoothly rather than snapping.

---

## INT-012 - What the theme maps, and what it refuses to

`LumiereThemeData` builds a `ColorScheme` from a seed, then overrides the roles
that matter: `primary`, `onPrimary`, `error`, `onError`, `surface`, `onSurface`,
`onSurfaceVariant`, `outlineVariant`. It maps seven text styles
(`headlineSmall`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`,
`bodySmall`, `labelMedium`) and sets `scaffoldBackgroundColor`, `canvasColor` and
`dividerColor`.

It deliberately does **not** set `visualDensity`. Material's density would silently
resize every token-driven control, which is the opposite of owning the geometry
(`DS-CONST-10`). Components that wrap a Material widget set `tapTargetSize`
explicitly for the same reason.

Consequence for a consumer: stock Material widgets an application drops on the page
inherit this identity, but at *their* sizes, not at the Lumiere control sizes. Only
the package's components are measured.

---

## INT-013 - Overriding a token

`LumiereTokens` exposes `copyWith`, so an application can change the brightness or
replace the whole colour set:

```dart
final ThemeData base = LumiereThemeData.dark();
final LumiereTokens tokens =
    base.extension<LumiereTokens>()!.copyWith(colors: myColors);
final ThemeData themed = base.copyWith(
  extensions: <ThemeExtension<dynamic>>[tokens],
);
```

**The gap:** `LumiereColors` has no `copyWith`. Changing a single role - one brand
accent, one surface - requires constructing all twenty-one fields by hand, and that
constructor has no defaults, so the change is unsafe to write and impossible to
review. An application that wants one different colour today either rebuilds the
whole palette or forks the package.

This is the single most likely reason a second project would stop using the
package, and it is the first thing an `INT` change should address.

**The exception, since 0.7.0:** the font family does have the ergonomic path. It is a
`String` field with a default, so it travels the short way and needs no `copyWith`
surgery at all:

```dart
final ThemeData theme = LumiereThemeData.dark(fontFamily: 'Acme Sans');
```

That is deliberate: colours are the design's and a partial override of them is a
question for the design file, while the typeface is the one thing every consumer is
expected to own (INT-004). An application MUST NOT read this as a precedent for
patching individual colours.

---

## INT-014 - Nesting a theme

A light panel inside a dark application MUST be wrapped in its own theme:

```dart
Theme(
  data: LumiereThemeData.light(),
  child: Builder(
    builder: (BuildContext context) => ColoredBox(
      color: LumiereTokens.of(context).colors.surfaceBase,
      child: const MyLightPanel(),
    ),
  ),
)
```

Both halves are required. Painting a light *background* without providing a light
*theme* produces dark tokens on a white surface - a hybrid no theme produces, and
one that the package's own goldens shipped for the divider and the loading
indicator (**OPEN-08**). The `Builder` matters because `LumiereTokens.of` must be
called below the `Theme` that carries it.

---

## INT-015 - What an application MUST NOT do

- Read a component's resolved colour from a painter. The painters are public for the
  package's tests only (INT-002).
- Wrap a package component in `Semantics` to supply the name it should have had.
  That is a defect to report, not a workaround to standardise (**OPEN-03**).
- Set `MaterialApp.theme.fontFamily` to substitute the typeface. See INT-004.
- Pass `visualDensity` to a component's ancestor to make it smaller. Use the
  control's own `size` axis, which is the measured one.

---

## Status

The two themes, the extension, the `ColorScheme` mapping, the refusal to set
`visualDensity` and the nesting model are all implemented and exercised - the
gallery toggles both themes over twelve pages, and the goldens cover both palettes
for three components.

Two weaknesses: `LumiereColors` cannot be partially overridden, and the nesting
model is easy to get half right, as the package's own goldens demonstrate.

## Open items

- **OPEN-08** - Two goldens paint a light surface with dark tokens, which is the exact failure mode the nesting rule warns against.
- **OPEN-13** - `fill.*` is documented as an overlay tint but is opaque in the light theme, so a consumer composing an overlay from it gets a solid rectangle.
