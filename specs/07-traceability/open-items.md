# 07 - Open items

The pending list the code has been citing since 0.3.0 without a file to point at.

An entry here is a known deviation from a rule in these specifications. It is not a
backlog of features and not a wish list: every line records something the package
claims, does not do, and knows it. An entry leaves this file only when the code is
fixed **and** a test fails without the fix - otherwise it becomes a permanent
exception in the [register](../03-accessibility/exception-register.md) instead.

Severity: **critical** breaks something a user can see or fail; **high** breaks a
guarantee a consumer was told to rely on; **medium** weakens verification or drifts
documentation; **low** is hygiene.

## Summary

| ID | Sev | Area | Title |
| --- | --- | --- | --- |
| `OPEN-01` | critical | Button, colour | Material's overlay composites over the token fill; the light primary button renders a 1.11:1 label on hover |
| `OPEN-02` | low | Button, tokens | The dashed painter keeps private `4 / 3 / 1` literals instead of reading `LumiereStrokes` |
| `OPEN-03` | high | Button, checkbox, radio | No way to give an accessible name to an icon-only button or a label-less control |
| `OPEN-04` | high | Button, loading | A loading button loses its accessible name |
| `OPEN-05` | medium | Tag | The close-action name is guarded by an `assert` only, then dereferenced with `!` |
| `OPEN-06` | critical | Tag, colour | The tag label fails 4.5:1 in nine of eleven light families on the soft background and ten of eleven on the strong one, and the families are outside the contrast contract |
| `OPEN-07` | high | Tokens, provenance | The generated token file cannot be regenerated from this repository |
| `OPEN-08` | medium | Goldens | Two goldens render their "light" panel with dark tokens |
| `OPEN-09` | high | Focus | The button draws no focus ring, and no ring's contrast is measured |
| `OPEN-10` | medium | Accessibility test | The "an open exception must keep failing" test iterates an empty set |
| `OPEN-11` | medium | Loading, motion | The indicator ignores reduced motion, and no motion token exists |
| `OPEN-12` | medium | Tests | Named coverage gaps across components and platforms |
| `OPEN-13` | high | Tokens, colour | `fill.1` to `fill.4` are translucent in the dark theme and opaque in the light one |
| `OPEN-14` | medium | CI | Flutter is not pinned, the gallery has no PR trigger, and goldens never run in CI |
| `OPEN-15` | low | Hygiene | No `dart format` gate; 48 of 60 files differ from the current formatter |
| `OPEN-16` | low | Switch | The dartdoc still declares a 10 px small handle in three places |
| `OPEN-17` | low | Divider | `align: none` is an interpretation of the design, not a measurement |
| `OPEN-18` | low | Tag | The `filled`/`bordered` pairing is an inference from the measurement |
| `OPEN-19` | medium | Versioning | Releases are untagged past `v0.2.0`, the README pins `^0.2.0`, one shipped change has no CHANGELOG line |
| `OPEN-20` | low | Packaging | The pub archive ships the seven golden baselines |
| `OPEN-21` | medium | Register | `AE-12` to `AE-15` are cited by the button and exist in no register entry |
| `OPEN-22` | medium | Register | `AE-11` denotes two different entries, so a citation is ambiguous |
| `OPEN-23` | medium | Provenance | Unmeasured placeholder values are documented as pending but registered nowhere |
| `OPEN-24` | high | Tag, accessibility | The close action's tap target is the glyph's size, not the tag's height |
| `OPEN-25` | critical | Button, colour | An icon on a `primary` button is drawn in the fill's own colour: 1.00:1 in six of eight combinations |
| `OPEN-26` | high | Typography, weight | Ten family cuts pressed into nine Flutter slots: no 600, so every heading renders Bold, and 400 is bound to Book |
| `OPEN-27` | medium | Typography, rhythm | The line heights were measured against the previous family and were not re-measured |

---

## OPEN-01 - Material's overlay replaces the token fill

**Where:** [lumiere_button.dart:256](../../lib/src/components/button/lumiere_button.dart),
the single `overlayColor: WidgetStatePropertyAll<Color>(colors.fillDefault)`.

