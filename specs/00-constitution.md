# 00 - Constitution

Twelve invariants. Each one is stated so that a reviewer can decide, without
discussion, whether a pull request breaks it. Everything else in `specs/` is
detail underneath these; where a detail and an invariant disagree, the invariant
wins and the detail is the bug.

A violation is not merged, whatever it fixes. If an invariant is genuinely wrong,
it changes here first, with an `ADR-nnnn`, and the code follows.

Legend: **In force** means a test enforces it today. **Review** means it is
enforced by reading the diff. **OPEN-nn** means the code violates it right now.

---

## DS-CONST-01 - One public entry point

The package `MUST` expose exactly one importable library,
`package:lumiere_ui/lumiere_ui.dart`, which names what it exports with an explicit
`show` list. Everything under `lib/src/` `MUST NOT` be imported by a consumer.

*Why:* the surface a consumer can reach is the surface this package has to keep
stable. An implicit export makes every future refactor a breaking change.

*Enforced:* Review. The barrel is thirty-four lines and the `show` lists are
visible in the diff ([`lib/lumiere_ui.dart`](../lib/lumiere_ui.dart)).

---

## DS-CONST-02 - A component holds no visual literal

A component `MUST NOT` contain a colour, a size, a duration or an opacity written
as a literal. It reads a token: a semantic role for colour, an `Arco*` scale for
geometry, `LumiereStrokes` for line weight.

*Why:* a literal is a decision taken outside the design file, invisible to the
token layer, and impossible to theme.

*Enforced:* Review, except for the recorded exception: the button's dashed
painter keeps its own `4 / 3 / 1` instead of reading
[`LumiereStrokes`](../lib/src/tokens/lumiere_tokens.dart) - see **OPEN-02**.

---

## DS-CONST-03 - Components read semantic roles, never primitives

A component `MUST NOT` reference `ArcoPalette*` or `ArcoSemantic*` directly. Colour
reaches a component only through `LumiereColors` and `LumiereStatusColors`.

*Why:* the primitive layers are generated from the design file and may be
renamed, re-cut or replaced by a different file. The semantic layer is the
hand-written mapping that survives that.

*Enforced:* Review, and by the barrel: the primitive classes are not exported
([`lib/lumiere_ui.dart`](../lib/lumiere_ui.dart)).

---

## DS-CONST-04 - Every value comes from a measurement, and unmeasured values say so

A value in this package `MUST` cite where it was measured. A value that has not
been measured `MUST` be labelled as pending, name the token it falls back to, and
appear in [`07-traceability/open-items.md`](07-traceability/open-items.md).

*Why:* the difference between "the design says 12" and "12 looked right" is the
difference between a design system and a guess, and after two releases nobody can
tell them apart.

*Enforced:* Review. The dartdoc of every component names its source, and the
`Status:` line of each spec records what is still unmeasured.

---

## DS-CONST-05 - State is a widget state, not a property

A component `MUST NOT` accept `hovered`, `pressed`, `focused` or `disabled` as a
parameter it paints from. It resolves them from the widget's own state. `disabled`
is the exception only where it is a semantic property of the value (a disabled
item in a list), and even then the widget `MUST` also treat a null callback as
disabled.

*Why:* a caller can describe a state the widget is not in, and the resulting
screenshot lies.

*Enforced:* In force, by construction: no component has such a parameter.

---

## DS-CONST-06 - A component carries its own accessibility

Every interactive component `MUST` provide its own role, name, state, keyboard
activation and visible focus. It `MUST NOT` require the caller to wrap it in a
`Semantics` widget or to pass a label the component could derive itself.

*Why:* accessibility delegated to the caller is not implemented. In a library used
by several applications, it is implemented zero times, or a different amount in
each.

*Violated today:* `LumiereButton` in an icon-only shape, `LumiereCheckbox` and
`LumiereRadio` without a visible label have no way to receive an accessible name -
see **OPEN-03** and **OPEN-04**.

---

## DS-CONST-07 - Value is never carried by colour alone

