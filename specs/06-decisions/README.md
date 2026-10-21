# 06 - Decisions

The decisions that outlived the pull request that made them. Each one records what
was chosen, what it cost, and the option that was discarded; a future maintainer who
wants to undo one is expected to argue with the record, not to rediscover it.

| ADR | Title | Status | Specs affected | Consequence in one line |
| --- | --- | --- | --- | --- |
| [`ADR-0001`](adr-0001-three-token-layers.md) | Three token layers | Accepted | `DS-TOK-*`, `DS-COL-*` | The generated layer can be re-cut without touching a component, at the price of a hand-maintained mapping that drifts and a generator that lives elsewhere. |
| [`ADR-0002`](adr-0002-state-as-widget-state.md) | State as widget state | Accepted | `DS-CONST-05`, `DS-API-*` | A caller cannot describe a state the widget is not in, and no test can render one without driving real input. |
| [`ADR-0003`](adr-0003-own-painters-over-material.md) | Own painters over Material | Accepted | `DS-COMP-020`, `DS-COMP-021`, `DS-COMP-022`, `DS-COMP-012` | The measured geometry and the focus ring are exactly the design's, and roughly 1,400 lines of widget code are ours to get right. |
| [`ADR-0004`](adr-0004-goldens-verified-locally.md) | Goldens verified locally | Accepted | `PRC-*`, `OPEN-08`, `OPEN-14` | The visual contract is asserted at pixel level, and nowhere a pull request can observe it. |
| [`ADR-0005`](adr-0005-icon-and-typeface-agnostic.md) | Icon and typeface agnostic | Accepted | `INT-*`, `DS-COMP-017` | There is no font or icon set to keep in step, and a consumer who forgets the typeface gets a system that looks approximately right. |
| [`ADR-0006`](adr-0006-raw-radio-from-the-sdk.md) | Raw radio from the SDK | Accepted | `DS-COMP-021`, `INT-*` | Selection semantics come from the SDK instead of being rebuilt, on an API young enough to break with a Flutter upgrade. |
| [`ADR-0007`](adr-0007-family-is-theme-scoped.md) | Family is theme-scoped | Accepted | `DS-TYPE-001`, `INT-004`, `INT-013`, `OPEN-26`, `OPEN-27` | Any product can own its typeface with one argument, at the price of a hand-applied edit to the generated file and a weight axis that does not fit Flutter's nine slots. |

ADR-0001 to ADR-0006 are dated 2026-10-16, the date this suite was written; where the
code predates that date, the ADR records the decision it was already following rather
than a change made to satisfy the spec. ADR-0007 is dated 2026-10-20, the day the
family changed.

All seven are `Accepted`.

## When a decision MUST become an ADR

Three tests, any one of which is sufficient. It outlives the pull request: the code
will still be shaped by it after the branch is gone. It has a cost someone will
question: the review raised it, or a maintainer will ask "why not the obvious way".
Or it discards an option a future maintainer will reach for, so the reasoning has to
survive in a place people read before arguing.

The decision to draw a checkbox with a `CustomPainter` fails none of these and is an
ADR; the decision to name a private helper `_TickGeometry` is a convention and is
recorded in the code.

## When a decision MUST NOT become an ADR

A transient implementation choice: which file a painter lives in, which widget
composites which, the order of two branches, a local workaround with a date on it.
Writing those down produces a directory nobody reads, which is how the seven that
matter get lost.

## What an ADR is not

It is not a design document, a tutorial or a place to argue. The six sections are
fixed: `Context`, `Decision`, `Consequences`, `Alternatives considered`,
`References`. It names at least one real negative consequence and at least one
discarded alternative; an ADR whose consequences are all positive is marketing, and
is sent back. It is not edited after acceptance: a decision that changes is a new
ADR whose `Status` line supersedes the old one.