**What:** the resolved background is not the colour the state resolution returns.
Material paints the overlay on top of it, and in the light theme `fillDefault` is an
opaque `#F2F3F5`, so it *replaces* the fill. Measured by sampling rendered pixels:

| Theme | Resolved fill on hover | Rendered on hover | Label contrast |
| --- | --- | --- | --- |
| Light, primary | `#4080FF` (3.65) | `#F2F3F5` | **1.11:1**, white on near-white |
| Dark, primary | `#306FFF` (4.34) | `#407AFF` | **3.86:1**, not the recorded 4.34 |

The same tint erases the secondary button's hover feedback, because its hover fill
and the overlay are close to the same value.

**Why open:** nobody has fixed it because nothing observes composited pixels
(`DS-A11Y-001`), the goldens do not render hover, and the five colour assertions
that exist read the painter or the style, not the raster.

**Closing it:** the overlay MUST be a translucent tint that is composited onto an
unknown fill, or absent where the fill is a token; the light theme's opaque `fill.*`
cannot serve as an overlay (`OPEN-13`). A test that samples the centre pixel of a
hovered button against the resolved role MUST fail before the fix.

---

## OPEN-02 - Private dash literals in the button

**Where:** [lumiere_button.dart:332-333](../../lib/src/components/button/lumiere_button.dart)
and the `strokeWidth: 1` on line 169.

**What:** `LumiereStrokes` was introduced in 0.6.0 so components would stop writing
literals, and the divider reads it. The button's `_DashedBorderPainter` still
declares `_dashLength = 4` and `_gapLength = 3` privately, and passes a bare `1` for
the stroke width. The values agree today, so this is coupling rather than a visible
defect - a change to `LumiereStrokes.dash` would silently leave the button behind.

**Closing it:** delete the private constants, read `LumiereStrokes.dash`, `.gap` and
`.hairline`. A test asserting the painter's dash pattern against the tokens is the
guard that keeps it closed.

---

## OPEN-03 - No accessible name for icon-only and label-less controls

**Where:** [lumiere_button.dart:79-91](../../lib/src/components/button/lumiere_button.dart)
(no `semanticLabel`), [lumiere_checkbox.dart:77-85](../../lib/src/components/checkbox/lumiere_checkbox.dart),
[lumiere_radio.dart:68-77](../../lib/src/components/radio/lumiere_radio.dart).

**What:** `LumiereSwitch` and `LumiereLoading` accept `semanticLabel`; the button,
the checkbox and the radio do not. A button in the `square` or `circle` shape is an
icon-only control by design, and with an empty `label` it reaches the semantics tree
with no name - the package's own example ships exactly that
([main.dart:57](../../example/lib/main.dart)). A checkbox or radio without a visible
label is documented as "the accessible name is then empty", which for a form control
is not an acceptable resting state.

This contradicts `DS-CONST-06` in the component that most often needs it.

**Closing it:** add `semanticLabel` to the three components, used when the visible
label is absent, and require it in an `assert` when the shape or the absence of a
label makes the control nameless. A test that reads the semantics node's label for
an icon-only button is the guard.

---

## OPEN-04 - A loading button loses its name

**Where:** [lumiere_button.dart:280-284](../../lib/src/components/button/lumiere_button.dart).

**What:** with `isLoading: true` the content is replaced by
`LumiereLoading(...)`, which without a `semanticLabel` is wrapped in
`ExcludeSemantics`. The label is gone from the tree, so a screen reader announces a
button with no name while it is busy - the exact moment a user needs to know what is
busy.

The accessible name SHOULD come from the label the button already has, and the busy
state SHOULD be exposed as `busy: true` rather than as the absence of a name.

**Closing it:** keep `label` in the semantics tree while loading, or pass it to the
indicator; expose the busy state. A test asserting `hasFlag(SemanticsFlag.isBusy)`
or a non-empty label on a loading button is the guard.

---

## OPEN-05 - The tag's close name is guarded by an `assert`

