import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/doc_page.dart';

/// The approved spacing scale.
class SpacingPage extends StatelessWidget {
  const SpacingPage({super.key});

  static const List<(String, double)> _steps = <(String, double)>[
    ('spaceXs', ArcoSpace.spaceXs),
    ('spaceSm', ArcoSpace.spaceSm),
    ('spaceMd', ArcoSpace.spaceMd),
    ('spaceLg', ArcoSpace.spaceLg),
    ('spaceXl', ArcoSpace.spaceXl),
  ];

  /// Pixels of bar per spacing pixel, so a 4 px step is still legible.
  static const double _barScale = 7;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return DocPage(
      title: 'Spacing',
      lead: 'Five steps, every one divisible by two. Components read them for '
          'padding and for the gaps between elements, so no component holds a '
          'spacing literal.',
      ruleId: 'DS-SPACE-001',
      children: <Widget>[
        DocSection(
          title: 'Steps',
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(ArcoSpace.spaceMd),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final (String name, double value) in _steps)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: ArcoSpace.spaceSm,
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 96,
                            child: Text(
                              name,
                              style: tokens.mono(
                                ArcoType.size12,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 56,
                            child: Text(
                              '${value.toInt()} px',
                              style: tokens.secondary(ArcoType.size12),
                            ),
                          ),
                          Container(
                            width: value * _barScale,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colors.accent.normal,
                              borderRadius:
                                  BorderRadius.circular(ArcoRadius.radiusSm),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: ArcoSpace.spaceXs),
                  Text(
                    'Bars are drawn at $_barScale px per spacing pixel.',
                    style: tokens.tertiary(ArcoType.size12),
                  ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Applied',
          description: 'The same box padded with each step. This is the '
              'difference a spacing token makes in practice, at real size.',
          children: <Widget>[
            Wrap(
              spacing: ArcoSpace.spaceMd,
              runSpacing: ArcoSpace.spaceMd,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: <Widget>[
                for (final (String name, double value) in _steps)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(value),
                        decoration: BoxDecoration(
                          color: colors.accent.subtle,
                          borderRadius:
                              BorderRadius.circular(ArcoRadius.radiusMd),
                        ),
                        child: Container(
                          width: 64,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.accent.normal,
                            borderRadius:
                                BorderRadius.circular(ArcoRadius.radiusSm),
                          ),
                        ),
                      ),
                      const SizedBox(height: ArcoSpace.spaceSm),
                      Text(name, style: tokens.tertiary(ArcoType.size12)),
                      Text(
                        '${value.toInt()}',
                        style: tokens.tertiary(ArcoType.size10),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),

        DocSection(
          title: 'Why this scale is not the one the file declares',
          children: <Widget>[
            const Callout(
              title: 'The approved scale supersedes the Space component',
              body: 'The Space component on the Layout page declares 4 / 8 / 16 '
                  '/ 24. The approved scale is 4 / 8 / 12 / 16 / 20: it adds 12 '
                  'and 20 because those are the measured control paddings, and '
                  'it drops 24 in favour of 20. Every step stays divisible by '
                  'two, which is what lets a control sit on the grid at any of '
                  'its four sizes.',
              tone: CalloutTone.warning,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'Odd values inside a component are geometry, not spacing',
              body: 'Component internals still use 2, 5 and 6 - a checkbox '
                  'border, a switch knob offset. Those are measured geometry '
                  'and belong to the component, which is why they do not appear '
                  'on this scale.',
            ),
          ],
        ),
      ],
    );
  }
}
