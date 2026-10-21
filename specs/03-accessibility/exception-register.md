# 03 - Exception register

Section 8 of the [accessibility contract](contract.md), as a document. Every entry
here is a combination that does not meet its threshold and is known, named and
justified. Nothing in this package may fail a threshold without an entry.

Two properties make this register worth more than a comment:

- An entry marked **open** asserts the opposite of a threshold: the test requires
  the combination to keep failing, so fixing it breaks the build and forces the
  entry to be closed rather than forgotten.
- An entry marked **permanent** has no threshold at all. The combination is
  recorded because reaching for it is a mistake, not because the value is
  acceptable as text.

---

## DS-A11Y-009 - What an entry must contain

An entry MUST carry: a stable ID, the combination it covers named as the contract
names it, the recorded value or range, a reason that says *why* this is acceptable
or permanent, whether it is open or permanent by design, and the test that
enforces it.

An entry whose reason begins with `Open` MUST still fail its threshold. An entry
whose reason begins with `Permanent` MUST have no threshold. Both properties are
asserted ([contrast_test.dart:663-747](../../test/accessibility/contrast_test.dart)).

An ID MUST NOT be reused, renamed or retired. A closed entry stays in the table,
marked closed, with the version that closed it.

---

## The register

### AE-08 - light `text.3`, closed in 0.5.0

| | |
| --- | --- |
| Combination | light `text.3` on the white surface |
| Export value | `#86909C`, 3.89:1 - below 4.5:1 |
| Package value | `#6A7583`, 4.68:1 |
| Reason | Darkened to the smallest change of the declared pair that reaches the threshold, by a declared override; `text.2` stays at 7.10 and `text.1` at 16.13, so the hierarchy survives |
| Status | **Closed.** No longer an exception: the value is recorded like any other |

`tokens.g.dart` annotates the override where it lands and repeats it at the end of
the class, so a difference from the design file is visible in the generated output
instead of living in a comment somebody has to remember.

### AE-09 - `text.4` is decorative

| | |
| --- | --- |
| Combinations | dark `text.4` on `bg.1` (2.71), light `text.4` on `bg.1` (1.59) |
| Reason | Permanent by design: `text.4` is decorative and disabled-only, never informational, so no threshold is asserted for it |
| Status | **Permanent** |

### AE-10 - separators are not boundaries

| | |
| --- | --- |
| Combinations | `border.1`, `border.2`, `border.3` on `bg.1`, both themes (1.11 to 2.80) |
| Reason | Permanent by design: these are separators; a boundary that identifies a control uses `border.4` |
| Status | **Permanent** |

### AE-11 - the decorative status fill is not text

| | |
| --- | --- |
| Combinations | light `success.6`, `warning.6`, `danger.6` on their own step-1 background (2.41 to 3.25) |
| Reason | Permanent by design: those fills are decorative and are never used as text. Each family carries `onSubtle` for that, asserted at 4.5:1 by `status_ink_test.dart`. The values stay recorded because reaching for the fill instead of the ink is still wrong |
| Status | **Permanent**, with the ink implemented in 0.5.0 |

### Collision: `AE-11` also names the tag label

The tag's own documentation cites `AE-11` for a different entry: the tag label at
step 6 does not reach 4.5:1 on every colour family in the light theme
([lumiere_tag.dart:28-31](../../lib/src/components/tag/lumiere_tag.dart)). That is a
real and open exception, it is not the one above, and it appears in no register
entry. The same ID therefore resolves to a closed-permanent status decision and to
an open component failure - **OPEN-22**.

### AE-12 to AE-15 - cited but missing

The button's colour resolution states that the design's hover and pressed steps
"stay as the design declares them, which the register records as AE-12 to AE-15"
([lumiere_button.dart:201-203](../../lib/src/components/button/lumiere_button.dart)).
No such entries exist. The combinations they would cover are the primary button's
hover and pressed fills in both themes, where the label measures 3.65 (light hover)
and 4.34 (dark hover) against `textOnAccent` - above 3:1 as a graphic indicator,
below 4.5:1 as text, which is precisely why they need a decision recorded -
**OPEN-21**.

### The tag families - no entry at all

Nine of eleven light families fail 4.5:1 on the soft background and ten of eleven
on the strong one (worst 1.70, `dusk` on its own subtle background). This is the
largest deviation from the contract in the package and it is registered nowhere:
the contrast table never reads `LumiereTagColor` - **OPEN-06**.

---

## Status

Three live entries (`AE-09`, `AE-10`, `AE-11`) and one closed (`AE-08`), all encoded
in [contrast_test.dart](../../test/accessibility/contrast_test.dart).

The register is **not** complete: two citations dangle (`AE-12` to `AE-15`), one ID
is overloaded (`AE-11`), and the tag families - the worst contrast figures in the
package - have no entry. The safeguard that keeps an open entry honest
([contrast_test.dart:695-730](../../test/accessibility/contrast_test.dart)) has
never run, because every entry is permanent.

## Open items

- **OPEN-06** - The tag families are registered nowhere and fail in both forms.
- **OPEN-10** - The open-entry safeguard iterates an empty set, so "an open entry must keep failing" is untested.
- **OPEN-21** - `AE-12` to `AE-15` are cited by the button and do not exist.
- **OPEN-22** - `AE-11` names both the closed status-ink decision and the open tag-label failure.