**Where:** [lumiere_tag.dart:43-47](../../lib/src/components/tag/lumiere_tag.dart)
and the `closeSemanticLabel!` on line 125.

**What:** the constructor asserts `onClose == null || closeSemanticLabel != null`.
`assert` is compiled out of release builds, so a release build with `onClose` set and
no name throws a null-check error at build time instead of failing at construction
with a message that says what is missing.

`DS-CONST-09` requires the guard to be real in release builds too.

**Closing it:** keep the assert and add a release-safe fallback - an empty label
plus a `FlutterError` in debug, or require the name through an API that cannot be
omitted. A test that builds the widget in a release-equivalent configuration is the
guard.

---

## OPEN-06 - The tag label fails contrast, and the families are outside the contract

**Where:** [lumiere_tokens.dart:331-387](../../lib/src/tokens/lumiere_tokens.dart)
(the `tagColors` map), [lumiere_tag.dart:119](../../lib/src/components/tag/lumiere_tag.dart)
(the ink), and the absence of any tag row in the contrast table.

**What:** every family's ink is palette step 6 and its backgrounds are steps 1 and 2.
Measured contrast of the label:

| Family | Light, filled | Light, bordered | Dark, filled |
| --- | --- | --- | --- |
| neutral | 14.53 | 12.94 | 14.35 |
| romanticRed | 3.25 | 2.60 | 5.43 |
| wildGreen | 2.63 | 2.11 | 4.32 |
| blueTide | **2.04** | **1.73** | 6.11 |
| vitalityOrange | 2.41 | 2.08 | 6.55 |
| lateAutumnRed | 2.60 | 2.20 | 6.74 |
| dusk | **1.70** | **1.57** | 8.13 |
| youthPurple | 3.57 | 2.59 | 4.40 |
| magenta | 3.11 | 2.40 | 5.02 |
| ultimateBlue | 4.62 | 3.63 | 4.83 |
| seaBlue | 2.92 | 2.46 | 6.84 |

Normal text requires 4.5:1. Only `neutral` is compliant in both forms. On the soft
background nine of the eleven fail, `ultimateBlue` just clearing at 4.62; on the
strong background ten of the eleven fail, `neutral` alone passing. The dark theme is
the mirror image: two fail on the soft background (`wildGreen` 4.32, `youthPurple`
4.40) and seven on the strong one. So the bordered form is the worse of the two in
both themes, and no family is safe everywhere except `neutral`.

**Why open:** the fix is the design file's - the inks belong to it - and the
`onSubtle` mechanism that solved the same problem for the status families in 0.5.0
has no counterpart for the tag families. It stays open rather than hidden because
`contrast_test.dart` never reads `LumiereTagColor`, so nothing fails when the palette
moves.

**Closing it:** either the design declares a darker ink per family, or the token
layer derives one the way `onSubtle` derives the status ink. Either way the eleven
families MUST enter the contrast table, and the entry MUST be in the register.

---

## OPEN-07 - The token source is not in this repository

**Where:** [tokens.g.dart:1-10](../../lib/src/tokens/tokens.g.dart) declares
`Command: node design/tools/build-tokens.mjs` and
`GENERATED FILE - DO NOT EDIT BY HAND`; sixteen references across `lib/` and `test/`
point at `design/reference/`, `design/variables/`. The directory does not exist here.

**What:** the file that every colour in the package derives from cannot be
regenerated from a clone. The generator, the Figma export, the overrides file, the
geometry export and the accessibility contract all live elsewhere. Every claim of the
form "measured, 30 variants, zero variance" is therefore unverifiable in this
repository, and a new measurement cannot be applied without that other repository.

**Closing it:** commit the generator and the exported inputs under `design/`, or
state explicitly in `tokens.g.dart` and in `README.md` where they live and how to get
them. A CI check that regenerating produces no diff is the guard.

---

## OPEN-08 - Two goldens encode a theme that does not exist

**Where:** [lumiere_divider_golden_test.dart:68-74](../../test/golden/lumiere_divider_golden_test.dart)
and [lumiere_loading_golden_test.dart:52](../../test/golden/lumiere_loading_golden_test.dart).