A control that expresses a value `MUST` also express it geometrically or
typographically: the checkbox draws a tick or a dash, the radio a dot, the switch
moves its handle. Colour may decorate the difference; it `MUST NOT` be the
difference.

*Why:* colour-blind users, monochrome displays, printed output and forced-colours
mode all remove the one carrier a designer finds cheapest.

*Enforced:* In force: geometry asserted in the behaviour tests, and visible in the
goldens.

---

## DS-CONST-08 - Focus is always visible and never enlarges the layout

A focusable control `MUST` draw a focus indicator of at least 2 logical pixels that
reaches 3:1 against what it sits on, drawn inside the measured interactive box so
the control does not move when focused.

*Why:* a control that shifts on focus destroys the interaction for keyboard users;
one that does not show focus destroys the interaction for everyone who cannot use
a pointer.

*Enforced:* Partly. The ring is measured in the geometry tests; its contrast is
**not** asserted - see **OPEN-09**.

---

## DS-CONST-09 - The package ships no user-visible string

The package `MUST NOT` contain a word a user reads. Accessible names, loading
announcements and close actions take their text from the caller. A component that
needs a string `MUST` require it in its constructor and fail loudly when it is
missing - in release builds too, not only in an `assert`.

*Why:* this package has no locale, and a design system that guesses a language is
wrong in every application that does not share the guess. An `assert` is compiled
out of release builds, so a debug-only guard converts a clear error into a null
dereference in production.

*Enforced:* Review. One guard is `assert`-only today - see **OPEN-05**.

---

## DS-CONST-10 - Geometry comes from the scales, never from Material

Control heights and paddings `MUST` come from `ArcoControl`; spacing from
`ArcoSpace`; radii from `ArcoRadius`. The theme `MUST` leave Material's
`visualDensity` at its default and `MUST` set `tapTargetSize` explicitly rather
than inheriting a platform default.

*Why:* a design system that lets Material decide a control's height does not own
its own geometry, and the number changes silently with the Flutter version.

*Enforced:* In force: `LumiereThemeData` sets neither density nor target size, and
the button pins both
([`lumiere_button.dart`](../lib/src/components/button/lumiere_button.dart)).

---

## DS-CONST-11 - A fill and its label are a pair

A solid surface `MUST` take its fill and the ink that sits on it from the same
`solidFill`/`solidLabel` pair of one `LumiereStatusColors`. A component `MUST NOT`
choose a fill from one family and a label from another, or pick a label by eye.

*Why:* contrast is a property of the pair. Chosen separately, the pair is only
correct by coincidence, and the coincidence expires with the next palette change.

*Enforced:* The pair is asserted, by `contrast_test.dart`, which reads it from
`LumiereRamp` and checks 4.5:1 for all eight combinations in both themes.

*Violated today, and this is why the invariant is worded about the pair and not about
the label:* the label of a `primary` button takes `solidLabel`, but its **icon** takes
`ramp.normal` - the fill colour itself. Measured at 1.00:1 in six of the eight
`kind`-and-theme combinations; an icon-only primary button is a blank rectangle in the
light theme. See **OPEN-25**.

---

## DS-CONST-12 - A rule without an enforcing test is registered, not assumed

Every normative rule in `specs/` `MUST` map, in
[`07-traceability/rules.md`](07-traceability/rules.md), to either a test that
fails when the rule breaks, or an `OPEN-nn` entry that says it is unenforced and
why.

*Why:* a specification whose guarantees are not executed is a description of
intentions. This repository already had that problem once: the accessibility
contract lived only inside a test file, and the "pending list" the code cites
was never written down.

*Enforced:* Review, at the level of the traceability file. It is the invariant
that keeps the other eleven honest.

---

## What these invariants deliberately do not say

They say nothing about file layout, naming style, comment density or commit
message shape. Those are conventions, they are visible in the code, and turning
them into policy buys argument rather than consistency. The contribution guide
records them; this constitution does not enforce them.
