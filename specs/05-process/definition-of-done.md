# 05 - Definition of done

The checklist a reviewer walks. It is organised by the twelve invariants of
[`00-constitution.md`](../00-constitution.md), because a pull request either breaks
one or does not, and answering that is what review is for. The last two blocks say
what a new component needs on top, and what a pull request deliberately does not
need.

## The twelve invariants

| Invariant | The reviewer looks for | Proof |
| --- | --- | --- |
| `PRC-040` `DS-CONST-01` One public entry point | one line added to the barrel, naming what it exports; no `lib/src/` import in `showcase/` or `example/` | review; [`lib/lumiere_ui.dart`](../../lib/lumiere_ui.dart) is 34 lines |
| `PRC-041` `DS-CONST-02` No visual literal | every colour, size, duration and opacity resolves to a token | review; the dashed button painter keeps its own `4 / 3 / 1` as the recorded exception |
| `PRC-042` `DS-CONST-03` Roles, never primitives | no `ArcoPalette*` or `ArcoSemantic*` anywhere in the diff | review, and the barrel does not export them |
| `PRC-043` `DS-CONST-04` Measurement | a date and an artifact behind every changed value; a pending marker and an open item behind every unmeasured one | review |
| `PRC-044` `DS-CONST-05` State is widget state | no `hovered`, `pressed`, `focused` or `disabled` parameter a component paints from; `loading` is the only property | by construction; the hover cases in `test/lumiere_<name>_test.dart` |
| `PRC-045` `DS-CONST-06` Own accessibility | role, name, state, activation and focus all inside the component; a missing name fails loudly in release, not in an `assert` | the `semantics` and `keyboard` groups of each behaviour file |
| `PRC-046` `DS-CONST-07` Never colour alone | a tick, a dash, a dot or a moved handle carries the value; colour only decorates it | geometry asserted in the behaviour tests, visible in the goldens |
| `PRC-047` `DS-CONST-08` Focus | a ring of at least 2 logical pixels, drawn inside the measured box, no layout shift on focus | the geometry tests measure the ring; no ring's contrast is asserted, and the button draws none |
| `PRC-048` `DS-CONST-09` No user-visible string | not one word a user reads; no guard that only an `assert` carries | review |
| `PRC-049` `DS-CONST-10` Geometry from the scales | heights and paddings from `ArcoControl`, spacing from `ArcoSpace`, radii from `ArcoRadius`; `visualDensity` left alone and `tapTargetSize` set explicitly | review; the theme sets neither density nor target size |
| `PRC-050` `DS-CONST-11` Fill and ink are a pair | both sides of a solid surface come from one `solidFill`/`solidLabel` pair of one family | [`contrast_test.dart`](../../test/accessibility/contrast_test.dart): 4.5:1 across eight pairs in both themes |
| `PRC-051` `DS-CONST-12` Traceability | every new rule ID has a row in [`07-traceability/rules.md`](../07-traceability/rules.md) with a test or an open item beside it | review of that file |

A row that cannot be satisfied is a blocking review comment, whatever else the pull
request fixes. A `SHOULD` the request overrides MUST say so, and, if the override
outlives the request, MUST become an ADR in
[`06-decisions/`](../06-decisions/README.md).

## A new component

`PRC-052` - All of the following, in the same pull request:

- `02-components/<name>.md` from [`_template.md`](../02-components/_template.md), with a `Status` line that names what is unmeasured.
- A `DS-COMP-nnn` allocated in the table of [`specs/README.md`](../README.md), and its row in the axis matrix of [`02-components/README.md`](../02-components/README.md).
- One baseline in `test/golden/goldens/` laying out every variant and state in a labelled matrix, plus the behaviour tests that assert each state without pixels.
- A page under `showcase/lib/src/pages/` and an entry in [`catalog.dart`](../../showcase/lib/src/catalog.dart), carrying the `ruleId` and a warning callout for anything provisional.
- A CHANGELOG entry under `Added`, and under `Changed (breaking)` with an entry in [`04-integration/migration.md`](../04-integration/migration.md) if an existing call changes shape.
- A row per new rule ID in [`07-traceability/rules.md`](../07-traceability/rules.md), each pointing at a test or at an `OPEN-nn`.
- The six steps of [`contribution.md`](contribution.md) satisfied in order, with the measurement cited where a value is new.

## Not required

`PRC-053` - A pull request MUST NOT be blocked for any of these, and a reviewer who
asks for one is adding ceremony to the checklist rather than completing it:

- An ADR. A decision that does not outlive the pull request, has no cost worth
  questioning, and discards no option a future maintainer would reach for belongs in
  the pull request description.
- A screenshot or a link to the gallery. The gallery is the screenshot; it is
  generated from the same code.
- A CHANGELOG entry for a `docs:` or `chore:` change. Only what a consumer can observe
  is recorded there.
- A version bump in `pubspec.yaml`. The version moves in the release commit, next to
  the version in the CHANGELOG heading.
- A reformat of files the change does not otherwise touch. There is no
  `dart format` gate (**OPEN-15**), and a whitespace-only diff hides the change that
  matters.
- A new test for a rule that already has one, or coverage figures. There is no
  coverage gate and no coverage target.
- A `showcase/` golden regeneration unless a gallery page changed.

## Status

Seven of the twelve are enforced by reading the diff (`DS-CONST-01`, `02`, `03`, `04`,
`06`, `09`, `12`), four by a test (`05`, `07`, `10`, `11`) and one partly (`08`: the
ring is measured, no contrast is asserted, and the button draws none). The checklist
therefore leans on review for more than half of its rows, and one of the rows that
appears enforced by a test is not: the accessibility test that requires open exceptions
to keep failing iterates an empty set, because all three register entries are permanent
(**OPEN-10**). The list is honest about that rather than counting rows.

## Open items

- **OPEN-10** - the accessibility safeguard test iterates an empty set; `PRC-045` and `PRC-047` rest on review alone until a fourth, non-permanent register entry exists.
- **OPEN-15** - no `dart format` gate, so the "no reformat" line of `PRC-053` is a convention with no enforcer.