**What:** both paint a second panel as `ColoredBox(LumiereColors.light.surfaceBase)`
inside a `MaterialApp` whose theme is dark. The components in that panel resolve dark
tokens on a white background. Measured in the divider baseline: the line is
`#A3A3A4`, which is the dark `border.2` (`#484849`) antialiased over white, not the
light `#E5E6EB`.

The checkbox, radio and switch goldens get this right by wrapping each panel in its
own `Theme`. These two verify a hybrid.

**Closing it:** wrap the panel in `Theme(data: LumiereThemeData.light())` and read
`surfaceBase` from that theme's tokens, then regenerate both baselines and review the
diff - the line colour must change.

---

## OPEN-09 - The focus ring is neither drawn everywhere nor measured anywhere

**Where:** [lumiere_button.dart](../../lib/src/components/button/lumiere_button.dart)
draws no ring at all; `_focusRingWidth = 2` and `_focusRingInset = 1` are declared
privately in the checkbox, the radio and the switch.

**What:** `DS-CONST-08` requires every focusable control to draw a 2 px ring at 3:1
inside the measured box. The button is a restyled `TextButton`: its only focus
indication is Material's overlay tint, which is not 2 px, is not inset, and is the
same mechanism as `OPEN-01`. No test asserts a ring's contrast against any surface
for any component, so the ring's colour can move below 3:1 in silence.

**Closing it:** draw the ring for the button the way the other three do, move the two
constants into `LumiereStrokes`, and add the ring pairs to the contrast contract. A
test that samples the ring pixel against `accent.normal`'s recorded ratio is the
guard.

---

## OPEN-10 - The open-exception safeguard is dead code

**Where:** [contrast_test.dart:695-730](../../test/accessibility/contrast_test.dart).

**What:** the test `the open exceptions are still failing with their recorded value`
iterates `_exceptions.where((e) => e.open)`. All three entries are `open: false`, so it
has never run a single assertion. The file's own header claims the property it does
not have.

The related cross-check that the register and the table cover the same combinations
*is* real and does work, which makes the gap harder to notice.

**Closing it:** register at least one genuinely open entry (the tag families are the
obvious candidate, `OPEN-06`) so the branch executes, or delete the branch and the
claim. A test that runs no assertion MUST NOT be described as a safeguard.

---

## OPEN-11 - Motion: no token, no reduced-motion support

**Where:** [lumiere_loading.dart:47-52](../../lib/src/components/loading/lumiere_loading.dart).

**What:** the indicator rotates on a 900 ms `repeat()` controller and never consults
`MediaQuery.disableAnimations`. A user who has asked their platform for reduced
motion gets a spinner that rotates forever anyway. There is also no motion token, so
the 900 ms is a placeholder that cannot be replaced by a declared value because none
exists.

**Closing it:** read `MediaQuery.of(context).disableAnimations` and hold the
indicator static (or fade it) when set; give the duration a token when the design
declares one.

---

## OPEN-12 - Named coverage gaps

Not a single defect, a list of things no test asserts. Each line is a test that
should fail when its behaviour breaks and currently cannot.

| Gap | Where it would live |
| --- | --- |
| `LumiereButton.isFullWidth` | `lumiere_button_test.dart` |
| Colour resolution per `kind` (danger, warning, success) in both themes | `lumiere_button_test.dart` |
| A tag with `filled: true` and `bordered: true` together | `lumiere_tag_test.dart` |
| `LumiereRadioGroup(groupValue: null)` - arrow keys with nothing selected | `lumiere_radio_test.dart` |
| Which side the divider's short line sits on for `start` and `end` | `lumiere_divider_test.dart` |
| A dashed vertical divider outside a golden | `lumiere_divider_test.dart` |
| `focusNode` adoption of an external node and disposal of an internal one | all three form controls |
| Right-to-left layout for any component | a new `test/directionality_test.dart` |
| Text scaling (`MediaQuery.textScaler`) at 1.5 and 2.0 | a new `test/text_scale_test.dart` |
| The `text` track content of the switch when disabled | `lumiere_switch_test.dart` |

