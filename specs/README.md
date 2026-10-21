# Lumiere UI specifications

The normative source of truth for `lumiere_ui`. Code, tests and the gallery are
consequences of what is written here; when they disagree with a spec, the spec is
what gets reviewed and one of the two is wrong.

This directory does not teach. It does not hold screenshots, tutorials or
marketing. Live documentation is the gallery in [`showcase/`](../showcase/README.md);
the prose that explains *why* a value is what it is stays in the dartdoc next to
the code. What lives here is only what is **binding**: the rules a change must
satisfy, the contract a consumer may depend on, and the register of what is still
unproven.

## Who reads what

| Reader | Entry point | Why |
| --- | --- | --- |
| An application consuming this package | [`04-integration/consuming.md`](04-integration/consuming.md) | What is guaranteed, what must the app supply, how to override |
| A contributor changing a component | [`00-constitution.md`](00-constitution.md) then the component file | The invariants a change may not break |
| A reviewer | [`05-process/definition-of-done.md`](05-process/definition-of-done.md) and [`07-traceability/rules.md`](07-traceability/rules.md) | Whether a claim is enforced by a test |
| A designer owning the Figma file | [`01-foundations/`](01-foundations/) and [`03-accessibility/contract.md`](03-accessibility/contract.md) | What the design file is responsible for |
| Anyone about to re-litigate a settled question | [`06-decisions/`](06-decisions/) | The decision, its cost and what was discarded |

## Normative language

The words below are load-bearing and are used in the RFC 2119 sense:

| Word | Meaning here |
| --- | --- |
| **MUST** / **MUST NOT** | A change that breaks this is not merged, whatever it fixes |
| **SHOULD** / **SHOULD NOT** | The default; a deviation MUST be justified in the PR and, if lasting, recorded as an ADR |
| **MAY** | Genuinely optional |
| **RECORDED** | A value or combination that is known and deliberately not asserted, because the design file owns it. Registered in [`03-accessibility/exception-register.md`](03-accessibility/exception-register.md) |
| **OPEN** | Not satisfied today. Registered in [`07-traceability/open-items.md`](07-traceability/open-items.md) with an ID, a severity and the reason it is not closed |

A rule without an enforcing test and without an `OPEN-xx` entry is a bug in this
directory, not a rule. That is the whole point of
[`07-traceability/rules.md`](07-traceability/rules.md).

## Identifiers

Every normative rule carries an ID that is unique across the repository and never
reused or renumbered. IDs already cited by the code are preserved as-is.

| Prefix | Scope | Owner |
| --- | --- | --- |
| `DS-CONST-nn` | The invariants of the design system | [`00-constitution.md`](00-constitution.md) |
| `DS-TOK-nnn` | Token layer: layers, provenance, generation, literals | [`01-foundations/tokens.md`](01-foundations/tokens.md) |
| `DS-COL-nnn` | Semantic colour roles, ramps and pairs | [`01-foundations/colour.md`](01-foundations/colour.md) |
| `DS-TYPE-nnn` | Family, scale, line heights, hierarchy | [`01-foundations/typography.md`](01-foundations/typography.md) |
| `DS-SPACE-nnn` | Spacing scale | [`01-foundations/geometry.md`](01-foundations/geometry.md) |
| `DS-RADIUS-nnn` | Corner radii | [`01-foundations/geometry.md`](01-foundations/geometry.md) |
| `DS-CONTROL-nnn` | Control heights and paddings | [`01-foundations/geometry.md`](01-foundations/geometry.md) |
| `DS-STROKE-nnn` | Hairlines, dashes, focus rings | [`01-foundations/geometry.md`](01-foundations/geometry.md) |
| `DS-MOTION-nnn` | Durations, easing, reduced motion | [`01-foundations/motion.md`](01-foundations/motion.md) |
| `DS-COMP-nnn` | One component contract as a whole | [`02-components/`](02-components/) |
| `DS-API-nnn` | The shape of the public API | [`02-components/_template.md`](02-components/_template.md) |
| `DS-A11Y-nnn` | Accessibility behaviour | [`03-accessibility/`](03-accessibility/) |
| `AE-nn` | Accessibility exception register entries | [`03-accessibility/exception-register.md`](03-accessibility/exception-register.md) |
| `INT-nnn` | Consumer-facing guarantees | [`04-integration/`](04-integration/) |
| `PRC-nnn` | Process rules | [`05-process/`](05-process/) |
| `ADR-nnnn` | Architecture decision records | [`06-decisions/`](06-decisions/) |
| `OPEN-nn` | Known, acknowledged, unclosed gaps | [`07-traceability/open-items.md`](07-traceability/open-items.md) |

`DS-COMP-nnn` numbers are allocated in publication order and never reused:

