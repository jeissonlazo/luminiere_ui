# 03 - Accessibility contract

The contrast and legibility guarantees this package makes, by section, with the
ratio each combination must reach and the ratio the design records for it.

Until this file existed, the contract was referenced as
`design/accessibility-contract.md` "which lives with the application"
([contrast_test.dart](../../test/accessibility/contrast_test.dart) line 3), and its
content survived only as a table inside a test. That is the problem this file
solves: an exception ID could be cited by shipped code while its referent was
unreachable.

**Only sections 1, 3 and 8 are reproduced here**, because those are the ones this
package implements and encodes. The original contract numbers further sections
that this repository has never held; a section not reproduced below is not
covered by any test, and no rule may claim otherwise.

---

## DS-A11Y-001 - The contract is level 1

This contract is arithmetic over the token layer. It MUST be evaluated on the
values a component resolves, in both themes, without mounting a widget.

*Consequence, stated so nobody relies on the opposite:* nothing in this contract
observes a rendered pixel. A colour composited by the framework after the token is
resolved is outside its reach - which is how a primary button can render a 1.11:1
label on hover while every section below passes (**OPEN-01**), and why a component
that resolves its ink from the primitive palette instead of a semantic role can
fail while the table stays green (**OPEN-06**).

The executable copy of this document is the `_pairs` table of
[contrast_test.dart](../../test/accessibility/contrast_test.dart). A change to a
recorded value MUST move both, and a reviewer MUST reject a diff that moves one.

---

## DS-A11Y-002 - Section 1: thresholds

| Category | Minimum ratio |
| --- | --- |
| Normal text | 4.5:1 |
| Large text | 3:1 |
| Graphical information and control boundaries | 3:1 |

A combination MUST be measured against the background it is actually composited
over, not against the page by default.

Permitted tolerance between a recorded value and the measured one is 0.1, because
the contract recorded its opacities as percentages (90, 70, 50, 30) while the
generated tokens carry them as 8-bit alpha (229, 178, 128, 77)
([contrast_test.dart:52-58](../../test/accessibility/contrast_test.dart)). A
palette change moves a ratio much further than 0.1, so the tolerance keeps the
check meaningful without being brittle.

---

## DS-A11Y-003 - Section 3.1: the text hierarchy

Text MUST reach 4.5:1 on the surface it sits on.

**`text.1` and `text.2` on the page and on every container:**

| Token | Dark, recorded | Light, recorded |
| --- | --- | --- |
| `text.1` on `bg.1` | 14.58 | 16.13 |
| `text.2` on `bg.1` | 9.16 | 7.10 |
| `text.3` on `bg.1` | 5.26 | 4.68 |
| `text.4` on `bg.1` | 2.71 (AE-09) | 1.59 (AE-09) |

**Containers.** On `bg.2` to `bg.5` the dark theme records ranges rather than
single values, because each container is a different grey: `text.1` between 9.96
and 14.58, `text.2` between 6.74 and 9.16
([contrast_test.dart:505-548](../../test/accessibility/contrast_test.dart)). The
light containers are all the white of `bg.1`, measured again so that a change to a
container token cannot pass unnoticed.

**`text.3` is not approved on the dark containers.** It drops to 4.30 on `bg.5`,
below the normal-text threshold. A component that places tertiary text on a raised
surface in the dark theme therefore violates this section even though
`text.3` on `bg.1` passes - the rule is about the pair, not the token.

**`text.4` is decorative and disabled only** and MUST NOT carry information. Its
values are recorded under `AE-09` and never asserted.

---

## DS-A11Y-004 - Section 3.2: a solid fill and its label, and the overlays

A solid surface MUST carry the one label colour that reaches the threshold on it,
and that pair MUST be the family's own `solidFill`/`solidLabel` (see
`DS-CONST-11`).

| Family | Dark, recorded | Light, recorded |
| --- | --- | --- |
| accent | white on `primary.4` 6.90 | white on `primary.6` 5.19 |
| danger | ink on `danger.6` 5.50 | white on `danger.7` 5.43 |
| warning | ink on `warning.6` 7.41 | ink on `warning.6` 6.29 |
| success | ink on `success.6` 6.90 | ink on `success.6` 5.81 |

The light danger pair is the documented asymmetry: dark ink on `danger.7` measures
2.97, white measures 5.43, so the pair is `danger.7` + white and not `danger.6` +
ink. The theme is the authority on which step a solid fill uses.