The last two matter more than their size suggests: a design system used by several
applications will meet a 200 % text scale and an RTL locale before it meets anything
else on this list.

---

## OPEN-13 - One role, two incompatible purposes

**Where:** [tokens.g.dart:332-335](../../lib/src/tokens/tokens.g.dart) (dark
`fill.1..4` as white with alpha 10/20/31/41) versus
[tokens.g.dart:385-388](../../lib/src/tokens/tokens.g.dart) (light `fill.1..4` as
opaque `#F7F8FA`, `#F2F3F5`, `#E5E6EB`, `#C9CDD4`).

**What:** the semantic layer documents `fill.*` as "translucent overlays used for
hover and pressed states on neutral surfaces", and section 3.2 of the contract
measures text composited over them. In the light theme they are opaque surfaces, not
overlays. So the same four roles are a surface fill for a consumer and an overlay
tint for a component, and only one of those readings is true in each theme.

This is the root cause of `OPEN-01`: using `fillDefault` as an overlay tint is valid
in the dark theme and is a solid rectangle in the light one.

**Closing it:** separate the two concepts - a surface fill role and an overlay role,
each with its own alpha in both themes - or stop treating `fill.*` as an overlay and
give hover/pressed their own tokens.

---

## OPEN-14 - CI does not close the loop on the visual contract

**Where:** [ci.yml](../../.github/workflows/ci.yml), [pages.yml](../../.github/workflows/pages.yml).

**What:** three separate gaps.

1. Neither workflow pins Flutter: both use `channel: stable`, while the package
   requires `>=3.47.0`. An upstream change to Material's `TextButton`, or to
   `RawRadio`, can break the package on a day nobody changed this repository.
2. `pages.yml` has no `pull_request` trigger, so a change under `lib/` that breaks
   the gallery is discovered after the merge.
3. The goldens are excluded from every CI run. The visual contract is verified only
   when somebody on Windows runs the suite, which is also how `OPEN-08` survived.

**Closing it:** pin a Flutter version and bump it deliberately; trigger the Pages
workflow on pull requests (build only, no deploy); run the goldens on a pinned
Windows runner.

---

## OPEN-15 - No formatting gate

**Where:** the workflows; the repository has no `dart format` step.

**What:** `dart format --set-exit-if-changed` reports 48 of 60 Dart files as
differing from the current formatter, almost all because the formatter's tall style
arrived after the code was written. Nothing is unreadable, and CI is green, but the
first person to run `dart format .` will produce a diff that touches most of the
repository and mixes with whatever they were actually changing.

**Closing it:** one formatting commit that changes nothing else, then the gate.

---

## OPEN-16 - The switch's dartdoc contradicts its own measurement

**Where:** [lumiere_switch.dart:69](../../lib/src/components/switch/lumiere_switch.dart),
[:96-99](../../lib/src/components/switch/lumiere_switch.dart), and the class
dartdoc at [:236-237](../../lib/src/components/switch/lumiere_switch.dart).

**What:** the comment on `handleSizeSmall` says the small handle is 12 and records
that the upstream kit showed 10. Three other places still describe the small size as
"10 x 10", including the class-level dartdoc a consumer reads in the IDE.

**Closing it:** correct the three passages. The spec records the measured 12; the
code is right and the prose is wrong.

The same dartdoc also names the wrong pair in its contrast figures: it states that
`borderHeavy` "measures 3.11:1 against the page in the dark theme and 3.24:1 in the
light theme, and the same figures against the white handle". Against the page the
dark pair measures **5.75:1**; 3.11 is the white handle on `borderHeavy`. In the
light theme the two pairs coincide (3.24) only because the page and the handle are
both white, which is what makes the error easy to miss. Correcting it is part of
closing this entry: a figure that misattributes a pair is worse than a missing one,
because it looks measured.

---

## OPEN-17 - The divider's `none` alignment is an interpretation

**Where:** [lumiere_divider.dart:9-15](../../lib/src/components/divider/lumiere_divider.dart).

**What:** `align: none` is read as "the label without lines beside it". That is an
interpretation of a design axis the package cannot confirm, and it is recorded as
pending in the code rather than presented as certain. It is the only value of the
axis that draws no line.

