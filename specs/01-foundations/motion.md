# 01 - Motion

The package owns almost no motion, and the honest reason is that the design declares
none: there is no duration token, no easing token and no curve constant anywhere in
`lib/`. What exists is one indeterminate indicator and whatever Material animates
underneath the button.

## What moves today

| Where | What moves | Value | Source |
| --- | --- | --- | --- |
| `LumiereLoading` | Continuous rotation of a 270° arc | 900 ms per turn, `repeat()` | Placeholder, no design value |
| `LumiereLoading` | Arc drawn with a round cap, stroke = diameter / 10 | 2 at the default 40 | RECORDED, unmeasured |
| `LumiereButton` | Material ink splash and its overlay tint from `fillDefault` | Not tokenised | Material, inherited |
| Everything else | Nothing | — | — |

The indicator is an `AnimationController` of 900 ms with `repeat()`, driving a
`RotationTransition`
([`lumiere_loading.dart:44`](../../lib/src/components/loading/lumiere_loading.dart#L44-L52)).
It never settles, so a widget test pumps frames instead of waiting for the tree. The
duration is a placeholder and will be replaced when the design declares one.

The button's splash is not this package's animation: it belongs to the `TextButton`
underneath and the button only colours it. It is not tokenised, and the overlay's
behaviour is the subject of OPEN-01, registered with the button spec rather than here.

## Rules

**DS-MOTION-001 - A duration is a token or nothing.** A duration or easing value in a
component `MUST NOT` be a literal once a motion token exists. Until one exists the
single duration in the package `MUST` stay labelled as a placeholder, and a new
duration `MUST NOT` be added without the token that governs it (OPEN-11).

**DS-MOTION-002 - Reduced motion is honoured.** Every animation `MUST` consult
`MediaQuery.disableAnimations`. When it reports true, the loading indicator `MUST` stop
repeating and `MUST` show a static representation of the same arc. The indicator does
not consult it today, so this rule is unmet in the only place the package animates
(OPEN-11).

**DS-MOTION-003 - Only the indicator animates on its own.** An animation that runs
without a widget state change `MUST` be the loading indicator. Any other component
`MUST NOT` start a self-driven animation, and a component that does animate `MUST`
dispose its controller with its state.

**DS-MOTION-004 - State changes do not animate without a declared duration.** A
transition between states `MUST NOT` interpolate on a duration the package did not
declare. Where Material animates a state change on the package's behalf, the component
`MUST` record that the animation is inherited rather than tokenised, as the button does
with its splash.

**DS-MOTION-005 - A new motion value is measured.** A duration, easing or stroke ratio
`MUST` be measured from the design file before it is added. A value with no
measurement `MUST` be labelled a placeholder, `MUST` name what it will be measured
against, and `MUST` appear in [`../07-traceability/open-items.md`](../07-traceability/open-items.md).

## Status

Measured: that the indicator turns without any input, and that the button draws the
indicator rather than `CircularProgressIndicator`
([`lumiere_loading_test.dart:63`](../../test/lumiere_loading_test.dart#L63-L79),
[`:105`](../../test/lumiere_loading_test.dart#L105-L115)). That is the whole of the
measured surface.

Not measured: the 900 ms itself, which no test pins and no design value backs; the
stroke-to-diameter ratio, which the component records as pending; reduced motion, which
nothing consults; and every easing, because none exists. There is no motion token to
measure against, so DS-MOTION-001 and DS-MOTION-005 have nothing to bind to yet.

The specification matches the code: one indicator, one placeholder duration, no
tokens, and a reduced-motion gap.

## Open items

- OPEN-11 - The loading indicator ignores reduced motion and no motion token exists,
  which is the whole of DS-MOTION-001 and DS-MOTION-002 unmet.
