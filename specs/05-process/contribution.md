# 05 - Contribution

What a change to `lumiere_ui` MUST satisfy before it is reviewed. The six steps are
the ones [`README.md`](../../README.md) declares and the history has followed since
0.1.0; the obligations after them are what [`specs/`](../README.md) adds. Where a
step and a rule disagree, the rule is what a reviewer cites.

## The six steps

| # | Required | Rule |
| --- | --- | --- |
| 1 | Confirm the component exists in the design file and list its axes and options | `PRC-001` |
| 2 | Create `lib/src/components/<name>/<name>.dart` from semantic roles and scales only | `PRC-002` |
| 3 | Cover every state, make focus visible, guarantee keyboard operation and an accessible name | `PRC-003` |
| 4 | Export it from the barrel with an explicit `show` list | `PRC-004` |
| 5 | Add behaviour tests and a golden per variant and state | `PRC-005` |
| 6 | Register it in the gallery catalog | `PRC-006` |

A new component MUST pass all six in one pull request. A change to an existing
component MUST repeat the steps its change touches: a change to what it paints
repeats 3 and 5, a change to its constructor repeats 1, 2 and 3.

### PRC-001 - Axes come from the design file

The pull request MUST name the component set in the Figma file and list every axis
and its options in the order the file declares them. A component that is not in the
file MUST NOT be added.

Where the contract cannot be read, the API MUST be marked provisional in three
places: the class dartdoc, the `Status` line of `02-components/<name>.md`, and a
`CalloutTone.warning` on the gallery page. Provisional is a state, not a synonym for
unfinished.

The `state` axis is not an axis of the API: it is resolved from the widget's own
state ([ADR-0002](../06-decisions/adr-0002-state-as-widget-state.md)).

### PRC-002 - A component holds no visual literal

The file lives at `lib/src/components/<name>/<name>.dart`, one directory per
component, and reads colour from `LumiereColors` or `LumiereStatusColors`, geometry
from the `Arco*` scales and line weight from `LumiereStrokes`. It MUST NOT reference
`ArcoPalette*` or `ArcoSemantic*` (`DS-CONST-03`), MUST NOT write a colour, size,
duration or opacity as a literal (`DS-CONST-02`), and MUST NOT take a height from
Material (`DS-CONST-10`).

A literal that cannot be avoided is a recorded exception: it is named as such in the
dartdoc, and the spec and the traceability file say why.

### PRC-003 - The component carries its own accessibility

Every declared state MUST be implemented and reachable through real input: default,
hover, focus, active and disabled, plus `loading` where the design declares it.
Focus MUST be drawn inside the measured interactive box and MUST NOT enlarge the
layout (`DS-CONST-08`). Keyboard operation MUST be complete without a pointer. The
accessible name MUST be derivable by the component or required in its constructor;
it MUST NOT be delegated to a `Semantics` wrapper the caller supplies
(`DS-CONST-06`). A guard that rejects a missing name MUST fail in release builds,
not only in an `assert` (`DS-CONST-09`).

### PRC-004 - One entry point, explicit exports

The component MUST be exported from [`lib/lumiere_ui.dart`](../../lib/lumiere_ui.dart),
which stays a single library (`DS-CONST-01`). The export line MUST be added in the same
pull request and MUST make the published surface visible: the token layer is exported
with a `show` list, and a component file that publishes more than the component - its
painter, a helper type - names that extra surface in the dartdoc, because adding a
class to an exported file publishes it. Nothing under `lib/src/` becomes importable any
other way.

### PRC-005 - A test and a baseline per variant and state

The behaviour file is `test/lumiere_<name>_test.dart` and MUST cover every axis
value, both themes where colour is resolved, the semantics tree, disabled behaviour
and keyboard operation. The golden is
`test/golden/lumiere_<name>_golden_test.dart`, tagged `golden`, and MUST lay out
every variant and state in one labelled matrix per component; "a golden per variant
and state" means coverage of each combination in the baseline, not one image per
combination.