**Closing it:** confirm the semantics against the design file, then either delete the
caveat or change the behaviour.

---

## OPEN-18 - The tag's filled/bordered pairing is an inference

**Where:** [lumiere_tag.dart:22-26](../../lib/src/components/tag/lumiere_tag.dart),
[lumiere_tag.dart:97](../../lib/src/components/tag/lumiere_tag.dart).

**What:** the design gives each colour two backgrounds and the variant counts split
evenly between the `filled` and `bordered` sets, so the package reads them as "filled
uses the soft background, bordered the strong one". Nothing in the design file states
it. The consequence a consumer meets: `bordered: true` alone keeps the soft
background, because `filled` defaults to true.

**Closing it:** confirm the pairing, and consider whether the two booleans should be
one three-valued axis, since `filled: false, bordered: false` is a third state with
no background at all.

---

## OPEN-19 - The version record does not reconstruct

**Where:** [pubspec.yaml:9](../../pubspec.yaml) says `0.6.0`;
[README.md:24](../../README.md) tells you to install `^0.2.0`; `git tag` lists
`v0.1.0` and `v0.2.0` only; `CHANGELOG.md` carries six versions.

**What:** four releases are untagged, the installation instructions pin a version
five releases old, and at least one shipped change - the light danger pair moving to
white - appears in no CHANGELOG section, because it landed between two version
commits. "Which commit is 0.5.0" is answerable only by reading prose.

**Closing it:** tag `v0.3.0` to `v0.6.0` at their CHANGELOG commits, fix the README
pin, and add the missing CHANGELOG line. A release checklist (`INT-018`) is the guard.

---

## OPEN-20 - The pub archive ships the golden baselines

**Where:** `.pubignore` excludes the gallery, the lockfile and the failure artefacts,
but not `test/golden/goldens/`.

**What:** the seven baselines are 65 KB of the 122 KB archive. A consumer of the
library has no use for them; they are a test fixture and they are already versioned
in the repository.

**Closing it:** one line in `.pubignore`. It also excludes `specs/`, for the same
reason.

---

## OPEN-21 - Four accessibility IDs exist only as citations

**Where:** [lumiere_button.dart:201-203](../../lib/src/components/button/lumiere_button.dart)
cites `AE-12` to `AE-15`; the register holds `AE-08` to `AE-11`.

**What:** the button states that its hover and pressed steps "stay as the design
declares them, which the register records as AE-12 to AE-15". No such entries exist
in [contrast_test.dart](../../test/accessibility/contrast_test.dart) or anywhere else.
The combinations they would cover are real and do need a decision: the primary
label on its hover fill measures 3.65 in the light theme and 4.34 in the dark one -
above 3:1 as a graphic indicator, below 4.5:1 as text.

**Closing it:** either add the four entries with their values and reasons, or remove
the citation and let the button's own colour table carry the decision.

---

## OPEN-22 - `AE-11` names two different entries

