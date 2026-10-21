# ADR-0006 - Raw radio from the SDK

- Status: Accepted
- Date: 2026-10-16
- Specs affected: `DS-COMP-021`, `INT-*`

## Context

A radio group must be one tab stop, move its selection with the arrow keys and expose itself
as a group to assistive technology. The SDK's `Radio` carries `groupValue`/`onChanged` for
that, and this Flutter version marks both deprecated in favour of `RadioGroup<T>`, which owns
the group's selection and hands each radio a `RadioGroupRegistry`. Building on the deprecated
pair would mean writing the group's navigation by hand and suppressing an analyzer warning on
every use.

## Decision

`LumiereRadioGroup<T>` wraps the SDK's `RadioGroup<T>`. `LumiereRadio<T>` is built on
`RawRadio<T>` plus a `RadioGroupRegistry`, not on `Radio`'s deprecated pairing. A radio used
outside a group supplies a private `_StandaloneRadioRegistry`, which registers no clients,
because `RawRadio` requires a registry whenever it is enabled.

## Consequences

### Positive

- The group's semantics - single tab stop, arrow navigation, Space to select - are the SDK's, not a reimplementation racing accessibility guidance.
- No deprecation is suppressed, so a future Flutter release does not turn an accepted warning into an error the package cannot fix quickly.
- A standalone radio and a grouped one share one implementation, so they cannot diverge in paint or in semantics.

### Negative

- The package depends on a young part of the SDK - `RawRadio`, `RadioGroupRegistry`, `RadioClient` - whose signature can change in an upgrade, and the dependency is invisible in [`pubspec.yaml`](../../pubspec.yaml) because it arrives with `flutter/material.dart` itself: an upgrade can break this package with no version constraint moving.
- The private registry must implement three members to satisfy an interface it barely uses: an empty client list and two no-op notifications.
- The group behaviour is only as correct as the SDK's, and the tests verify it indirectly - one tab stop, arrows, Space - rather than by construction.

## Alternatives considered

- **Keep `Radio` with `groupValue` and `onChanged`, and suppress the deprecation.** Ship today on an API with a removal date, and inherit a warning that becomes an error at the next major version.
- **Implement the group by hand.** Arrow keys, a roving tab stop, a `Semantics` container and the focus management, all ours - the argument behind [`ADR-0003`](adr-0003-own-painters-over-material.md), applied to behaviour, where the toolkit's version is more likely to be right.
- **Wait for the API to stabilise.** Correct and indefinite: the design file already declares the component, and 0.4.0 could not have shipped it.

## References

- [`02-components/radio.md`](../02-components/radio.md), [`03-accessibility/keyboard-and-focus.md`](../03-accessibility/keyboard-and-focus.md)
- [`lib/src/components/radio/lumiere_radio.dart`](../../lib/src/components/radio/lumiere_radio.dart)
- [`CHANGELOG.md`](../../CHANGELOG.md), 0.4.0