| ID | Component | Spec |
| --- | --- | --- |
| `DS-COMP-012` | Loading | [`loading.md`](02-components/loading.md) |
| `DS-COMP-017` | Tag | [`tag.md`](02-components/tag.md) |
| `DS-COMP-018` | Divider | [`divider.md`](02-components/divider.md) |
| `DS-COMP-019` | Button | [`button.md`](02-components/button.md) |
| `DS-COMP-020` | Checkbox | [`checkbox.md`](02-components/checkbox.md) |
| `DS-COMP-021` | Radio and radio group | [`radio.md`](02-components/radio.md) |
| `DS-COMP-022` | Switch | [`switch.md`](02-components/switch.md) |

## How a rule is written

A rule is a block whose **first token is its ID**, followed by ` - ` and a title. That
is what makes an ID greppable and a citation resolvable by search, and it is the only
part of the formatting this directory enforces. Two carriers are canonical:

- **As a section**, when the rule stands alone:
  `## DS-A11Y-061 - Activation keys`.
- **As a bold lead**, when it lives inside a section: `**DS-API-019-01** - A disabled
  button MUST be a null callback`.

The heading form is used by the constitution, the accessibility contract and its
siblings, the integration files and the process files. The bold form is used by the
foundations and by every component spec, where rules sit inside the template's
sections. An ID that appears only inside a sentence is a citation, not a rule, and
[`07-traceability/rules.md`](07-traceability/rules.md) will not find it.

## The map

| File | What it binds |
| --- | --- |
| [`00-constitution.md`](00-constitution.md) | The twelve invariants. Everything else is detail under them |
| [`01-foundations/tokens.md`](01-foundations/tokens.md) | Three layers, one owner each; provenance and generation |
| [`01-foundations/colour.md`](01-foundations/colour.md) | Roles, the nine-step ramp, solid pairs, tag families |
| [`01-foundations/typography.md`](01-foundations/typography.md) | `Nunito Sans`, the ten sizes, the hierarchy |
| [`01-foundations/geometry.md`](01-foundations/geometry.md) | Spacing, radius, control, strokes |
| [`01-foundations/motion.md`](01-foundations/motion.md) | What moves, how fast, and when it must not |
| [`02-components/README.md`](02-components/README.md) | The axis matrix and the coverage status of each component |
| [`02-components/_template.md`](02-components/_template.md) | The required shape of a component spec |
| [`03-accessibility/contract.md`](03-accessibility/contract.md) | The thresholds, by section. The referent of every `AE-nn` |
| [`03-accessibility/exception-register.md`](03-accessibility/exception-register.md) | What is recorded and not asserted, and why |
| [`03-accessibility/keyboard-and-focus.md`](03-accessibility/keyboard-and-focus.md) | Focus model, ring, order, composite controls |
| [`04-integration/consuming.md`](04-integration/consuming.md) | Install, entry point, what the app must supply |
| [`04-integration/theming.md`](04-integration/theming.md) | Light and dark, overriding, nesting |
| [`04-integration/versioning.md`](04-integration/versioning.md) | Semantic versioning and the deprecation window |
| [`04-integration/migration.md`](04-integration/migration.md) | Every breaking change, old value to new |
| [`05-process/contribution.md`](05-process/contribution.md) | Adding or changing a component |
| [`05-process/verification.md`](05-process/verification.md) | What CI enforces and what only a local run can |
| [`05-process/definition-of-done.md`](05-process/definition-of-done.md) | The checklist a PR must satisfy |
| [`06-decisions/README.md`](06-decisions/README.md) | Index of ADRs |
| [`07-traceability/rules.md`](07-traceability/rules.md) | Every rule, mapped to the test that enforces it |
| [`07-traceability/open-items.md`](07-traceability/open-items.md) | The pending list the code has been citing since 0.3.0 |

## Status of this suite

Written against `lumiere_ui` `0.7.0`, verified on 2026-10-20 with `flutter analyze`
clean, 122 non-golden tests and 7 goldens green, and `flutter pub publish --dry-run`
reporting zero warnings.

Each spec describes **what the code does today**, not an aspiration. Where the code
and the intent disagree, the spec says so in a `Status` line and the disagreement
gets an `OPEN-nn` entry. A spec that reads as clean while the code misbehaves is
worth less than no spec at all: it manufactures confidence.

## Adding to this directory

1. A new component gets `02-components/<name>.md` from
   [`_template.md`](02-components/_template.md), a `DS-COMP-nnn` number from the
   table above, and a row in the axis matrix.
2. A new normative rule gets an ID from its namespace, a line in
   [`07-traceability/rules.md`](07-traceability/rules.md), and either a test that
   fails when the rule is broken or an `OPEN-nn` entry.
3. A lasting design decision gets an ADR. A transient one belongs in the PR.

Specifications are versioned with the package and published in the repository, not
in the pub archive: consumers read
[`04-integration/`](04-integration/) through the README, which mirrors the
guarantees that matter to them.