**Where:** the register entry `AE-11` (status inks, permanent, closed by the
`onSubtle` work in 0.5.0) versus its use in
[lumiere_tag.dart:28-31](../../lib/src/components/tag/lumiere_tag.dart),
[tag_page.dart:260](../../showcase/lib/src/pages/tag_page.dart) and CHANGELOG 0.4.0
(the tag label's open contrast failure).

**What:** one ID resolves to a closed design decision and to an open component
failure. A reader following the tag's citation arrives at an entry that says the
opposite of what the tag needs, and the real tag entry was never written.

**Closing it:** give the tag label its own ID and register it properly - it is the
same fix as `OPEN-06`, and it is blocked on the same design decision.

---

## OPEN-23 - Placeholders that no design value covers

**Where:** `LumiereStrokes.dash` and `.gap` (4 and 3), the loading indicator's
`size / 10` stroke ratio and its 900 ms duration, the tag's `mini` label size (12),
and the switch's icon sizes that fall back to a type or spacing step.

**What:** each of these is a value the design file does not declare. Each is
documented as pending or as a named fallback where it is defined, which satisfies half
of `DS-CONST-04`; none of them appeared in this register, which breaks the other half.
The consequence is that a reader cannot enumerate what is still provisional without
reading five component files, and "pending" becomes a word rather than a list.

`DS-CONST-04` requires an unmeasured value to name its source, name its fallback and
appear in this file. The first two are done. This entry is the third.

**Closing it:** either the design declares the values, or each one gets its own entry
with the alternative that was rejected. A generated table in the spec suite would be
better than prose: the register is only as good as someone's memory of it.

---

## OPEN-24 - The tag's close action is a 12 px target

**Where:** [lumiere_tag.dart:141-170](../../lib/src/components/tag/lumiere_tag.dart),
the `_CloseAction` widget; the claim it contradicts is in the class dartdoc at
[:136-140](../../lib/src/components/tag/lumiere_tag.dart).

**What:** the class documents the close action as carrying "its own tap target, which
is the full height of the tag: an icon-only control identifies itself, and the target
is never the size of the glyph". The widget tree is `Semantics > InkWell > Icon` inside
a `Row` that does not stretch its children, so the `InkWell` takes the size of the
`Icon` - `height * 0.5`, which is 12 x 12 in a 24 px tag and 16 x 16 in the largest
one. The glyph *is* the target, which is exactly what the dartdoc says it must not be.

The semantics are correct: the action has its own name and `button: true`. It is the
pointer target that is wrong, and it is smaller than the 24 x 24 interactive box the
package uses as its own standard for a control.

**Closing it:** wrap the icon in a `SizedBox` of the tag's height (or an
`IconButton`-equivalent hit area), and assert the measured target in a test rather than
trusting the dartdoc. The test is what would have caught this: the tag's behaviour
tests check the name, not the box.

---

## OPEN-25 - An icon on a primary button is drawn in the fill's own colour

**Where:** [lumiere_button.dart:276-278](../../lib/src/components/button/lumiere_button.dart),
`_content`: `iconColor` is `ramp.normal` when enabled, regardless of `type`.

**What:** the label of a `primary` button is `ramp.solidLabel` (white), because a fill
and its ink are a pair (`DS-CONST-11`). The icon takes `ramp.normal`, the *fill*
colour, and is drawn on top of `ramp.solidFill`. Measured:

| `kind` | Theme | Icon | Fill | Ratio |
| --- | --- | --- | --- | --- |
| standard | light | `#165DFF` | `#165DFF` | **1.00:1** |
| standard | dark | `#3C7EFF` | `#1D4DD2` | **1.85:1** |
| danger | light | `#F53F3F` | `#CB272D` | **1.46:1** |
| danger | dark | `#F76965` | `#F76965` | **1.00:1** |
| warning | light | `#FF7D00` | `#FF7D00` | **1.00:1** |
| warning | dark | `#FF9626` | `#FF9626` | **1.00:1** |
| success | light | `#00B42A` | `#00B42A` | **1.00:1** |
| success | dark | `#27C346` | `#27C346` | **1.00:1** |

A graphic needs 3:1. Six of the eight combinations are at 1.00:1 - not "low contrast"
but *no* contrast, the same colour drawn on itself - and the other two are below 2:1.

The visible consequence is worst in the `square` and `circle` shapes, where the icon is
the button's only content: an icon-only primary button in the light theme is a solid
blue rectangle with nothing in it.

Why nobody saw it, stated precisely because it is the point of this file: the committed
golden is a **dark** matrix, and the dark standard case is the 1.85:1 one, where the
glyph survives as a faint square at the end of the last row
(`test/golden/goldens/lumiere_button.png`). The 1.00:1 cases - light standard, warning
and success in both themes - have no baseline at all, because the button golden covers
one theme. And even the baseline that does exist failed nothing: a golden is a
fingerprint, not an audit, and nobody read the fingerprint.

**Why open:** nothing measures a resolved foreground against a resolved background for
this component, and the icon path is the one branch of `_content` the colour table in
[`button.md`](../02-components/button.md) did not enumerate.

