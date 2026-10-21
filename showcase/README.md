# lumiere_ui showcase

Visual documentation of the `lumiere_ui` package: one page per component with
live examples, the variant matrix, the state list and the full API, plus the
token foundations.

It is not a product surface and it is not published. It exists so a component
can be **looked at and operated** before it is trusted: a disabled state, a
focus ring and a loading indicator only prove themselves when they can be
clicked, tabbed into and compared against the design file.

Published at <https://jeissonlazo.github.io/luminiere_ui/>.

## Why a Flutter web application

The components are Flutter widgets. A screenshot would go stale the moment a
token changed and could never show hover, focus or keyboard operation. Building
the gallery as a web application means every example on it is the real widget,
built from the same public API a product surface uses - anything the gallery can
render, an application can render.

## Running it

The gallery consumes the package through its single public entry point. Two
layouts are supported:

**Inside the package repository** (how it is published). `pubspec.yaml` points
at `../`:

```powershell
cd showcase
flutter pub get
flutter run -d chrome
```

**Side by side with a package checkout** (how it is usually developed). Use
Dart's local override instead of editing `pubspec.yaml`:

```
<parent>/luminiere_ui/     <- the package
<parent>/showcase/         <- this gallery
```

```yaml
# showcase/pubspec_overrides.yaml, not committed
dependency_overrides:
  lumiere_ui:
    path: ../luminiere_ui
```

## Verification

```powershell
flutter analyze
flutter test                     # widget tests + goldens
flutter test --exclude-tags=golden   # goldens are OS dependent, as in the package
flutter test --tags=golden --update-goldens   # regenerate the baselines
```

### The golden baselines

`test/golden/goldens/` holds one image per page, in both themes. They are the
visual half of the verification: the widget tests prove that a page builds, and
the baselines prove what it looks like. Review the diff when the baselines
change.

Two things are worth knowing about them:

- **They are captured with the real typeface.** Since 0.7.0 the gallery declares and
  bundles `Mark Pro` in `fonts/MarkPro/`, and `test/support/gallery_fonts.dart`
  registers those same faces from disk, so a baseline shows the letterforms a user
  sees rather than a substitute. The one caveat is the weight axis: `FontLoader`
  cannot assign a weight, so a face is matched by the weight it declares about itself,
  and the test loader deliberately omits `MarkPro.otf` to make `w400` resolve to the
  same face the manifest binds it to. See `OPEN-26`.
- **The loading indicator never settles.** It rotates for as long as it is
  mounted, so the tests advance time by a fixed step instead of using
  `pumpAndSettle`, which would never return.

## Adding a component page

1. Write `lib/src/pages/<component>_page.dart`. Build it from `DocPage`,
   `DocSection`, `ExampleCard`, `Playground`, `DocTable` and `Callout`, so it
   matches the other pages without restating the layout.
2. Register it in `lib/src/catalog.dart`. That one list drives the sidebar, the
   overview cards and the coverage test, so there is a single place to keep in
   step.
3. Cite the rule. `ruleId` is the identifier of
   `docs/constraints/design-constraints.md` of the application repository, which
   is where the normative text lives. The gallery shows what the package built
   from a rule; it never restates the rule.
4. Say what is provisional. Where the package is uncertain, the page uses a
   `Callout` with `CalloutTone.warning` and names the pending item. A gallery
   that presents an open question as settled is worse than no gallery.
5. Regenerate the baselines: `flutter test --tags=golden --update-goldens`, then
   look at the images.

## Deployment

`.github/workflows/pages.yml` builds this directory and publishes it to GitHub
Pages on every push to `main` that touches the package or the gallery.

The base href is derived from the repository name, so nothing has to be edited
if the repository is renamed:

```
flutter build web --release --base-href "/${repo}/"
```

**The typeface has to be in the checkout.** The gallery declares `Mark Pro`, the
package ships no font, and the faces are licensed - so they are committed here, in
`fonts/MarkPro/`, and a fork without a licence for them cannot build this workflow.
The build does not rely on that being true by accident: two steps make it explicit.

| Step | Fails when | Why it exists |
| --- | --- | --- |
| *Every declared face is present* | an `asset:` line in `pubspec.yaml` names a file the checkout does not have | `flutter pub get` would fail later, inside the asset bundler, with a message about a path and no mention of the licence that puts the file there |
| *The typeface reached the bundle* | the built `FontManifest.json` has no `Mark Pro`, or a declared face was not emitted to `build/web/assets` | a font that is declared but not emitted deploys a site that renders in a fallback face, and nothing else would report it |

Both are run against the real tree, in the passing and the failing direction, before
being committed; the faces they check are the sixteen `pubspec.yaml` declares, not a
hardcoded count, so adding a weight needs no change to the workflow.

**The one-time setup is done.** Pages is enabled for this repository with
*Settings → Pages → Build and deployment → Source* set to **GitHub Actions**, so
what this workflow uploads is what gets served. Two things worth knowing before
touching that screen again:

- **Do not pick a template from it.** The *GitHub Pages Jekyll* and *Static HTML*
  cards create a second workflow that competes with this one, and neither can
  build a Flutter application: *Static HTML* would publish the repository root,
  which holds no `index.html`, and *Jekyll* would find no site to build.
- `actions/configure-pages` has an `enablement: true` input that looks like it
  would turn Pages on by itself, and this workflow deliberately does not use it:
  the action documents that the option *requires a token other than
  `GITHUB_TOKEN`*. The default token cannot enable Pages, so setting it fails the
  run instead of helping. Doing it that way needs a personal access token in a
  secret, which is more setup than the click it replaces.

## Known gaps

- **The typeface is licensed, and the gallery is the only thing that carries it.**
  `Mark Pro` lives in `fonts/MarkPro/` and is declared in `pubspec.yaml`, so the
  gallery renders what a licensed consumer renders. It is not in the package and not
  in the published archive, and a checkout that has no licence for it will fail to
  build the gallery rather than fall back silently. A consumer supplies its own.
- **The weight binding is a decision, not a measurement.** Ten family cuts are pressed
  into Flutter's nine slots, so `w600` renders Bold and `400` is bound to `Book`
  (`OPEN-26`).
- **The URL does not reflect the page.** Navigation is in memory, so a deep link
  cannot be shared and a refresh returns to the overview. Adding hash routing
  would be a small change; it was left out because it needs a `404.html` shim to
  survive a refresh on Pages, which is a deployment concern rather than a
  documentation one.
- **No search.** With twelve pages the sidebar is enough; it stops being enough
  as the component list grows.

## Licence

MIT covers the gallery's code. The typeface in `fonts/MarkPro/` is **not** MIT and is
not covered by the package's licence: it is bundled here under the project's own
licence from the foundry, and it is excluded from the published archive.
