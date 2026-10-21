# 05 - Verification

What is executed today, measured on 2026-10-16 against `0.6.0`. Each gate is stated
with the command that runs it and the result that command produced; where a gate is not
executed by a workflow, the rule that follows says so and the `Status` section says what
that costs.

## Gates

| Gate | Command | Result | What it proves |
| --- | --- | --- | --- |
| Static analysis | `flutter analyze` | clean, no issues | types, lints from [`analysis_options.yaml`](../../analysis_options.yaml); walks `example/` as well |
| Behaviour, semantics, geometry, colour | `flutter test --exclude-tags=golden` | 122 tests pass | everything except the pixels |
| The visual contract | `flutter test test/golden` | 7 goldens pass on Windows | what each component looks like, variant by variant |
| Baseline regeneration | `flutter test --update-goldens` | rewrites `test/golden/goldens/` | nothing by itself; the diff is the evidence |
| Archive shape | `flutter pub publish --dry-run` | 0 warnings, 122 KB | the file list a consumer downloads, and that nothing in it is a warning |
| Gallery analysis | `flutter analyze` in `showcase/` | clean | the gallery compiles against the package's public API |
| Gallery tests | `flutter test --exclude-tags=golden` in `showcase/` | 11 tests pass | every catalog entry builds, in both themes |
| Gallery build | `flutter build web --release --base-href "/<repo>/"` | succeeds | the published documentation is not stale |

The suite is organised in six layers: colour contract arithmetic
([`test/accessibility/contrast_test.dart`](../../test/accessibility/contrast_test.dart)
and [`status_ink_test.dart`](../../test/accessibility/status_ink_test.dart)),
behaviour, semantics, geometry, colour resolution and goldens. The first five are the
122 tests that run on every platform; the sixth is the seven baselines that run only
on the reference one.

`showcase/**` is excluded from the root analyzer in
[`analysis_options.yaml`](../../analysis_options.yaml) because the gallery is a
package of its own with dependencies this one does not have:
`flutter analyze` walks into it from here and cannot resolve those imports on a fresh
clone. It is not left unverified, but it is verified by a workflow that never runs on
a pull request.

## What CI runs

| Workflow | Trigger | Steps |
| --- | --- | --- |
| [`ci.yml`](../../.github/workflows/ci.yml) | push to `main`, `pull_request` | `pub get`, `flutter analyze`, `flutter test --exclude-tags=golden`, `flutter pub publish --dry-run` |
| [`pages.yml`](../../.github/workflows/pages.yml) | push to `main` on `showcase/**`, `lib/**`, `pubspec.yaml`, the workflow, plus `workflow_dispatch` | every declared typeface face is present, `pub get`, `flutter analyze`, `flutter test --exclude-tags=golden`, `flutter build web --release --base-href "/<repo>/"`, the typeface reached the bundle, then configure, upload and deploy Pages |

Both run on `ubuntu-latest` with `channel: stable`. `pages.yml` has no
`pull_request` trigger, so the gallery gates are only observed after merge, on
`main`; Pages must be enabled once by hand with Source = GitHub Actions.

`pages.yml` carries two gates that exist only because the gallery ships a licensed
typeface the package does not: one before `pub get` that checks every `asset:` line in
`showcase/pubspec.yaml` against the checkout, and one after the build that checks the
`FontManifest.json` of the artifact for the family and every declared face against
`build/web/assets`. The second is the one that matters: a font declared but not emitted
deploys a site that renders in a fallback face, and no other test would say so. Both
were exercised in the passing and the failing direction before being committed.

The golden tag is declared in [`dart_test.yaml`](../../dart_test.yaml) and not
skipped there. It is excluded by the `--exclude-tags=golden` flag and nothing else,
so a plain `flutter test` on Linux or macOS fails on the seven baselines and pushes
the contributor toward regenerating images they cannot review.

## Rules

`PRC-020` - What MUST pass before merge. A pull request MUST pass `flutter analyze`,
`flutter test --exclude-tags=golden` and `flutter pub publish --dry-run`, and those
three results are the only executed proof a reviewer may accept. A change that
touches `showcase/` or the public API MUST also be run through the gallery gates
locally, because no pull request runs them.

`PRC-021` - The local Windows run. Only a local run on the reference operating system
can verify the seven goldens, and therefore any change to what a component paints. A
pull request that changes painting without changing a baseline MUST state that the
goldens were run and passed, by whom and when. A pull request that changes a baseline
MUST state why the image changed; a change to a `.png` with no corresponding change
to a token, a painter or a widget is a defect until proven otherwise.

`PRC-022` - A baseline changes only with a reviewed diff. `--update-goldens` MUST be
run on Windows, the resulting images MUST be opened and compared before they are
committed, and the regeneration MUST NOT be bundled into a commit whose subject is
about something else. A baseline regenerated on another operating system MUST NOT be
committed at all: it encodes that machine's rasterisation, not the design.

`PRC-023` - A new gate is a workflow step. A check that matters MUST be added to
[`ci.yml`](../../.github/workflows/ci.yml) or [`pages.yml`](../../.github/workflows/pages.yml)
as a step, not written down as a rule. A rule whose gate exists only in prose MUST be
registered as an `OPEN-nn` in
[`07-traceability/open-items.md`](../07-traceability/open-items.md) and MUST NOT be
cited as enforced (`DS-CONST-12`).

`PRC-024` - The archive is checked after any ignore-rule change. Because
[`.pubignore`](../../.pubignore) takes precedence over `.gitignore` for `pub publish`,
a rule that lives only in one of the two stops applying to the archive. A change to
either file MUST be followed by `flutter pub publish --dry-run` and a read of the
file list.

## Status

The visual oracle is a single machine and is not validated in any pull request. The
seven goldens are green on Windows; `ci.yml` excludes them and `pages.yml` runs
nothing that reads `test/golden/`, so no review has ever observed a pixel of this
package. A green CI run proves analysis, behaviour, semantics, geometry and archive
shape, and proves nothing about what a component looks like. Every other gate is
executed on every pull request, and none of them is pinned to the Flutter version the
package requires.

## Open items

- **OPEN-14** - CI pins no Flutter version (`channel: stable` in both workflows) although the package requires `>=3.47.0`; `pages.yml` has no `pull_request` trigger; the goldens never run in CI.
- **OPEN-15** - there is no `dart format` gate and 48 of 60 files differ from the current formatter, so formatting is invisible to every gate above.
- **OPEN-20** - the pub archive ships the seven golden baselines in `test/golden/goldens/`, about 65 KB of test images a consumer cannot use.

