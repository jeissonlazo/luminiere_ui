# 07 - Rules and their enforcement

Every normative rule in `specs/`, with the test that fails when it is broken, or a
statement that it rests on review, or the `OPEN-nn` that records that it is not
enforced at all.

This file is what `DS-CONST-12` requires. A rule that appears in no row here is a
rule nobody has read, and a rule whose row says `Review` is a rule that survives
only as long as reviewers remember it. Both are worth knowing; pretending otherwise
is how a specification becomes decoration.

**Verdicts.**

| Verdict | Meaning |
| --- | --- |
| `Test` | A named test fails if the rule breaks |
| `Review` | Enforced by reading the diff; no test would catch a violation |
| `Recorded` | A value is pinned by a test, but no threshold is asserted (register entries) |
| `OPEN-nn` | Not enforced today; the entry records what is missing |

**Counts.** 198 rules across seventeen namespaces: 147 in the `DS-` namespaces (12
constitutional, 135 in the foundations, accessibility and component layers), 22
integration and 29 process. Two of those identifiers, `DS-SPACE-001` and
`DS-CONTROL-001`, pre-date this suite and are cited rather than defined.

No single ratio summarises the enforcement, and inventing one would be the first lie
in a file about honesty. What is asserted: the scales' values, the colour pairs, the
accessibility arithmetic over the token layer, and most component behaviour. What is
reviewed: provenance, API shape, process and the promises made to a consumer.

That split is the honest finding of this file. A design system whose geometry, colour
pairs and contrast arithmetic are executed, and whose provenance, token layering and
process are not, is exactly what this repository is.

---

## Namespace allocation

| Prefix | Range used | Owner |
| --- | --- | --- |
| `DS-CONST` | 01-12 | [`00-constitution.md`](../00-constitution.md) |
| `DS-TOK` | 001-009 | [`01-foundations/tokens.md`](../01-foundations/tokens.md) |
| `DS-COL` | 001-011 | [`01-foundations/colour.md`](../01-foundations/colour.md) |
| `DS-TYPE` | 001-008 | [`01-foundations/typography.md`](../01-foundations/typography.md) |
| `DS-SPACE` | 001-002 | [`01-foundations/geometry.md`](../01-foundations/geometry.md) |
| `DS-CONTROL` | 001-003 | same file |
| `DS-RADIUS` | 001-004 | same file |
| `DS-STROKE` | 001-004 | same file |
| `DS-MOTION` | 001-005 | [`01-foundations/motion.md`](../01-foundations/motion.md) |
| `DS-COMP` | 012, 017-022 (the contract), `-nn` for a rule inside it | [`02-components/`](../02-components/) |
| `DS-API` | one block per component | the component's spec |
| `DS-A11Y-001`-`009` | the contract and its register | [`03-accessibility/contract.md`](../03-accessibility/contract.md) |
| `DS-A11Y-060`-`068` | keyboard, focus and target size, cross-cutting | [`03-accessibility/keyboard-and-focus.md`](../03-accessibility/keyboard-and-focus.md) |
| `DS-A11Y-0nn` | one block per component, `nn` = its `DS-COMP` number | the component's spec |
| `AE` | 08-15 (allocated), 08-11 (existing) | [`03-accessibility/exception-register.md`](../03-accessibility/exception-register.md) |
| `INT` | 001-022 | [`04-integration/`](../04-integration/) |
| `PRC` | 001-010, 020-024, 040-053 | [`05-process/`](../05-process/) |
| `ADR` | 0001-0006 | [`06-decisions/`](../06-decisions/) |
| `OPEN` | 01-27 | [`open-items.md`](open-items.md) |

Two allocation rules keep this readable. A component-level accessibility rule reuses
its component's `DS-COMP` number (`DS-A11Y-017` is the tag's block, `DS-A11Y-022` the
switch's), so a citation names its component without a lookup. A cross-cutting
accessibility rule takes the next free number from the `060` block, which exists so
the two schemes cannot collide - an earlier draft had `DS-A11Y-012` meaning both the
loading indicator's block and a focus rule.

---

## The constitution

