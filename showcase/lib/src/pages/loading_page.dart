import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../widgets/callout.dart';
import '../widgets/doc_page.dart';
import '../widgets/doc_table.dart';
import '../widgets/example_card.dart';
import '../widgets/playground.dart';

/// The indeterminate loading indicator.
class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

/// Which ramp the indicator is drawn from.
enum _Spin {
  accent('accent, the default'),
  success('success'),
  warning('warning'),
  danger('danger');

  const _Spin(this.label);

  final String label;
}

class _LoadingPageState extends State<LoadingPage> {
  static const List<double> _sizes = <double>[16, 24, 40, 56];

  double _size = 40;
  _Spin _spin = _Spin.accent;
  bool _labelled = true;

  Color? _color(LumiereColors colors) => switch (_spin) {
        _Spin.accent => null,
        _Spin.success => colors.success.normal,
        _Spin.warning => colors.warning.normal,
        _Spin.danger => colors.danger.normal,
      };

  String _code() {
    final StringBuffer buffer = StringBuffer('LumiereLoading(\n')
      ..writeln('  size: ${_size.toInt()},');
    if (_spin != _Spin.accent) {
      buffer.writeln('  color: tokens.colors.${_spin.name}.normal,');
    }
    if (_labelled) {
      buffer.writeln("  semanticLabel: 'Loading',");
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return DocPage(
      title: 'Loading',
      lead: 'One indeterminate indicator. The design declares no axis for it at '
          'all - not even a size - so the package exposes a size only because '
          'the button draws the same indicator smaller, at its own icon size.',
      ruleId: 'DS-COMP-012',
      children: <Widget>[
        DocSection(
          title: 'Playground',
          children: <Widget>[
            Playground(
              controls: <Widget>[
                ChoiceRow<double>(
                  label: 'size',
                  values: _sizes,
                  selected: _size,
                  labelOf: (double value) => value.toInt().toString(),
                  onChanged: (double value) => setState(() => _size = value),
                ),
                ChoiceRow<_Spin>(
                  label: 'color',
                  values: _Spin.values,
                  selected: _spin,
                  labelOf: (_Spin value) => value.label,
                  onChanged: (_Spin value) => setState(() => _spin = value),
                ),
                BoolRow(
                  label: 'semanticLabel',
                  value: _labelled,
                  onChanged: (bool value) => setState(() => _labelled = value),
                ),
              ],
              preview: LumiereLoading(
                size: _size,
                color: _color(tokens.colors),
                semanticLabel: _labelled ? 'Loading' : null,
              ),
              code: _code(),
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'The semanticLabel changes nothing you can see',
              body: 'Without it the indicator is decorative and hidden from '
                  'screen readers, which is the right default for a spinner '
                  'that only decorates a surface already announcing its own '
                  'state. Turn it on and the indicator becomes an announced '
                  'status instead. The package ships no string, so the caller '
                  'decides which of the two it is.',
            ),
          ],
        ),

        DocSection(
          title: 'Sizes',
          description: 'The design component is 40 px. The other three are '
              'shown because the size is a parameter, not a scale: nothing in '
              'the design declares them.',
          children: <Widget>[
            ExampleCard(
              code: '''
LumiereLoading(size: 16, semanticLabel: 'Loading')
LumiereLoading(size: 24, semanticLabel: 'Loading')
LumiereLoading(size: 40, semanticLabel: 'Loading')  // the design's size
LumiereLoading(size: 56, semanticLabel: 'Loading')''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceXl,
                samples: <Widget>[
                  for (final double size in _sizes)
                    Sample(
                      label: '${size.toInt()} px',
                      note: size == 40 ? 'the design' : null,
                      child: LumiereLoading(
                        size: size,
                        semanticLabel: 'Loading',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Inside a button',
          description: 'This is why the size is a parameter. A loading button '
              'draws the same indicator at the icon size of its own size step, '
              'so the two must be able to differ.',
          children: <Widget>[
            ExampleCard(
              code: '''
LumiereButton(label: 'Save', isLoading: true, onPressed: () {})
LumiereButton(label: 'Saving', isLoading: true, type: LumiereButtonType.secondary, onPressed: () {})''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceMd,
                samples: <Widget>[
                  LumiereButton(
                    label: 'Save',
                    isLoading: true,
                    onPressed: () {},
                  ),
                  LumiereButton(
                    label: 'Saving',
                    type: LumiereButtonType.secondary,
                    isLoading: true,
                    onPressed: () {},
                  ),
                  LumiereButton(
                    label: '',
                    shape: LumiereButtonShape.circle,
                    isLoading: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'On a button, the indicator is drawn in the disabled ink',
              body: 'isLoading disables the button, so the indicator takes '
                  'accent.textDisabled and lands on the disabled fill. That '
                  'pair measures 1.41:1 in the dark theme and 1.31:1 in the '
                  'light one, against the 3:1 asked of graphical information '
                  'that identifies a state, so the progress it reports is '
                  'barely there. The Button page carries the measurement in '
                  'full.',
              tone: CalloutTone.danger,
            ),
          ],
        ),

        DocSection(
          title: 'Notes',
          children: <Widget>[
            const Callout(
              title: 'It never settles',
              body: 'The rotation repeats for as long as the widget is mounted, '
                  'so a widget test has to pump frames instead of waiting for '
                  'the tree to settle - pumpAndSettle on a screen holding this '
                  'indicator never returns. The golden test of the gallery '
                  'unmounts the page for the same reason.',
              tone: CalloutTone.warning,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'The duration is a placeholder',
              body: 'The design declares no motion values yet, so the 900 ms '
                  'turn is a stand-in that will be replaced when it does. '
                  'Whether motion belongs to the design contract at all is '
                  'decision PC-OPEN-07, and the missing durations are item E-6 '
                  'of the pending list.',
              tone: CalloutTone.warning,
            ),
          ],
        ),

        DocSection(
          title: 'API',
          children: const <Widget>[
            DocTable(
              columns: <String>['Property', 'Type', 'Default', 'Description'],
              flex: <int>[4, 5, 3, 9],
              monoColumns: <int>{0, 1, 2},
              rows: <List<String>>[
                <String>[
                  'size',
                  'double',
                  '40',
                  'Diameter in logical pixels. The design component is 40.',
                ],
                <String>[
                  'color',
                  'Color?',
                  'null',
                  'Defaults to the accent of the current theme.',
                ],
                <String>[
                  'semanticLabel',
                  'String?',
                  'null',
                  'Announcement for assistive technology. Null makes the '
                      'indicator decorative.',
                ],
              ],
            ),
            SizedBox(height: ArcoSpace.spaceMd),
            Callout(
              title: 'There is no API row for the design axes',
              body: 'Not an omission: DS-COMP-012 records zero axes and zero '
                  'variants for general/loading. There is one indicator, and '
                  'this page documents the whole of it.',
            ),
          ],
        ),
      ],
    );
  }
}
