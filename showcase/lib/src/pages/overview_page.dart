import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../catalog.dart';
import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/code_block.dart';
import '../widgets/doc_page.dart';

/// Landing page: what the package is, what it ships today and what is missing.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  static const String _installCode = '''
dependencies:
  lumiere_ui:
    git:
      url: https://github.com/jeissonlazo/luminiere_ui.git
      ref: main

# While working on the package and the application at the same time,
# point at the checkout instead of pushing on every change:
#
#   dependency_overrides:
#     lumiere_ui:
#       path: ../luminiere_ui
''';

  static const String _usageCode = '''
import 'package:lumiere_ui/lumiere_ui.dart';

MaterialApp(
  theme: LumiereThemeData.dark(),
  home: Scaffold(
    body: LumiereButton(
      label: 'Save',
      leadingIcon: const Icon(Icons.save),
      onPressed: _save,
    ),
  ),
)
''';

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return DocPage(
      title: 'lumiere_ui',
      lead: 'The design system and component library of Lumiere, rendered live. '
          'Every example on these pages is the real widget from the package, '
          'so a variant can be compared against the design file and a state can '
          'be operated with the mouse and the keyboard.',
      ruleId: 'DS-COMP-020',
      children: <Widget>[
        DocSection(
          title: 'What the package is',
          description: 'It is independent of the application. It never imports '
              'the editor, the viewport, the domain or '
              'the GPU module, and it ships no user-visible string: text and '
              'icons arrive from the caller. Its only visual input is the '
              'token layer and its only output is widgets.',
          children: <Widget>[
            const CodeBlock(code: _installCode),
            const SizedBox(height: ArcoSpace.spaceMd),
            const CodeBlock(code: _usageCode),
          ],
        ),

        DocSection(
          title: 'Components',
          ruleId: 'DS-COMP-020',
          description: 'The components this gallery documents, with the rule of '
              'the design constraints that fixes their axes. The rule is '
              'normative; this page only shows what the package built from it.',
          children: <Widget>[
            Wrap(
              spacing: ArcoSpace.spaceMd,
              runSpacing: ArcoSpace.spaceMd,
              children: <Widget>[
                for (final DocEntry entry in Catalog.componentEntries)
                  _ComponentCard(entry: entry),
              ],
            ),
          ],
        ),

        DocSection(
          title: 'Stage 1 coverage',
          description: 'Spec 001 fixes eighteen basic controls for stage 1. The '
              'table is the state of that list today, read from the package '
              'rather than from a plan.',
          children: <Widget>[
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: tokens.colors.surfaceContainer,
                borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
                border: Border.all(color: tokens.colors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int i = 0; i < _specItems.length; i++) ...<Widget>[
                    if (i > 0)
                      Container(height: 1, color: tokens.colors.borderSubtle),
                    _CoverageRow(item: _specItems[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'Two rows are waiting on a design decision',
              body: 'Shortcut Hint (D-1) and Label (D-2) have no component in '
                  'the design file, so the package cannot mirror one. Both are '
                  'recorded as pending design work instead of being invented.',
              tone: CalloutTone.warning,
            ),
          ],
        ),

        DocSection(
          title: 'How this gallery is built',
          description: 'It is a Flutter web application in '
              '`showcase/` of the package repository. It consumes `lumiere_ui` '
              'through its single public entry point, exactly as a product '
              'surface does, so nothing here can reach past the package API.',
          children: <Widget>[
            const Callout(
              title: 'The gallery is not the source of truth',
              body: 'Every statement on these pages either renders a real '
                  'widget, reads a token, or cites a rule of the design '
                  'constraints. Where the package is provisional, the page says '
                  'so rather than presenting it as settled.',
            ),
          ],
        ),
      ],
    );
  }
}

class _ComponentCard extends StatelessWidget {
  const _ComponentCard({required this.entry});

  final DocEntry entry;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return Container(
      width: 292,
      padding: const EdgeInsets.all(ArcoSpace.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  entry.title,
                  style: tokens.primary(
                    ArcoType.size16,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              if (entry.ruleId != null)
                RuleChip(ruleId: entry.ruleId!, compact: true),
            ],
          ),
          const SizedBox(height: ArcoSpace.spaceXs),
          Text(
            entry.summary ?? '',
            style: tokens.secondary(ArcoType.size13),
          ),
        ],
      ),
    );
  }
}

class _CoverageRow extends StatelessWidget {
  const _CoverageRow({required this.item});

  final _SpecItem item;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ArcoSpace.spaceMd,
        vertical: ArcoSpace.spaceSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.item,
                  style: tokens.primary(
                    ArcoType.size13,
                    weight: FontWeight.w500,
                  ),
                ),
                if (item.note != null)
                  Text(item.note!, style: tokens.tertiary(ArcoType.size12)),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              item.widget,
              style: tokens.mono(
                ArcoType.size12,
                color: tokens.colors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: 108,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusPill(label: item.status.label, tone: item.status.tone),
            ),
          ),
        ],
      ),
    );
  }
}

/// A control of the spec 001 inventory and where it stands in the package.
enum _Status {
  implemented('implemented', CalloutTone.success),
  partial('partial', CalloutTone.warning),
  pending('pending', CalloutTone.info);

  const _Status(this.label, this.tone);

  final String label;
  final CalloutTone tone;
}

@immutable
class _SpecItem {
  const _SpecItem(this.item, this.widget, this.status, {this.note});

  /// Name of the control as the spec's inventory lists it.
  final String item;

  /// What the package offers for it, or a dash when it offers nothing.
  final String widget;

  final _Status status;
  final String? note;
}

/// Spec 001 section 6.1, in the order the spec lists it.
const List<_SpecItem> _specItems = <_SpecItem>[
  _SpecItem('Button', 'LumiereButton', _Status.implemented),
  _SpecItem('Icon Button', 'LumiereButton with shape square or circle',
      _Status.partial, note: 'no widget of its own yet'),
  _SpecItem('Toggle Button', 'LumiereSwitch', _Status.implemented,
      note: 'the design file calls it switch (D-3)'),
  _SpecItem('Button Group', '-', _Status.pending),
  _SpecItem('Checkbox', 'LumiereCheckbox', _Status.implemented),
  _SpecItem('Radio Button', 'LumiereRadio, LumiereRadioGroup',
      _Status.implemented),
  _SpecItem('Switch', 'LumiereSwitch', _Status.implemented),
  _SpecItem('Slider', '-', _Status.pending),
  _SpecItem('Range Slider', '-', _Status.pending,
      note: 'the slider with its range axis (D-4)'),
  _SpecItem('Progress Bar', '-', _Status.pending),
  _SpecItem('Spinner / Loading', 'LumiereLoading', _Status.implemented),
  _SpecItem('Label', '-', _Status.pending, note: 'no component in the file (D-2)'),
  _SpecItem('Link', '-', _Status.pending),
  _SpecItem('Badge', '-', _Status.pending),
  _SpecItem('Chip / Tag', 'LumiereTag', _Status.implemented),
  _SpecItem('Separator / Divider', 'LumiereDivider', _Status.implemented),
  _SpecItem('Tooltip', '-', _Status.pending),
  _SpecItem('Shortcut Hint', '-', _Status.pending,
      note: 'no component in the file (D-1)'),
];