**Overlays.** `fill.1` to `fill.4` are documented as the overlays of a neutral
surface, so informational text on them is measured with the overlay composited over
the page:

| Token | Dark, recorded | Light, recorded |
| --- | --- | --- |
| `text.1` on `fill.1` | 13.28 | 15.18 |
| `text.1` on `fill.2` | 11.94 | 14.53 |
| `text.1` on `fill.3` | 10.46 | 12.94 |
| `text.1` on `fill.4` | 9.20 | 10.11 |

This section is the one that assumes `fill.*` is a tint. In the light theme those
tokens are opaque, so the same role is used as a surface fill and as an overlay
tint - **OPEN-13** - and using it as an overlay over an accent fill is what
**OPEN-01** does.

**Hover and pressed states are validated separately** by their own rows rather than
by reusing the resting pair. A state that changes the fill MUST re-establish its
pair; reusing the resting ratio is not a valid claim about a state the design moves.

---

## DS-A11Y-005 - Section 3.3: the status inks

A status family MUST expose an ink for text that sits on its own subtle
background, and that ink MUST reach 4.5:1 on it.

The decorative fill at step 6 is not that ink: it measures 2.41 to 3.25 on the
subtle background in the light theme, so it MUST NOT be used as text there. Each
family carries `onSubtle` for exactly this, asserted by
[status_ink_test.dart](../../test/accessibility/status_ink_test.dart).

The step-6 values stay recorded under `AE-11` because reaching for the fill
instead of the ink is still wrong, even once the ink exists.

---

## DS-A11Y-006 - Section 3.4: control boundaries and separators

A boundary that identifies a control MUST reach 3:1 against every background the
control can sit on, and it MUST be `border.4`.

| Boundary | Dark, recorded | Light, recorded |
| --- | --- | --- |
| `border.4` on `bg.1` | 5.75 | 3.24 |
| `border.4` on `bg.2` / `bg.3` / `bg.4` / `bg.5` | 5.05 / 4.61 / 4.18 / 3.82 | measured on `bg.1` only |

`border.1` to `border.3` are separators, not control boundaries. They are recorded
under `AE-10` and 3:1 is never asserted for them. Using a separator as the only
edge of a control is a violation of this section, not a matter of taste.

The light `border.4` on `bg.1` measures 3.24, so the margin is 0.24. A palette
change that darkens the boundary, or lightens the page, closes it.

---

## DS-A11Y-007 - Section 8: the exception register

A combination that does not reach its threshold MUST be registered by ID, with the
reason, the values and whether it is open or permanent by design. **`RECORDED` is
not a synonym for `accepted silently`:** an entry with `open: true` MUST keep
failing, and closing it MUST fail the test that says so.

The register is [`exception-register.md`](exception-register.md). It is currently
incomplete in two ways - **OPEN-21** and **OPEN-22** - and its "open" branch is
dead code - **OPEN-10**.

---

## DS-A11Y-008 - A component must state which combination it renders

For every state it paints, a component MUST be able to name the foreground and the
background pair from a section of this contract. A component that resolves a
colour by a rule this document does not describe - for example the focus ring, or
a decorative glyph - MUST register it as an `OPEN-nn` rather than leave it
unmeasured.

This is the section that the components currently fail most often in a silent way:
the ring (**OPEN-09**) and the tag families (**OPEN-06**) are resolved from real
tokens with real thresholds, and no row covers them.

---

## Status

Sections 1, 3.1, 3.2, 3.3, 3.4 and 8 are encoded and green: 55 documented
combinations across both themes, plus eight solid pairs read from the semantic
layer rather than restated.

Not covered, and deliberately listed rather than implied: the 11 tag colour
families (OPEN-06), the focus ring (OPEN-09), and any colour composited after
resolution (OPEN-01). The suite is level 1 only; there is no level 2.

## Open items

- **OPEN-01** - A composited overlay is outside this contract's reach, so the primary button's light-theme hover renders a 1.11:1 label while every section passes.
- **OPEN-06** - The tag families are absent from the table; nine of eleven light families fail 4.5:1 on their soft background and ten of eleven on the strong one.
- **OPEN-09** - The focus ring's contrast is never measured.
- **OPEN-10** - The test that requires open register entries to keep failing iterates an empty set.
- **OPEN-13** - Section 3.2 treats `fill.*` as a tint; in the light theme those tokens are opaque.
- **OPEN-21** - `AE-12` to `AE-15` are cited by the button and exist in no register entry.
- **OPEN-22** - `AE-11` denotes two different entries, so a citation cannot be resolved unambiguously.
