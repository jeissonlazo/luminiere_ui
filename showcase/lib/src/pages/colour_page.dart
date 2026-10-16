import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/doc_page.dart';
import '../widgets/swatch.dart';

/// The colour layer: the semantic roles a component is allowed to read.
class ColourPage extends StatelessWidget {
  const ColourPage({super.key});

  static const double _swatchWidth = 132;
  static const double _swatchHeight = 44;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return DocPage(
      title: 'Colour',
      lead: 'Three layers, each with a different owner. Components read the '
          'semantic roles, never the palette, so a palette change cannot leak '
          'into a component and a component cannot invent a colour.',
      ruleId: 'DS-COLOR-048',
      children: <Widget>[
        const Callout(
          title: 'The raw palette is deliberately not exported',
          body: 'Only LumiereColors, the tag families and the scales leave the '
              'package. ArcoPaletteDark and ArcoPaletteLight stay private, so '
              'a consumer cannot reach a palette step by name and bypass the '
              'semantic layer.',
        ),

        DocSection(
          title: 'Surfaces',
          description: 'The four background levels. Values shown are the ones '
              'in the theme currently rendered: switch the theme in the header '
              'to read the other mode.',
          children: <Widget>[
            SwatchGroup(
              title: 'Background levels',
              note: 'bg.1 is the page, bg.2 the first container, bg.3 a raised '
                  'panel and bg.5 the dropdown and tooltip surface.',
              children: <Widget>[
                Swatch(
                  name: 'surfaceBase',
                  color: colors.surfaceBase,
                  note: 'bg.1',
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
                Swatch(
                  name: 'surfaceContainer',
                  color: colors.surfaceContainer,
                  note: 'bg.2',
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
                Swatch(
                  name: 'surfaceRaised',
                  color: colors.surfaceRaised,
                  note: 'bg.3',
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
                Swatch(
                  name: 'surfaceOverlay',
                  color: colors.surfaceOverlay,
                  note: 'bg.5',
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
              ],
            ),
          ],
        ),

        DocSection(
          title: 'Text',
          description: 'A text colour cannot be judged from a rectangle, so '
              'each role is drawn as type on the container it is specified '
              'against.',
          children: <Widget>[
            Wrap(
              spacing: ArcoSpace.spaceMd,
              runSpacing: ArcoSpace.spaceMd,
              children: <Widget>[
                InkSwatch(
                  name: 'textPrimary',
                  color: colors.textPrimary,
                  width: 232,
                ),
                InkSwatch(
                  name: 'textSecondary',
                  color: colors.textSecondary,
                  width: 232,
                ),
                InkSwatch(
                  name: 'textTertiary',
                  color: colors.textTertiary,
                  width: 232,
                ),
                InkSwatch(
                  name: 'textDisabled',
                  color: colors.textDisabled,
                  width: 232,
                ),
                InkSwatch(
                  name: 'textOnAccent',
                  color: colors.textOnAccent,
                  background: colors.accent.normal,
                  width: 232,
                ),
              ],
            ),
          ],
        ),

        DocSection(
          title: 'Borders',
          children: <Widget>[
            Wrap(
              spacing: ArcoSpace.spaceMd,
              runSpacing: ArcoSpace.spaceMd,
              children: <Widget>[
                Swatch(
                  name: 'borderSubtle',
                  color: colors.borderSubtle,
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
                Swatch(
                  name: 'borderDefault',
                  color: colors.borderDefault,
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
                Swatch(
                  name: 'borderStrong',
                  color: colors.borderStrong,
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
                Swatch(
                  name: 'borderHeavy',
                  color: colors.borderHeavy,
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
              ],
            ),
          ],
        ),

        DocSection(
          title: 'Fills',
          description: 'Translucent overlays used for the hover and pressed '
              'states of a neutral surface. They are drawn here over the page '
              'background, which is where a neutral control usually sits.',
          children: <Widget>[
            Wrap(
              spacing: ArcoSpace.spaceMd,
              runSpacing: ArcoSpace.spaceMd,
              children: <Widget>[
                Swatch(
                  name: 'fillSubtle',
                  color: colors.fillSubtle,
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
                Swatch(
                  name: 'fillDefault',
                  color: colors.fillDefault,
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
                Swatch(
                  name: 'fillStrong',
                  color: colors.fillStrong,
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
                Swatch(
                  name: 'fillHeavy',
                  color: colors.fillHeavy,
                  width: _swatchWidth,
                  height: _swatchHeight,
                ),
              ],
            ),
          ],
        ),

        DocSection(
          title: 'Status ramps',
          description: 'Four families, each with the same nine roles. This is '
              'what LumiereStatusColors carries, and what a Button resolves its '
              'kind through.',
          children: <Widget>[
            for (final (String name, LumiereStatusColors ramp) in <(
              String,
              LumiereStatusColors,
            )>[
              ('accent', colors.accent),
              ('success', colors.success),
              ('warning', colors.warning),
              ('danger', colors.danger),
            ]) ...<Widget>[
              _RampGroup(name: name, ramp: ramp),
              const SizedBox(height: ArcoSpace.spaceXl),
            ],
          ],
        ),

        DocSection(
          title: 'Why a family has both normal and onSubtle',
          children: <Widget>[
            const Callout(
              title: 'Two steps, because one does not reach 4.5:1',
              body: 'normal is the decorative fill. It measures below the '
                  'contrast the accessibility contract requires for text on '
                  'its own subtle background in the light theme, so onSubtle '
                  'carries a darker step for that use. The step is measured, '
                  'not chosen by eye; the contract records it as exception '
                  'AE-11.',
              tone: CalloutTone.warning,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'solidFill and solidLabel are a pair on purpose',
              body: 'A solid control must not choose its fill and its label '
                  'independently, so the token layer publishes them together '
                  'and the level-1 accessibility test asserts the pair across '
                  'all four families in both themes.',
              tone: CalloutTone.success,
            ),
          ],
        ),

        DocSection(
          title: 'Tag colour families',
          description: 'Eleven families, each with the soft background of the '
              'filled form, the stronger background of the bordered form and '
              'the ink of its text and icon. The names are the design file\'s '
              'own axis options; the design calls the first one default.',
          children: <Widget>[
            for (final LumiereTagColorName name in LumiereTagColorName.values)
              Padding(
                padding: const EdgeInsets.only(bottom: ArcoSpace.spaceMd),
                child: _TagFamilyRow(name: name, family: colors.tag(name)),
              ),
          ],
        ),

        DocSection(
          title: 'Dark against light',
          description: 'The two modes side by side, read from LumiereColors '
              'directly rather than from the live theme, so this block does '
              'not change when the theme is switched.',
          children: <Widget>[
            for (final (String label, Color dark, Color light)
                in <(String, Color, Color)>[
              (
                'surfaceBase',
                LumiereColors.dark.surfaceBase,
                LumiereColors.light.surfaceBase,
              ),
              (
                'surfaceContainer',
                LumiereColors.dark.surfaceContainer,
                LumiereColors.light.surfaceContainer,
              ),
              (
                'surfaceRaised',
                LumiereColors.dark.surfaceRaised,
                LumiereColors.light.surfaceRaised,
              ),
              (
                'textPrimary',
                LumiereColors.dark.textPrimary,
                LumiereColors.light.textPrimary,
              ),
              (
                'textSecondary',
                LumiereColors.dark.textSecondary,
                LumiereColors.light.textSecondary,
              ),
              (
                'borderSubtle',
                LumiereColors.dark.borderSubtle,
                LumiereColors.light.borderSubtle,
              ),
              (
                'accent.normal',
                LumiereColors.dark.accent.normal,
                LumiereColors.light.accent.normal,
              ),
              (
                'accent.solidFill',
                LumiereColors.dark.accent.solidFill,
                LumiereColors.light.accent.solidFill,
              ),
              (
                'danger.normal',
                LumiereColors.dark.danger.normal,
                LumiereColors.light.danger.normal,
              ),
              (
                'success.solidFill',
                LumiereColors.dark.success.solidFill,
                LumiereColors.light.success.solidFill,
              ),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: ArcoSpace.spaceSm),
                child: _DualRow(label: label, dark: dark, light: light),
              ),
            const SizedBox(height: ArcoSpace.spaceXs),
            const Callout(
              title: 'The brand blue differs between the two modes',
              body: 'The dark mode uses a customised #3C7EFF while the light '
                  'mode keeps Arco\'s original #165DFF. That difference comes '
                  'straight from the variables export and is not an oversight.',
            ),
          ],
        ),
      ],
    );
  }
}

/// One status family: its nine roles, wrapped.
class _RampGroup extends StatelessWidget {
  const _RampGroup({required this.name, required this.ramp});

  final String name;
  final LumiereStatusColors ramp;

  @override
  Widget build(BuildContext context) {
    return SwatchGroup(
      title: name,
      children: <Widget>[
        for (final (String role, Color value) in <(String, Color)>[
          ('subtle', ramp.subtle),
          ('normal', ramp.normal),
          ('hover', ramp.hover),
          ('active', ramp.active),
          ('disabled', ramp.disabled),
          ('textDisabled', ramp.textDisabled),
          ('solidFill', ramp.solidFill),
          ('solidLabel', ramp.solidLabel),
          ('onSubtle', ramp.onSubtle),
        ])
          Swatch(
            name: role,
            color: value,
            width: ColourPage._swatchWidth,
            height: ColourPage._swatchHeight,
          ),
      ],
    );
  }
}

/// One tag family: the three colours the design gives it.
class _TagFamilyRow extends StatelessWidget {
  const _TagFamilyRow({required this.name, required this.family});

  final LumiereTagColorName name;
  final LumiereTagColor family;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 156,
          child: Padding(
            padding: const EdgeInsets.only(top: ArcoSpace.spaceXs),
            child: Text(
              name.name,
              style: tokens.mono(
                ArcoType.size12,
                color: tokens.colors.textPrimary,
              ),
            ),
          ),
        ),
        for (final (String role, Color value) in <(String, Color)>[
          ('subtle', family.subtle),
          ('strong', family.strong),
          ('ink', family.ink),
        ]) ...<Widget>[
          Swatch(
            name: role,
            color: value,
            width: 132,
            height: 40,
          ),
          const SizedBox(width: ArcoSpace.spaceMd),
        ],
      ],
    );
  }
}

/// The same role in both themes.
class _DualRow extends StatelessWidget {
  const _DualRow({
    required this.label,
    required this.dark,
    required this.light,
  });

  final String label;
  final Color dark;
  final Color light;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    Widget box(Color color) => Container(
          width: 96,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(ArcoRadius.radiusSm),
            border: Border.all(color: tokens.colors.borderDefault),
          ),
        );

    Widget hex(Color color) => Text(
          GalleryTextStyles.hex(color),
          style: tokens.mono(
            ArcoType.size10,
            color: tokens.colors.textTertiary,
          ),
        );

    return Row(
      children: <Widget>[
        SizedBox(
          width: 156,
          child: Text(
            label,
            style: tokens.mono(
              ArcoType.size12,
              color: tokens.colors.textPrimary,
            ),
          ),
        ),
        box(dark),
        const SizedBox(width: ArcoSpace.spaceSm),
        SizedBox(width: 92, child: hex(dark)),
        const SizedBox(width: ArcoSpace.spaceMd),
        box(light),
        const SizedBox(width: ArcoSpace.spaceSm),
        hex(light),
      ],
    );
  }
}
