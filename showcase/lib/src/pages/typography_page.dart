import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/doc_page.dart';
import '../widgets/example_card.dart';

/// The type scale the design declares on its `Basic styles` page.
class TypographyPage extends StatelessWidget {
  const TypographyPage({super.key});

  /// Rule, size and the weights the design pairs with it.
  ///
  /// The size and the line height come from [ArcoType], so the page cannot
  /// disagree with the token layer; the weights are quoted from the rule table
  /// of `design-constraints.md`.
  static const List<(String, double, String)> _scale =
      <(String, double, String)>[
    ('DS-TYPE-001', ArcoType.size10, '400, 600'),
    ('DS-TYPE-002', ArcoType.size12, '400, 500, 600'),
    ('DS-TYPE-003', ArcoType.size13, '400, 500, 600'),
    ('DS-TYPE-004', ArcoType.size14, '400, 500, 600, 700'),
    ('DS-TYPE-005', ArcoType.size16, '400, 500, 600'),
    ('DS-TYPE-006', ArcoType.size20, '400, 500, 600'),
    ('DS-TYPE-007', ArcoType.size24, '400, 500, 600'),
    ('DS-TYPE-008', ArcoType.size36, '400, 500, 600'),
    ('DS-TYPE-009', ArcoType.size48, '400, 500, 600'),
    ('DS-TYPE-010', ArcoType.size56, '400, 500, 600'),
  ];

  static const String _specimen =
      'The quick brown fox jumps over the lazy dog';

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;
    final double lineHeight = ArcoType.lineHeightFor(ArcoType.size14) ?? 0;

    return DocPage(
      title: 'Typography',
      lead: 'Ten sizes, each with the line height the design file pairs with '
          'it. Components never write a size: they read ArcoType, and a size '
          'that is not in the scale is a gap rather than a value to guess.',
      ruleId: 'DS-TYPE-001',
      children: <Widget>[
        DocSection(
          title: 'Scale',
          description: 'Each specimen is rendered at the real size with the '
              'default weight of 400. The metadata column gives the rule, the '
              'size and line height in pixels, and the weights the design '
              'declares for that size.',
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
                  for (int i = 0; i < _scale.length; i++) ...<Widget>[
                    if (i > 0)
                      Container(height: 1, color: colors.borderSubtle),
                    _TypeRow(
                      rule: _scale[i].$1,
                      size: _scale[i].$2,
                      weights: _scale[i].$3,
                      specimen: _specimen,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            Callout(
              title: 'The line height is a token, not a multiplier',
              body: 'The design pairs an absolute line height with every size, '
                  'so the ratio is not constant: 10/18 is loose, 56/64 is '
                  'tight. ArcoType.lineHeightFor(${ArcoType.size14.toInt()}) '
                  'returns ${lineHeight.toInt()}, which is the ${(lineHeight / ArcoType.size14).toStringAsFixed(2)} '
                  'ratio the theme applies to body text.',
            ),
          ],
        ),

        DocSection(
          title: 'Weights',
          description: 'The four weights the scale declares. The family has no '
              'semibold, so w600 is drawn with Bold: the last two rows are the '
              'same face, and nothing is synthesized.',
          children: <Widget>[
            ExampleCard(
              previewAlignment: Alignment.centerLeft,
              code: '''
Text('Mark Pro', style: tokens.text(
  size: ArcoType.size14,
  weight: FontWeight.w600,
))''',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (String label, FontWeight weight)
                      in <(String, FontWeight)>[
                    ('w400 regular', FontWeight.w400),
                    ('w500 medium', FontWeight.w500),
                    ('w600 -> bold', FontWeight.w600),
                    ('w700 bold', FontWeight.w700),
                  ])
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: ArcoSpace.spaceSm),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 120,
                            child: Text(
                              label,
                              style: tokens.tertiary(ArcoType.size12),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _specimen,
                              overflow: TextOverflow.ellipsis,
                              style: tokens.primary(
                                ArcoType.size20,
                                weight: weight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Family',
          ruleId: 'DS-TYPE-001',
          children: <Widget>[
            const Callout(
              title: 'Mark Pro is licensed, and the package does not ship it',
              body: 'The design declares Mark Pro (latin) as the family, and it '
                  'is an application concern rather than a library one: the '
                  'package sets the family name and redistributes no typeface. '
                  'This gallery bundles its own licensed copy under '
                  '`fonts/MarkPro/`, which stays out of the published archive. '
                  'A consumer registers its own family in `pubspec.yaml` and '
                  'passes the name to `LumiereThemeData.dark(fontFamily: ...)`; '
                  'the declared family is only the default.',
              tone: CalloutTone.warning,
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.rule,
    required this.size,
    required this.weights,
    required this.specimen,
  });

  final String rule;
  final double size;
  final String weights;
  final String specimen;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;
    final double? lineHeight = ArcoType.lineHeightFor(size);

    return Padding(
      padding: const EdgeInsets.all(ArcoSpace.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 148,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  rule,
                  style: tokens.mono(
                    ArcoType.size10,
                    color: colors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${size.toInt()} / ${lineHeight?.toInt() ?? '-'} px',
                  style: tokens.secondary(ArcoType.size12),
                ),
                Text(
                  weights,
                  style: tokens.tertiary(ArcoType.size10),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              specimen,
              style: tokens.primary(size),
            ),
          ),
        ],
      ),
    );
  }
}
