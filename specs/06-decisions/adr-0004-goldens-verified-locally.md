# ADR-0004 - Goldens verified locally

- Status: Accepted
- Date: 2026-10-16
- Specs affected: `PRC-*`, `OPEN-08`, `OPEN-14`

## Context

The goldens are the verification of the visual contract: one baseline per component, laying
its variants and states out in a labelled matrix. Rasterisation differs between operating
systems, and a baseline produced on one does not match the same pixels rendered on another.
The alternative is a widget assertion that describes a colour and never sees the layout it
lands in.

## Decision

The goldens run only where the baseline was produced: Windows, the reference operating system.
`ci.yml` excludes them with `--exclude-tags=golden`, and `flutter test --update-goldens` on
Windows is the only way a baseline changes. The tag is declared in
[`dart_test.yaml`](../../dart_test.yaml) and is not skipped there.

## Consequences

### Positive

- The visual contract is asserted at pixel level somewhere, across every variant and state in one image per component.
- A matrix baseline is one file to open, not one per combination, so a visual change is read in a single look.
- Regeneration is one command, and the command is the review request.

### Negative

- The visual oracle is one machine: a regression is discovered by whoever next runs the tests on Windows, which may be weeks later and may be nobody.
- Nothing validates a golden in a pull request - `ci.yml` excludes them and `pages.yml` does not read the package's `test/golden/` at all (OPEN-14).
- The tag is declared but not skipped, so a bare `flutter test` on Linux or macOS fails on the baselines and pressures a contributor to regenerate images they cannot review.
- Two baselines encode a hybrid panel no theme produces: the divider and loading goldens paint a light background without a light `Theme` (OPEN-08). A green golden cannot reveal that, because it records whatever was drawn.

## Alternatives considered

- **Run the goldens in CI on Linux and regenerate the baselines there.** One portable oracle, moved from the machine where the components were reviewed to one nobody looks at.
- **Pin every font, device pixel ratio and text scale so a baseline becomes portable.** The closest thing to a real solution; it removes the platform from the picture and adds a harness whose own failures look like visual regressions.
- **Drop the goldens and keep widget assertions.** A colour and a size asserted separately, with nothing asserting that they land in the right place.

## References

- [`dart_test.yaml`](../../dart_test.yaml), [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)
- [`test/golden/`](../../test/golden/)
- [`05-process/verification.md`](../05-process/verification.md)
