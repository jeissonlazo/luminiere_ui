# 02 - Component spec template

Every file in this directory has the sections below, in this order, with these
headings. The order is not cosmetic: a reader checking a change walks it top to
bottom, and a section that moves breaks that walk. `## Status` and `## Open items`
close every file, as a pair, without exception.

The length of each section is free. The content of each is not: what follows says
what belongs in it and why the spec is worthless without it.

Rules inside these sections use the bold lead form, with the ID as the first token of
the block: `**DS-API-019-01** - A disabled button MUST be a null callback`. The heading
form is reserved for a rule that is a section of its own, which is what the foundations
and the cross-cutting accessibility files do. Both are canonical; an ID buried inside a
sentence is a citation, not a rule.

## Contract

The `DS-COMP-nnn` identifier, one paragraph on what the component is, the name of
the component set in the design file it mirrors, and a single sentence stating
what a consumer may rely on. Write the sentence as a promise, not as a summary;
it is the thing a reviewer holds a pull request against when the diff is large.

The identifier is allocated in [`README.md`](README.md) and never reused. A
component that mirrors no component set in the design file says so here, and the
absence is a finding rather than an omission.

## Axes

A table of `axis | values | where it lives`. Every axis the design file declares
appears, and the third column states whether the axis is a constructor parameter
or real widget state (`hover`, `focus`, `pressed`, `disabled` resolved from the
widget itself).

The distinction is the point of the section: state MUST NOT be a parameter
(`DS-CONST-05`), because a caller can then describe a state the widget is not in
and the screenshot lies. An axis that is a state and appears as a parameter is
the defect this section exists to make visible. An axis the widget collapses into
another — two boolean parameters that the design expresses as one — is named here
with the collapse written out.

## API

A table of `parameter | type | default | semantics`. The `semantics` column says
what the parameter does to the contract, not what its type is.

Every nullable parameter MUST have its `null` meaning written down, including
when `null` means "disabled" and when it means "absent and therefore not drawn".
A reader who has to open the source to learn what `null` does is reading the
implementation, which is exactly what this directory exists to avoid.

## Geometry

The measured values with their source, one row per value: the control height, the
padding, the visible box, the stroke width, the gap. The source is the layer or
the section of the measurement it came from, or the token that carries it.

Every value that is **not** measured appears too, with the token it fell back to
and the reason. A fallback stated here is a fallback a designer can overturn; a
fallback absent here is a number nobody can find again (`DS-CONST-04`). A value
that falls back to a token MUST also appear in `## Open items` or in `## Status`.

## Colour resolution

A table of `state | role | notes`, one row per state the component can be in, and
the **semantic role** in the middle column — `accent.normal`, `borderHeavy`,
`textOnAccent`. Never a hexadecimal value, never a palette primitive: a hex value
is a measurement of one theme at one moment, and it stops being true the first
time the design file changes (`DS-CONST-03`).

Where a fill and an ink are chosen together, the row says so, because they are a
pair (`DS-CONST-11`). Where a state has no colour of its own, the row says which
state's colours it keeps and why, so the absence reads as a decision.

## Accessibility

Six things, each in its own line: the role, where the accessible name comes from,
which states are exposed to assistive technology, how the control is operated from
a keyboard, what the focus indicator is, and what geometry that indicator occupies.
The focus ring is stated with its width, its offset and its colour role, because
`DS-CONST-08` is only checkable if the numbers are written down.

A control that has no accessible name without a visible label says so here and
carries an `OPEN-nn` entry. A component carries its own accessibility
(`DS-CONST-06`); a line delegating a name to the caller is a violation, not an
instruction.

## States that do not exist

The states the design file implies but does not declare, and the states the widget
deliberately does not have, each with the reason. A press that keeps the resting
colours belongs here; so does a `loading` that is a property because Material has
no state for it.

This section is what stops the next contributor from "completing" the matrix with
a state the design never drew.

## Verification

Which test files assert what, by layer: behaviour, semantics, geometry, colour
resolution, golden, contrast. Name the file and the fact, in a table.

A guarantee that is stated in the sections above and names no test here and no
`OPEN-nn` below is a bug in this directory (`DS-CONST-12`). The section is also
where an absent layer is recorded, because a missing row is read as a complete
one.

## Status

One or two lines: what is measured, what the implementation does today, and which
part of it is a consequence of a decision elsewhere — a breaking change to a
Material widget, a golden that covers one theme only.

## Open items

One line per `OPEN-nn`, quoting the identifier that
[`07-traceability/open-items.md`](../07-traceability/open-items.md) owns, or the
single word `None.` The identifiers are not defined here and MUST NOT be
invented here: an open item that only exists in a component file is not
registered, it is a note.

## Anti-patterns

Four things this directory forbids, each of which has been seen in this repository:

* **Describing the code.** "The painter reads `_CheckboxGeometry.radius`" is a
  sentence about a file. "The visible box is 14 x 14 with a 2 px radius" is a
  sentence about a contract. The spec describes what the component guarantees; the
  dartdoc next to the code explains why the value is what it is.
* **Citing a hexadecimal value** in `## Colour resolution`, or anywhere a role is
  meant. A hex value binds one theme at one moment and silently falsifies the
  other theme. Roles bind both.
* **Claiming a guarantee without naming its test.** A MUST that no test fails on
  and no `OPEN-nn` records is an aspiration dressed as a rule.
* **Omitting a known gap.** A spec that reads clean while the component misbehaves
  manufactures confidence, which is worse than the gap itself. The gap goes in
  `## Status` when it is a measurement limitation and in `## Open items` when it
  is unclosed work.