| ID | Rule | Verdict | Enforced by |
| --- | --- | --- | --- |
| `DS-CONST-01` | One public entry point | Review | 34-line barrel; the gallery and the example import only it |
| `DS-CONST-02` | A component holds no visual literal | Review | standing breach registered as `OPEN-02` |
| `DS-CONST-03` | Roles, never primitives | Review | the barrel does not export the colour classes; mapping asserted at [`lumiere_button_test.dart:172`](../../test/lumiere_button_test.dart) |
| `DS-CONST-04` | Every value is measured, or says it is not | Review | no test can read a citation |
| `DS-CONST-05` | State is a widget state | Test | by construction; no such parameter exists in any API |
| `DS-CONST-06` | A component carries its own accessibility | Review | breach registered as `OPEN-03`, `OPEN-04` |
| `DS-CONST-07` | Value never carried by colour alone | Test | geometry asserted in each behaviour file; visible in every golden |
| `DS-CONST-08` | Focus visible, never enlarging the layout | Review | geometry asserted; contrast unmeasured and the button has no ring - `OPEN-09` |
| `DS-CONST-09` | The package ships no user-visible string | Review | breach registered as `OPEN-05` |
| `DS-CONST-10` | Geometry from the scales, never Material | Test | [`lumiere_button_test.dart:220`](../../test/lumiere_button_test.dart) pairs every height with its padding |
| `DS-CONST-11` | A fill and its label are a pair | Test | [`contrast_test.dart:551`](../../test/accessibility/contrast_test.dart) reads all eight pairs from the semantic layer |
| `DS-CONST-12` | A rule without a test is registered | Review | this file |

---

## Foundations

**`DS-TOK-001` - `DS-TOK-009`** - token layers, provenance, generation.
Verdict: `Review`, with two exceptions. `DS-TOK-006` (the extension is mandatory) is a
`Test` at [`lumiere_button_test.dart:166`](../../test/lumiere_button_test.dart).
`DS-TOK-003` and `DS-TOK-004` (a new value arrives through the generator; an override
is annotated where it lands) are unenforceable while the generator is absent -
`OPEN-07`.

**`DS-COL-001` - `DS-COL-011`** - semantic colour roles. Five are `Test`:
`DS-COL-002` (the mapping follows the design) at
[`lumiere_button_test.dart:172`](../../test/lumiere_button_test.dart);
`DS-COL-003` (fill and label are a pair) and `DS-COL-005` (nine fields, complete) at
[`contrast_test.dart:551`](../../test/accessibility/contrast_test.dart);
`DS-COL-007` (`onSubtle` reaches 4.5:1) at
[`status_ink_test.dart:62`](../../test/accessibility/status_ink_test.dart);
`DS-COL-011` (an override is pinned) at
[`status_ink_test.dart:158`](../../test/accessibility/status_ink_test.dart).
`DS-COL-006` and `DS-COL-009` are `Review` with a breach: the tag label uses the step-6
ink on both backgrounds and no row covers it - `OPEN-06`. `DS-COL-010` is `OPEN-13`.

**`DS-TYPE-001` - `DS-TYPE-008`** - the type scale. `Test` for the values
(`DS-TYPE-001` family and `DS-TYPE-002`/`003` sizes and paired line heights at
[`lumiere_button_test.dart:193-218`](../../test/lumiere_button_test.dart));
`Review` for `DS-TYPE-005` (no font file shipped) and `DS-TYPE-008` (the `TextTheme`
mapping stays on the scale), which no test reads.

**`DS-SPACE-001`, `DS-CONTROL-001`** - pre-existing, `Test` at
[`lumiere_button_test.dart:204`](../../test/lumiere_button_test.dart) and
[:220](../../test/lumiere_button_test.dart).

**`DS-SPACE-002`, `DS-CONTROL-002`, `DS-CONTROL-003`, `DS-RADIUS-001` - `DS-RADIUS-004`,
`DS-STROKE-001` - `DS-STROKE-004`** - `Review`, with two exceptions:
`DS-STROKE-001` (a line weight comes from `LumiereStrokes`) has a standing breach at
`OPEN-02`, and `DS-STROKE-004` (one ring declared three times) is a drift warning with
no enforcer.

