# ADR-0001 - Three token layers

- Status: Accepted
- Date: 2026-10-16
- Specs affected: `DS-TOK-*`, `DS-COL-*`

## Context

The colour layer is a variables export from the Figma file `E6OUz1aF3tykVnr341r6fl`: 396
generated constants across `ArcoPalette*`, `ArcoSemantic*` and `ArcoComponent*`, for both
modes. The file also describes each token in role terms - "text.secondary",
"fill.secondary" - that no generated identifier expresses. The three populations have
different owners and lifetimes: the export is replaced when the file is re-cut, the roles
survive that, and the scales change with neither.

## Decision

Three layers, one owner each.

1. **Generated primitives.** `ArcoPalette*`, `ArcoSemantic*`, `ArcoComponent*`: the 396 colour constants, both modes, generated into [`tokens.g.dart`](../../lib/src/tokens/tokens.g.dart) from the variables export.
2. **Hand-written semantic roles.** `LumiereColors`, `LumiereStatusColors`, `LumiereTagColor`: about 60 roles mapped to primitives, from the description the file attaches to each token.
3. **Mode-independent scales.** `ArcoType`, `ArcoSpace`, `ArcoRadius`, `ArcoControl`, `ArcoTag`, `LumiereStrokes`.

Components read layer 2 and the scales and nothing else. Layer 1 is not exported from
[`lib/lumiere_ui.dart`](../../lib/lumiere_ui.dart), so a primitive in a component is both a
review failure and an import error (`DS-CONST-03`).

## Consequences

### Positive

- Re-cutting the design file renames layer 1 and stops there: no component compiles against a palette constant, so none breaks.
- No component decides a hexadecimal value, which makes both themes one mapping instead of a repaint.
- The barrel publishes a surface a consumer can learn, while the replaceable layer stays private.

### Negative

- Layer 2 is maintained by hand and can drift: a token renamed in Figma is a stale role here until somebody notices, and nothing fails.
- Regeneration needs a generator that does not live in this repository (OPEN-07): `design/` and `node design/tools/build-tokens.mjs` do not exist here, while 16 code references point into that tree.
- 396 generated constants plus about 60 hand-written roles is more surface than a seven-component system needs; chasing one colour crosses three layers.

## Alternatives considered

- **A single flat token file.** Every constant named for its role, and every palette re-cut becomes a rename across every component.
- **Components reference palette constants directly.** No mapping layer, therefore no drift - and the generated layer becomes the public API, so every future export is breaking.
- **Generate the semantic layer too.** The role descriptions are in the file, so the mapping could be generated; it would need a generator that parses prose, and a wrong guess would be invisible in the output.

## References

- [`01-foundations/tokens.md`](../01-foundations/tokens.md), [`colour.md`](../01-foundations/colour.md)
- [`lib/src/tokens/lumiere_tokens.dart`](../../lib/src/tokens/lumiere_tokens.dart)
- [`README.md`](../../README.md), section "Token layers"