**Closing it:** ink the icon in the same pair as the label - `solidLabel` for
`primary`, `ramp.normal` elsewhere - and add the assertion that fails today: the icon
colour of a primary button, in both themes, against its resolved fill.

---

## OPEN-26 - The family's weight axis does not fit Flutter's nine slots

**Where:** [`showcase/pubspec.yaml`](../../showcase/pubspec.yaml), the `fonts:` block;
`ArcoType.weights` in [`tokens.g.dart`](../../lib/src/tokens/tokens.g.dart).

**What:** Mark Pro is ten cuts - 250 Hairline, 275 Thin, 300 ExtraLight, 350 Light,
400 Regular, 450 Book, 500 Medium, 700 Bold, 800 Heavy, 900 Black - and a Flutter
manifest accepts only the nine hundred steps. Ten cuts must be pressed into nine
slots, and the binding chosen is a decision, not a measurement:

| Slot | Face | Its own weight |
| --- | --- | --- |
| 100 | Hairline | 250 |
| 200 | ExtraLight | 300 |
| 300 | Light | 350 |
| 400 | **Book** | 450 |
| 500 | Medium | 500 |
| 700 | Bold | 700 |
| 800 | Heavy | 800 |
| 900 | Black | 900 |

Two consequences, both live:

1. **There is no 600.** The scale declares `w600` at seven sizes and the theme uses it
   for every heading (`headlineSmall`, `titleLarge`, `titleMedium`). The family has no
   semibold, so those resolve upward to Bold and render a full step heavier than the
   previous family did. Nothing is synthesized; the gallery's `w600` and `w700`
   specimens are visually identical.
2. **400 is bound to Book (450), not to the face named Regular (400).** Book is the
   family's reading weight, and the `400` slot is what body text lands on. The face
   named Regular is lighter than Book, so binding it there would make body text
   lighter than the previous family's. `MarkPro.otf` and `MarkPro-Thin.otf` ship in
   `showcase/fonts/MarkPro/` but are declared nowhere.

A third, quieter divergence is worth knowing: `FontLoader`, which the gallery's tests
use, cannot assign a weight - the engine reads each face's own `OS/2` value - so the
test path and the manifest path agree at 400, 500 and 700 only because the test loader
deliberately omits `MarkPro.otf`. At 200 and 300 they differ by one slot. The scale
never reaches those weights.

**Closing it:** the design decides. Either the type scale stops asking for 600 (map
headings to 700 explicitly and delete the `w600` rows, which makes the heavier headings
a stated intention rather than a side effect), or a semibold is added to the family, or
the 400 binding is flipped to `Regular`. Any of the three is a one-line change plus a
regenerated baseline; none of them is a measurement.

---

## OPEN-27 - The line heights were not re-measured for the new family

**Where:** `ArcoType.lineHeight10` to `lineHeight56` in
[`tokens.g.dart`](../../lib/src/tokens/tokens.g.dart) and `ArcoType.lineHeightFor`.

**What:** the scale pairs each size with an absolute line height - 10/18, 12/20, 13/22,
14/22, 16/24, 20/28, 24/32, 36/44, 48/56, 56/64 - and those ratios are not constant:
1.80 at the smallest size, 1.57 at 14, 1.14 at 56. They were measured against the
family the design used when they were recorded. Mark Pro asks for 1.268 em of leading
of its own (hhea 2028/-507 over a 2000 unit em, `USE_TYPO_METRICS` set), which sits
inside that range, so nothing clips at the sizes the components use - but at 48 and 56
the declared leading is tighter than the font's own, and the family's descender reaches
0.2535 em, so the tightest steps are the ones to re-check with real strings rather than
with the specimen line.

The family changed and the vertical rhythm did not, which means the pairing is now an
assumption rather than a measurement. That is exactly what `DS-CONST-04` exists to
prevent, hence this entry.

**Closing it:** measure the leading the design wants against the new family - a
`lineHeightNN` per size, confirmed by a designer on wrapped paragraphs at 4x zoom - and
update the scale, the golden, and the `## Status` of
[`typography.md`](../01-foundations/typography.md).