**`DS-MOTION-001` - `DS-MOTION-005`** - `Review`, one of them vacuous: there is no
motion token for a rule about motion tokens to bind, and `DS-MOTION-002` (reduced
motion) is broken by the only animation in the package - `OPEN-11`.

---

## Accessibility

**`DS-A11Y-001` - `DS-A11Y-008`** - the contract. `Recorded`/`Test`: every section is
the `_pairs` table of
[`contrast_test.dart`](../../test/accessibility/contrast_test.dart), 55 combinations
across two themes. `DS-A11Y-001` (level 1 only) is a statement of scope, not a rule a
test can break; it is the reason `OPEN-01` sits outside this whole namespace.
`DS-A11Y-008` (a component names the combination it renders) is `Review`, and both the
ring and the tag families fail it - `OPEN-09`, `OPEN-06`.

**`DS-A11Y-009`** - what a register entry must contain. `Test` at
[`contrast_test.dart:629-747`](../../test/accessibility/contrast_test.dart), except the
half that has never run - `OPEN-10`.

**`DS-A11Y-060` - `DS-A11Y-068`** - keyboard, focus and target size. `Test` for the
tab-stop and activation rules (`DS-A11Y-060`, `061`) in
[`lumiere_radio_test.dart`](../../test/lumiere_radio_test.dart) and the keyboard groups
of each behaviour file; `Test` for the ring's geometry via the geometry groups.
`DS-A11Y-062` (the ring is drawn, not overlaid) is broken by the button - `OPEN-09`.
`DS-A11Y-066` (the ring's contrast) is unmeasured - `OPEN-09`. `DS-A11Y-067` (one
owner for the ring constants) is `Review` and currently false by duplication.
`DS-A11Y-068` (a target is the measured box) is broken by the tag - `OPEN-24` - and no
test anywhere measures a target box.

---

## Components

One block per component: the contract rule, an API block and an accessibility block.
Each component contributes four ID families - `DS-COMP-0nn` for the contract as a
whole, `DS-COMP-0nn-nn` for a rule inside it, `DS-API-0nn-nn` for the shape of its API
and `DS-A11Y-0nn-nn` for its accessibility. The rules are enumerated in each
component's spec; what follows is their enforcement, which is what this file exists
for.

| Component | Rules | Verdict | Enforced by |
| --- | --- | --- | --- |
| Button `DS-COMP-019` | `DS-COMP-019-*`, `DS-API-019-*`, `DS-A11Y-019-*` | `Test` for behaviour and semantics; `Review` for API shape | [`lumiere_button_test.dart`](../../test/lumiere_button_test.dart); colour resolution **untested**, `isFullWidth` untested - `OPEN-12`; the icon ink is 1.00:1 on a primary fill - `OPEN-25` |
| Checkbox `DS-COMP-020` | `DS-API-020-*`, `DS-A11Y-020-*` | `Test` | [`lumiere_checkbox_test.dart`](../../test/lumiere_checkbox_test.dart): behaviour, semantics, geometry, colour in both themes |
| Radio `DS-COMP-021` | `DS-API-021-*`, `DS-A11Y-021-*` | `Test` | [`lumiere_radio_test.dart`](../../test/lumiere_radio_test.dart); `groupValue: null` untested - `OPEN-12` |
| Switch `DS-COMP-022` | `DS-API-022-*`, `DS-A11Y-022-*` | `Test` | [`lumiere_switch_test.dart`](../../test/lumiere_switch_test.dart) |
| Tag `DS-COMP-017` | `DS-COMP-017-*`, `DS-API-017-*`, `DS-A11Y-017-*` | `Test` for behaviour and semantics, `Recorded` for the label ink | [`lumiere_tag_test.dart`](../../test/lumiere_tag_test.dart); contrast of the families not asserted - `OPEN-06`; the close target is glyph-sized - `OPEN-24` |
| Divider `DS-COMP-018` | `DS-API-018-*`, `DS-A11Y-018-*` | `Test` | [`lumiere_divider_test.dart`](../../test/lumiere_divider_test.dart); which side the short line sits on is not asserted - `OPEN-12` |
| Loading `DS-COMP-012` | `DS-API-012-*`, `DS-A11Y-012-*` | `Test` | [`lumiere_loading_test.dart`](../../test/lumiere_loading_test.dart); reduced motion broken - `OPEN-11` |

