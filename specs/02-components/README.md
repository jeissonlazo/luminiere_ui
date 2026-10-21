# 02 - Components

One file per component, in the shape [`_template.md`](_template.md) fixes. A file
that departs from that shape is rejected on the diff, before its content is read.

The twelve invariants of [`00-constitution.md`](../00-constitution.md) apply here
without being restated. A component that breaks one names the `OPEN-nn` entry that
records the breach, and a rule that is neither asserted nor registered is a defect
of this directory, not of the component.

## Allocation

`DS-COMP-nnn` is allocated in publication order and never reused. The number
belongs to the contract, not to the file: a component that is renamed keeps its
number.

| ID | Component | Spec | Public source |
| --- | --- | --- | --- |
| `DS-COMP-012` | Loading | [`loading.md`](loading.md) | [`lumiere_loading.dart`](../../lib/src/components/loading/lumiere_loading.dart) |
| `DS-COMP-017` | Tag | [`tag.md`](tag.md) | [`lumiere_tag.dart`](../../lib/src/components/tag/lumiere_tag.dart) |
| `DS-COMP-018` | Divider | [`divider.md`](divider.md) | [`lumiere_divider.dart`](../../lib/src/components/divider/lumiere_divider.dart) |
| `DS-COMP-019` | Button | [`button.md`](button.md) | [`lumiere_button.dart`](../../lib/src/components/button/lumiere_button.dart) |
| `DS-COMP-020` | Checkbox | [`checkbox.md`](checkbox.md) | [`lumiere_checkbox.dart`](../../lib/src/components/checkbox/lumiere_checkbox.dart) |
| `DS-COMP-021` | Radio and radio group | [`radio.md`](radio.md) | [`lumiere_radio.dart`](../../lib/src/components/radio/lumiere_radio.dart) |
| `DS-COMP-022` | Switch | [`switch.md`](switch.md) | [`lumiere_switch.dart`](../../lib/src/components/switch/lumiere_switch.dart) |

`LumiereLoading` also carries `DS-COMP-012` in its own dartdoc; the number is
cited by the code and is preserved as-is.

## Axis matrix

The values below are the options each widget declares. `—` means the design file
declares no such axis, not that the value is missing from the table. A cell that
names a parameter instead of a list is an axis with a single dimension.

| Component | `type` | `kind` | `shape` | `size` | State | Other axes |
| --- | --- | --- | --- | --- | --- | --- |
| Loading `012` | — | — | — | — (no axis; `size` is a parameter the button sets) | — | — |
| Tag `017` | — | — | — | large, medium, small, mini | — | `color` (11 families), `filled`, `bordered`, `icon`, `onClose` |
| Divider `018` | — | — | — | — | — | `orientation` (horizontal, vertical), `align` (start, center, end, none), `label`, `dashed` |
| Button `019` | primary, secondary, dashed, outline, text | standard, danger, warning, success | rectangle, pill, square, circle | large, medium, small, mini | default, hover, focus, active, disabled | `leadingIcon`, `trailingIcon`, `isLoading` (the one property), `isFullWidth` |
| Checkbox `020` | — | — | — | — (fixed 24 / 14 box) | default, hover, focus, disabled | `checked`, `indeterminate`, `label` |
| Radio `021` | — | — | — | — (fixed 24 / 14 box) | default, hover, focus, disabled | `checked`, `icon`, `label`, group membership |
| Switch `022` | circle, rectangle, line | — | — | standard, small | default, hover, focus, disabled | `value`, `handleIcon`, `trackContent` (none, icon, text), `label`, `semanticLabel` |

Every state column above is resolved from widget state, never from a parameter
(`DS-CONST-05`). The single exception in the table is the button's `isLoading`,
which has no Material state to attach to and is therefore a property; the button
spec states why.

## Coverage

The six verification layers are the ones
[`05-process/verification.md`](../05-process/verification.md) defines. A cell
names what exists; it does not claim that a layer is complete.

| Component | Behaviour | Semantics | Geometry | Colour resolution | Golden | Contrast |
| --- | --- | --- | --- | --- | --- | --- |
| Loading `012` | yes | yes | yes | yes | yes, two panels | absent |
| Tag `017` | yes | yes | yes | yes | yes, dark theme only | absent |
| Divider `018` | yes | yes | yes | yes | yes, dark tokens in the "light" panel | boundary registered, label ink asserted |
| Button `019` | yes | yes | heights, square box | absent | yes, dark theme only | solid pair only; overlay not measured |
| Checkbox `020` | yes | yes | yes | yes | yes, both themes | boundary asserted, fill pair light only |
| Radio `021` | yes | yes | yes | yes | yes, both themes | boundary asserted, fill pair light only |
| Switch `022` | yes | yes | yes | yes | yes | boundary asserted, handle pair absent |

Reading the last column: [`contrast_test.dart`](../../test/accessibility/contrast_test.dart)
tests the token layer arithmetically and never renders a widget. A component is
covered only when the roles it paints with are rows of that table. Three
consequences are on record:

* The tag's family inks are not in the table at all, so no contrast layer covers
  the tag ([`tag.md`](tag.md)).
* The button's `overlayColor` composite is not in the table and is not measured
  again by any component test; the value is measured in the button spec instead
  (`OPEN-01`).
* No focus ring is measured anywhere, in any component (`OPEN-09`).

The divider and loading goldens paint their second panel with the light
`surfaceBase` while the enclosing theme stays `LumiereThemeData.dark()`, so that
panel shows dark-theme ink on a light surface. The divider line is
`borderDefault`, which differs between the themes, so the panel is not a light
baseline; the loading panel passes its colour explicitly and is an accurate light
indicator, but nothing below it is light.

## What a new component must arrive with

A component MUST arrive as three things in the same change: a spec file from
[`_template.md`](_template.md), the next free `DS-COMP-nnn` from the table above,
and its row in the axis matrix and the coverage table. A component merged without
all three is not part of the system; it is code that happens to live in this
repository.

The same change MUST add every rule it introduces to
[`07-traceability/rules.md`](../07-traceability/rules.md), with either the test
that fails when the rule breaks or the `OPEN-nn` entry that records the gap
(`DS-CONST-12`). A new axis MUST be an enum declared by this package, so that the
set of values is closed at compile time.
