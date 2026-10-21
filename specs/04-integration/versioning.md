# 04 - Versioning

Semantic versioning for a design system, and the current state of the record.

A design system breaks in a way a library does not: moving a colour by two steps
keeps every signature intact and still invalidates every screenshot, every contrast
audit and every design review an application has already done. This file defines
what counts as breaking here, and what the record of a release must contain.

---

## INT-016 - The scheme

The package follows Semantic Versioning, is pre-1.0, and MUST stay pre-1.0 until the
component set, the axis vocabulary and the token layer have stopped moving.

Under `0.x`, the caret behaves differently from the way most people read it:
`^0.6.0` allows `>=0.6.0 <0.7.0`. An application that writes `^0.6.0` will therefore
**not** receive a breaking `0.7.0`. It will also not receive a fix to `0.6.0`
unless the package publishes `0.6.1`; a fix published as part of `0.7.0` reaches
nobody who pinned the minor.

---

## INT-017 - What counts as breaking

A change is breaking, and MUST be released as a new minor while pre-1.0, when it:

| Change | Breaking because |
| --- | --- |
| Any change to a rendered colour, size, radius or stroke | Every screenshot, golden and design review an application has is now wrong |
| Any change to a control's measured height or padding | Layouts built against the old geometry reflow |
| Removing or renaming a constructor parameter, enum value or exported symbol | Compile error, at best |
| Adding a required constructor parameter | Compile error for every call site |
| Changing a token's value such that a contrast pair moves | An audit that passed yesterday fails today, silently |
| Changing the semantics tree (role, name source, exposed state) | Assistive technology behaviour changes without a visual signal |
| Renaming an exported class, even keeping an alias | Every import in every application |

A change that is **not** breaking, and therefore a patch: a documentation
correction, a test, a performance improvement that does not move a pixel, or an
added optional parameter with a default that preserves the current rendering.

---

## INT-018 - A release must be reconstructable from its record

For every version, the record MUST contain:

1. A `CHANGELOG.md` entry in Keep a Changelog form, with `Added`,
   `Changed (breaking)` and `Removed` sections, and a `Notes` section for the
   decisions and the measurements behind the values.
2. A git tag `v<version>` on the commit that set `pubspec.yaml`'s `version` to that
   number.
3. A migration entry in [`migration.md`](migration.md) for every breaking change,
   naming the old value, the new value and the reason.
4. The version in `pubspec.yaml`, the tag and the CHANGELOG heading all agreeing.

Two of the six releases do not satisfy this today - **OPEN-19**. The concrete
symptoms: `pubspec.yaml` says `0.6.0` while the newest tag is `v0.2.0`, four
releases are untagged, and at least one shipped fix - the light danger pair moving
to white - has no CHANGELOG line in any version, because it landed between two
version commits.

---

## INT-019 - Deprecation

A symbol that is going to be removed MUST first be annotated `@Deprecated`, with a
message naming the replacement, and MUST survive at least one minor release in that
state before removal.

The package has no `@Deprecated` annotation today, so this rule has never been
exercised. It is stated now, before the first removal, because a deprecation window
declared after the fact is not a window.

Removal of a deprecated symbol is still breaking, and still needs an `INT-018`
entry: a deprecation window only converts a surprise into an announcement.

---

## INT-020 - The commit convention that feeds the record

Commits use Conventional Commits with `!` marking a breaking change:
`feat!:`, `feat:`, `fix:`, `docs:`, `chore:`. The subject line states the change and
its consequence, and the version it belongs to is decided once per release rather
than per commit.

A `fix:` commit that changes a rendered value is not a `fix:` - it is a visible
change and MUST be released as one. The distinction exists because a `fix:` reads
as "safe to adopt" to everyone who reads the log.

---

## INT-021 - The published archive

`flutter pub publish --dry-run` runs in CI and MUST report zero warnings. The
archive currently contains:

| Content | Size |
| --- | --- |
| `lib/`, `example/`, `test/`, docs, config | ~57 KB |
| Seven golden baselines under `test/golden/goldens/` | ~65 KB |
| Total, compressed | 122 KB |

A consumer of the library has no use for the golden baselines, which are a test
fixture and are already versioned in the repository - **OPEN-20**. The gallery is
correctly excluded through `.pubignore`; `specs/` MUST be excluded too, for the same
reason: a consumer reads `04-integration/` through the README, not through a 30-file
specification suite.

---

## INT-022 - What a consumer must pin

An application MUST pin the package to a minor and MUST NOT use `any` or an
unpinned git `ref`. While pre-1.0 a minor is the breaking unit (INT-016), so a pin
is the only thing standing between an application and a silently re-themed UI.

For a git dependency, pin a commit SHA rather than `ref: main` once the application
is past prototyping: a branch moves without a version number, which is the one thing
semantic versioning cannot protect against.

---

## Status

The scheme, the breaking-change taxonomy, the CHANGELOG shape, the Conventional
Commits convention and the publish check are all real and in use.

The record is not: four releases are untagged and one shipped fix has no CHANGELOG
line. No deprecation has ever been performed, so INT-019 is untested practice.

## Open items

- **OPEN-19** - Version drift: `pubspec.yaml` at `0.6.0`, tags only up to `v0.2.0`, README pinning `^0.2.0`, and at least one shipped change with no CHANGELOG entry.
- **OPEN-20** - The pub archive ships the seven golden baselines, most of its 122 KB.