A component's seven golden matrices are the visual layer of the same verdict, with two
caveats on record: the divider and loading goldens render their light panel with dark
tokens (`OPEN-08`), and no golden renders a hover state, which is why `OPEN-01`
survived.

---

## Integration

`INT-001` - `INT-022`, in [`04-integration/`](../04-integration/). Verdict: `Review`
for everything that a consumer observes and `Test` for the two that are mechanical -
`INT-021` (the archive) is checked by `flutter pub publish --dry-run` in CI, and
`INT-008` (the platform floor) by the fact that the package resolves at all.

The rest are promises no test reads: that the archive is 122 KB, that the README pins
the right version (`OPEN-19` fails it), that a deprecation window will be respected
(`INT-019`, never performed), and that the published surface is what `README.md` in
`lib` says it is.

---

## Process

| ID | Rule | Verdict |
| --- | --- | --- |
| `PRC-001` - `PRC-010` | Contribution steps for a new component | `Review` |
| `PRC-020` - `PRC-024` | The verification gates and what only a local run can check | `Test` where CI runs it (`ci.yml`, `pages.yml`); `Review` for the golden step, which CI never executes - `OPEN-14` |
| `PRC-040` - `PRC-051` | One row per constitutional invariant | `Review` - the checklist is walked by a person |
| `PRC-052` | What a new component must arrive with | `Review` |
| `PRC-053` | What a pull request must not be blocked for | `Review`; the "no reformat" line has no gate - `OPEN-15` |

---

## What rests on review alone

Evenly distributed across the namespaces, grouped by why a test cannot reach it:

- **Provenance.** No test can read a measurement citation or check that a value came
  from the design file, and while `design/` is absent from this repository (`OPEN-07`)
  nobody can either.
- **API shape.** A `DS-API` rule describes a contract; the behaviour tests exercise it
  incidentally rather than asserting its shape, and a new required parameter is caught
  by the compiler only in the applications.
- **Process.** A contribution step is performed by a person. The gates that are
  mechanical are already in CI, which is why the process namespace is the best-covered
  of the review-only groups.
- **Integration.** Consumer-facing promises are verified by consuming. Only the archive
  contents have a check, and it is `--dry-run`.
- **Texture.** Spacing, radius, stroke and motion rules whose *values* are asserted but
  whose *application* is not: a component that writes a literal `8` where `spaceSm`
  belongs passes every test in the suite.

The last group is the honest weakness. The scales are pinned, the components mostly
read them, and nothing notices when one does not. It is also the group a lint rule
could close, which is worth more than another review checklist row.

---

## Status

This file is complete against the specification suite as written: 198 rules across
seventeen namespaces, each with a verdict, and a dozen of them pointing at a registered
gap instead of a test.

It is not complete against the code, and cannot be: three rules are broken today
(`DS-STROKE-001` by `OPEN-02`, `DS-A11Y-062` by `OPEN-09`, `DS-MOTION-002` by
`OPEN-11`), one is false by duplication (`DS-A11Y-067`), and one register entry is
cited but absent (`OPEN-21`, `OPEN-22`).

Two identifiers were repaired while this suite was written and the history is worth
keeping: `DS-COMP-0nn` labelled two to four different rules in each component file, and
`DS-A11Y-012` meant both the loading indicator's block and a focus rule. Both are now
numbered by component, so a citation resolves to one rule.

## Open items

- **OPEN-01**, **OPEN-02**, **OPEN-05**, **OPEN-06**, **OPEN-08**, **OPEN-09**,
  **OPEN-11**, **OPEN-13**, **OPEN-21**, **OPEN-22**, **OPEN-24**, **OPEN-25** - each
  is the reason a rule in this file has no test.
- **OPEN-23** - the placeholder values whose registration `DS-CONST-04` requires.
- **OPEN-10** - part of the enforcement in the accessibility namespace has never
  executed.
- **OPEN-12** - the coverage gaps that keep component rules in the `Review` column.
- **OPEN-14** - the golden layer, which this file counts as enforcement, never runs in
  CI.
