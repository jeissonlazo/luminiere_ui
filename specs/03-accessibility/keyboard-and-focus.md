# 03 - Keyboard and focus

How a keyboard user reaches, operates and sees every control in this package, and
where the model breaks today.

The package owns this behaviour rather than inheriting it: the checkbox, radio and
switch are drawn by hand precisely so their focus indication is a property of the
design system and not of whatever the Flutter version ships (see
[ADR-0003](../06-decisions/adr-0003-own-painters-over-material.md)).

---

## DS-A11Y-060 - One control, one tab stop

Every interactive component MUST be exactly one node in the focus traversal order.
A composite control - the radio group - MUST be a single stop and move the
selection inside itself, so that a group of five radios does not cost five presses
of Tab to walk past.

*Enforced:* the radio group's single tab stop and its keyboard model are asserted
in [lumiere_radio_test.dart](../../test/lumiere_radio_test.dart).

---

## DS-A11Y-061 - Activation keys

| Control | Keys that operate it |
| --- | --- |
| Button | Enter and Space (Material's own behaviour) |
| Checkbox | Space; with `indeterminate`, Space selects rather than clears |
| Radio | Space; inside a group, arrows move and select, Space selects the focused radio |
| Switch | Space |

A control MUST NOT require a pointer, and MUST NOT require `Enter` where the
platform convention is `Space` for a toggle.

---

## DS-A11Y-062 - The focus ring is drawn, not overlaid

A focusable control MUST draw its own indicator: at least 2 logical pixels wide,
drawn **inside** the measured interactive box so that focusing a control never
moves it, and at 3:1 against what it sits on.

The ring is a 2 px stroke inset by 1 px from the interaction box, in every component
that draws it. Its colour is `accent.normal`, except on the switch's `circle` and
`rectangle` types, where the ring lands on the track and is drawn in `surfaceBase`
as a knockout, and on the `line` type, where it lands on the page and is drawn in
`accent.normal`.

*Violated by the button:* `LumiereButton` is a restyled `TextButton` and draws no
ring of its own; its only focus indication is the Material overlay tint, which is
not 2 px, is not inset, and is not measured. See **OPEN-09**.

---

## DS-A11Y-063 - Focus state lives in the widget

A component MUST resolve `WidgetState.focused` from the framework and MUST NOT
accept a `focused` parameter. Nothing about focus is delegated to the caller.

*Enforced:* by construction (`DS-CONST-05`).

---

## DS-A11Y-064 - Focus nodes are owned or accepted, never leaked

A component MUST accept an optional external `FocusNode` and MUST own, and dispose,
its own when none is given. A node created internally MUST be disposed with the
widget.

The checkbox, radio and switch expose `focusNode` and both create and dispose their
own. A `FocusNode` MUST NOT be attached to two widgets at once, which is why the
goldens hold one node per theme panel.

---

## DS-A11Y-065 - The ring must survive the platform's highlight policy

The ring is a focus *highlight*, and a touch-first platform suppresses it. A
component MUST therefore draw focus from the widget state rather than depending on
the platform default, and a test that asserts a ring MUST set
`FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional`
and restore it afterwards.

*Enforced:* the goldens and the behaviour tests do exactly this; a test that omits
it silently asserts nothing.

---

## DS-A11Y-066 - The ring's own contrast is part of the contract

A 2 px ring on `accent.normal` against `bg.1`, `bg.2`, `bg.5`, `fill.*` and against
the control's own fill MUST reach 3:1, and that MUST be recorded in the
[contract](contract.md) like any other pair.

*Not satisfied:* no row of the contract measures a focus ring - **OPEN-09**.

---

## DS-A11Y-067 - The ring constants live in one place

The ring width and inset are 2 and 1. They MUST come from a single token rather
than from a private constant in each component, so that a change cannot leave three
components disagreeing.

Today `_focusRingWidth` and `_focusRingInset` are declared privately in the
checkbox, the radio and the switch. They agree, and nothing enforces that they keep
agreeing.

---

## DS-A11Y-068 - An interactive target is the measured box, not the glyph

A tap target `MUST` be at least the measured interactive box of its control: 24 by 24
for the form controls, the full height of the tag for a tag's close action. A target
that shrinks to the size of its glyph `MUST NOT` ship, because an icon is a picture of
an action, not its hit area.

*Why:* a 12 px target is operable only with a precise pointer, and a design system
cannot assume one. The number is not a preference: it is the same box the package
already measures for every other control, so a smaller one is an internal
inconsistency as well.

*Violated today:* the tag's close action is `Semantics > InkWell > Icon` inside a `Row`
that does not stretch, so the target is the 12 x 12 glyph in a 24 px tag while the
dartdoc claims the tag's full height - **OPEN-24**.

---

## Status

Keyboard operation is tested for every control: Space activation, Enter and Space on
the button, arrow keys and Space inside the radio group, the group as a single tab
stop, and a visible ring on the three components that draw one.

The model has one hole, one duplication and one target: the button has no ring of its
own, no ring's contrast is measured anywhere, the ring constants are declared three
times, and the tag's close target is the size of its glyph.

## Open items

- **OPEN-09** - The button draws no focus ring of its own, and no component's ring contrast is measured against any surface.
- **OPEN-12** - `focusNode` lifecycle is exercised only incidentally; no test asserts that an external node is adopted and an internal one disposed.
- **OPEN-24** - The tag's close action has a 12 x 12 pointer target in a 24 px tag, and no test measures a target box for any component.
