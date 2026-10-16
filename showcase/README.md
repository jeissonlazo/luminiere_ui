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

- **They are captured with substitute typefaces.** `lumiere_ui` declares
  `Nunito Sans` and redistributes no font, so the baseline registers the Roboto
  instances that ship inside the Flutter SDK under the declared family name, and
  a system monospace face under `monospace`. This makes the layout and the type
  scale reviewable. It does **not** make the baseline a check of Nunito Sans
  itself - see `test/support/gallery_fonts.dart`.
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

**One-time setup, and it has to be done by hand:** in the repository, *Settings
→ Pages → Build and deployment → Source* must be set to **GitHub Actions**.
Until then the workflow runs and the deploy job fails, because there is no Pages
site to publish to. The repository is public, so Pages costs nothing.

`actions/configure-pages` has an `enablement: true` input that looks like it
would remove that click, and the workflow deliberately does not use it: the
action documents that the option *requires a token other than `GITHUB_TOKEN`*.
The default token the workflow runs with cannot enable Pages, so setting it
would fail the run rather than spare the click. Doing it that way needs a
personal access token stored as a secret, which is more setup than the click it
replaces.

## Known gaps

- **The typeface is not bundled.** Text falls back to the platform default, which
  is the state the product itself is in. The block to add Nunito Sans is
  commented out in `pubspec.yaml`; dropping the static instances into `fonts/`
  and uncommenting it is the whole change.
- **The URL does not reflect the page.** Navigation is in memory, so a deep link
  cannot be shared and a refresh returns to the overview. Adding hash routing
  would be a small change; it was left out because it needs a `404.html` shim to
  survive a refresh on Pages, which is a deployment concern rather than a
  documentation one.
- **No search.** With twelve pages the sidebar is enough; it stops being enough
  as the component list grows.

## Licence

MIT, as the package. The gallery bundles no typeface.