Goldens are produced on Windows only. See
[`verification.md`](verification.md) before regenerating one.

### PRC-006 - The gallery registers the component

A page at `showcase/lib/src/pages/<name>_page.dart` and one entry in
[`showcase/lib/src/catalog.dart`](../../showcase/lib/src/catalog.dart). That list
drives the sidebar, the overview cards and the coverage test, so an unregistered page
is invisible. The entry carries the `ruleId` of the rule the page documents, where one
exists, and the page says what is provisional.

## The obligations beyond the six

| Required | Rule |
| --- | --- |
| A spec, an ID, a rules row, a CHANGELOG entry, a migration guide when breaking | `PRC-007` |
| A cited measurement for every value, and an open item for every unmeasured one | `PRC-008` |

### PRC-007 - A component is documented before it is merged

The same pull request MUST add `02-components/<name>.md` from
[`_template.md`](../02-components/_template.md), allocate a `DS-COMP-nnn` in the
table of [`specs/README.md`](../README.md), add the row to the axis matrix of
[`02-components/README.md`](../02-components/README.md), add the rule row to
[`07-traceability/rules.md`](../07-traceability/rules.md), and write the CHANGELOG
entry. `DS-COMP-nnn` numbers are allocated in publication order and never reused.

A breaking change MUST also carry an entry in
[`04-integration/migration.md`](../04-integration/migration.md) that names the old
call and its replacement, which is part of the record
[`04-integration/versioning.md`](../04-integration/versioning.md) requires of every
release. The CHANGELOG keeps the repository's Keep a Changelog form: `Added`,
`Changed (breaking)`, `Removed`, `Notes`, in that order, one section per version.

### PRC-008 - Every value is a measurement or says it is not

A change to an existing value MUST cite the new measurement: the artifact, the date
and the sample. "Measured in the project file" without a date is not a citation. A
value that has not been measured MUST say so, MUST name the token it falls back to,
and MUST appear in [`07-traceability/open-items.md`](../07-traceability/open-items.md)
(`DS-CONST-04`).

### PRC-009 - Commits

Conventional Commits, as the history uses them: `feat`, `fix`, `docs`, `chore`, with
`!` for a breaking change (`feat!:`). One change per commit, imperative lower-case
subject that describes the effect rather than the file, no scope. The body carries
the reason when the subject cannot. A release landing names its version in
parentheses at the end of the subject (`feat: ..., and the corrections the
measurements forced (0.6.0)`).

A commit marked `!` MUST carry a `Changed (breaking)` CHANGELOG entry in the same
pull request. The history is 15 commits from one author; the conventions above are
what it actually does, not a template applied to it.

### PRC-010 - Pull requests

One component or one rule per pull request. The description MUST name the rule IDs it
satisfies, the measurement behind any value it changes, and the gates it ran and did
not run. A pull request MUST NOT claim a gate it did not execute: the seven goldens
cannot be claimed by anyone who did not run them on the reference operating system
(see [`verification.md`](verification.md)).

## Status

The six steps and the two obligations describe what 0.6.0 did; they are enforced by
reading the diff, not by a test. Three of them cannot be completed as written today.
A contribution that needs a new token cannot regenerate the generated layer from this
repository (**OPEN-07**). Formatting is not gated, so a diff that is not
`dart format` clean is caught by a reader or not at all (**OPEN-15**). A release
cannot be documented consistently, because the installation snippet pins `^0.2.0`
while the package is `0.6.0` and only `v0.1.0` and `v0.2.0` are tagged (**OPEN-19**).

## Open items

- **OPEN-07** - `design/` and `node design/tools/build-tokens.mjs` do not exist here, so no contribution can regenerate the token layer; 16 code references point into that tree.
- **OPEN-15** - there is no `dart format` gate, and 48 of 60 files differ from the current formatter; `PRC-002` says nothing about layout and no rule may require a reformat.
- **OPEN-19** - installation documentation pins `^0.2.0` against a `0.6.0` package, and the tag list stops at `v0.2.0`.
