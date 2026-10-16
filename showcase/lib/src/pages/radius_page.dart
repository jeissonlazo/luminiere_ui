import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/doc_page.dart';

/// Corner radii, and the measured geometry of every control size.
class RadiusPage extends StatelessWidget {
  const RadiusPage({super.key});

  static const List<(String, double)> _radii = <(String, double)>[
    ('radiusSm', ArcoRadius.radiusSm),
    ('radiusMd', ArcoRadius.radiusMd),
    ('radiusLg', ArcoRadius.radiusLg),
    ('radiusFull', ArcoRadius.radiusFull),
  ];

  /// Size name, control height and horizontal padding, from [ArcoControl].
  ///
  /// The order follows `LumiereButtonSize.values`, so the table reads as the
  /// enum does.
  static const List<(String, double, double)> _controls =
      <(String, double, double)>[
    ('large', ArcoControl.heightLarge, ArcoControl.paddingLarge),
    ('medium', ArcoControl.heightMedium, ArcoControl.paddingMedium),
    ('small', ArcoControl.heightSmall, ArcoControl.paddingSmall),
    ('mini', ArcoControl.heightMini, ArcoControl.paddingMini),
  ];

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return DocPage(
      title: 'Radius and controls',
      lead: 'The radius scale, and the height and horizontal padding every '
          'control of a given size carries. Both are measured from the design '
          'geometry rather than chosen, and both are what keeps four sizes of '
          'the same control aligned with each other.',
      ruleId: 'DS-RADIUS-001',
      children: <Widget>[
        DocSection(
          title: 'Corner radii',
          description: 'Four steps. radiusFull is a sentinel rather than a '
              'measurement: the corner clamps to half the shorter side, which '
              'is what produces a pill or a circle.',
          children: <Widget>[
            Wrap(
              spacing: ArcoSpace.spaceMd,
              runSpacing: ArcoSpace.spaceMd,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: <Widget>[
                for (final (String name, double value) in _radii)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 116,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.accent.normal,
                          borderRadius: BorderRadius.circular(value),
                        ),
                      ),
                      const SizedBox(height: ArcoSpace.spaceSm),
                      Text(
                        name,
                        style: tokens.primary(
                          ArcoType.size12,
                          weight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${value.toInt()} px',
                        style: tokens.tertiary(ArcoType.size10),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'The scale is derived from usage, not declared',
              body: 'It comes from counting cornerRadius across the file: 2 '
                  'dominates by a wide margin, then 8 and 4. A radius of 24 '
                  'also appears often and may belong to larger containers, so '
                  'it is left out pending confirmation.',
            ),
          ],
        ),

        DocSection(
          title: 'Control geometry',
          ruleId: 'DS-CONTROL-001',
          description: 'Height and horizontal padding per size, with a real '
              'button of that size beside the numbers. The padding is part of '
              'the size, not something a caller adds.',
          children: <Widget>[
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int i = 0; i < _controls.length; i++) ...<Widget>[
                    if (i > 0)
                      Container(height: 1, color: colors.borderSubtle),
                    Padding(
                      padding: const EdgeInsets.all(ArcoSpace.spaceMd),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 92,
                            child: Text(
                              _controls[i].$1,
                              style: tokens.mono(
                                ArcoType.size12,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 76,
                            child: Text(
                              'h ${_controls[i].$2.toInt()}',
                              style: tokens.secondary(ArcoType.size12),
                            ),
                          ),
                          SizedBox(
                            width: 76,
                            child: Text(
                              'p ${_controls[i].$3.toInt()}',
                              style: tokens.secondary(ArcoType.size12),
                            ),
                          ),
                          const SizedBox(width: ArcoSpace.spaceSm),
                          LumiereButton(
                            label: _controls[i].$1,
                            size: _buttonSize(_controls[i].$1),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'Measured with zero variance',
              body: 'Thirty variants per size, and every one agreed: 36 / 32 / '
                  '28 / 24 tall, with 20 / 16 / 16 / 12 of horizontal padding. '
                  'The measurement comes from the Arco kit geometry because the '
                  'Figma account was rate limited, and it matches the values '
                  'the tokens already carried.',
              tone: CalloutTone.success,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'Two of the paddings forced the spacing scale open',
              body: '12 and 20 did not exist on the 4 / 8 / 16 / 24 scale the '
                  'design file declares. Rather than round a measured value, '
                  'the scale was reapproved as 4 / 8 / 12 / 16 / 20; see the '
                  'Spacing page.',
            ),
          ],
        ),
      ],
    );
  }

  static LumiereButtonSize _buttonSize(String name) => switch (name) {
        'large' => LumiereButtonSize.large,
        'medium' => LumiereButtonSize.medium,
        'small' => LumiereButtonSize.small,
        _ => LumiereButtonSize.mini,
      };
}
