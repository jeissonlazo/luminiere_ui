import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/doc_page.dart';
import '../widgets/doc_table.dart';
import '../widgets/example_card.dart';
import '../widgets/playground.dart';

/// Divider: a hairline, an optional label and the one interpretation in it.
class DividerPage extends StatefulWidget {
  const DividerPage({super.key});

  @override
  State<DividerPage> createState() => _DividerPageState();
}

class _DividerPageState extends State<DividerPage> {
  LumiereDividerOrientation _orientation =
      LumiereDividerOrientation.horizontal;
  LumiereDividerAlign _align = LumiereDividerAlign.center;
  bool _dashed = false;
  bool _label = true;

  bool get _vertical => _orientation == LumiereDividerOrientation.vertical;

  String _code() {
    final StringBuffer buffer = StringBuffer('LumiereDivider(\n')
      ..writeln('  orientation: LumiereDividerOrientation.${_orientation.name},');
    if (_label) {
      buffer.writeln("  label: 'or',");
      buffer.writeln('  align: LumiereDividerAlign.${_align.name},');
    }
    if (_dashed) {
      buffer.writeln('  dashed: true,');
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereDivider divider = LumiereDivider(
      orientation: _orientation,
      label: _label ? 'or' : null,
      align: _align,
      dashed: _dashed,
    );

    return DocPage(
      title: 'Divider',
      lead: 'A separator, with an optional label. It carries no margin on '
          'purpose: a separator is a line, and the space around it belongs to '
          'the layout that places it rather than to the line itself.',
      ruleId: 'DS-COMP-018',
      children: <Widget>[
        DocSection(
          title: 'Playground',
          children: <Widget>[
            Playground(
              // A divider takes its length from its box, so the preview has to
              // give it one: full width across, or a fixed height down.
              preview: _vertical
                  ? SizedBox(height: 96, child: divider)
                  : SizedBox(width: 420, child: divider),
              controls: <Widget>[
                ChoiceRow<LumiereDividerOrientation>(
                  label: 'orientation',
                  values: LumiereDividerOrientation.values,
                  selected: _orientation,
                  onChanged: (LumiereDividerOrientation value) =>
                      setState(() => _orientation = value),
                ),
                ChoiceRow<LumiereDividerAlign>(
                  label: 'align',
                  values: LumiereDividerAlign.values,
                  selected: _align,
                  onChanged: _label
                      ? (LumiereDividerAlign value) =>
                          setState(() => _align = value)
                      : (LumiereDividerAlign _) {},
                ),
                BoolRow(
                  label: 'label',
                  value: _label,
                  onChanged: (bool value) => setState(() => _label = value),
                ),
                BoolRow(
                  label: 'dashed',
                  value: _dashed,
                  onChanged: (bool value) => setState(() => _dashed = value),
                ),
              ],
              code: _code(),
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'align only means something with a label',
              body: 'Without text there is nothing to place, so the alignment '
                  'control stops applying while the label is off.',
            ),
          ],
        ),

        DocSection(
          title: 'Alignment',
          description: 'Where the label sits along the line. The label always '
              'has a line on both sides except in the none form.',
          children: <Widget>[
            ExampleCard(
              code: '''
LumiereDivider(label: 'or', align: LumiereDividerAlign.start)
LumiereDivider(label: 'or', align: LumiereDividerAlign.center)
LumiereDivider(label: 'or', align: LumiereDividerAlign.end)
LumiereDivider(label: 'or', align: LumiereDividerAlign.none)
LumiereDivider()                              // no label at all
LumiereDivider(dashed: true, label: 'dashed')''',
              previewAlignment: Alignment.centerLeft,
              child: SizedBox(
                width: 460,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final LumiereDividerAlign align
                        in LumiereDividerAlign.values) ...<Widget>[
                      Text(
                        align.name,
                        style: tokens.tertiary(ArcoType.size12),
                      ),
                      const SizedBox(height: ArcoSpace.spaceXs),
                      LumiereDivider(label: 'or', align: align),
                      const SizedBox(height: ArcoSpace.spaceMd),
                    ],
                    Text('no label', style: tokens.tertiary(ArcoType.size12)),
                    const SizedBox(height: ArcoSpace.spaceXs),
                    const LumiereDivider(),
                    const SizedBox(height: ArcoSpace.spaceMd),
                    Text('dashed', style: tokens.tertiary(ArcoType.size12)),
                    const SizedBox(height: ArcoSpace.spaceXs),
                    const LumiereDivider(dashed: true),
                  ],
                ),
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Vertical, between controls',
          description: 'The divider adds no space of its own, so the gaps here '
              'are placed by the row. That is the whole point of the component '
              'having no margin.',
          children: <Widget>[
            ExampleCard(
              code: '''
Row(
  children: <Widget>[
    LumiereButton(label: 'Cut', type: LumiereButtonType.text, onPressed: () {}),
    const SizedBox(width: ArcoSpace.spaceSm),
    const SizedBox(height: 32, child: LumiereDivider(
      orientation: LumiereDividerOrientation.vertical,
    )),
    const SizedBox(width: ArcoSpace.spaceSm),
    LumiereButton(label: 'Copy', type: LumiereButtonType.text, onPressed: () {}),
  ],
)''',
              previewAlignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  LumiereButton(
                    label: 'Cut',
                    type: LumiereButtonType.text,
                    onPressed: () {},
                  ),
                  const SizedBox(width: ArcoSpace.spaceSm),
                  const SizedBox(
                    height: 32,
                    child: LumiereDivider(
                      orientation: LumiereDividerOrientation.vertical,
                    ),
                  ),
                  const SizedBox(width: ArcoSpace.spaceSm),
                  LumiereButton(
                    label: 'Copy',
                    type: LumiereButtonType.text,
                    onPressed: () {},
                  ),
                  const SizedBox(width: ArcoSpace.spaceSm),
                  const SizedBox(
                    height: 32,
                    child: LumiereDivider(
                      orientation: LumiereDividerOrientation.vertical,
                      dashed: true,
                    ),
                  ),
                  const SizedBox(width: ArcoSpace.spaceSm),
                  LumiereButton(
                    label: 'Paste',
                    type: LumiereButtonType.text,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Notes',
          children: <Widget>[
            const Callout(
              title: 'The none alignment is the one interpretation here',
              body: 'none is the design file\'s own value for the align axis, '
                  'and the package reads it as the label shown without lines '
                  'beside it. That reading is recorded as pending confirmation '
                  'against the design file rather than presented as settled - '
                  'every other option maps to a label with lines on both sides.',
              tone: CalloutTone.warning,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'Two options were renamed in code',
              body: 'The design names the alignment options left, center and '
                  'right. The package uses start, center and end, which is what '
                  'a direction-aware layout needs: in a right-to-left locale '
                  'start is on the right. The values are the design\'s, only the '
                  'identifiers differ.',
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'The dash metrics are not declared anywhere',
              body: 'The design carries no dash pattern, so the 4 px dash and '
                  'gap are the values the dashed button already used, kept '
                  'consistent and recorded as pending confirmation. They live '
                  'in LumiereStrokes with the 1 px hairline, which is measured.',
              tone: CalloutTone.warning,
            ),
          ],
        ),

        DocSection(
          title: 'Design axes',
          children: const <Widget>[
            DocTable(
              columns: <String>['Axis', 'Type', 'Options', 'Default'],
              flex: <int>[4, 3, 5, 3],
              monoColumns: <int>{0, 3},
              rows: <List<String>>[
                <String>[
                  'type',
                  'VARIANT',
                  'horizontal / vertical',
                  'horizontal',
                ],
                <String>['dashed', 'VARIANT', 'true / false', 'false'],
                <String>['text', 'VARIANT', 'true / false', 'true'],
                <String>[
                  'align',
                  'VARIANT',
                  'left / center / right / none',
                  'center',
                ],
              ],
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
                  'orientation',
                  'LumiereDividerOrientation',
                  'horizontal',
                  'Direction of the line.',
                ],
                <String>[
                  'label',
                  'String?',
                  'null',
                  'Optional text in the middle of the line.',
                ],
                <String>[
                  'align',
                  'LumiereDividerAlign',
                  'center',
                  'Where the label sits.',
                ],
                <String>[
                  'dashed',
                  'bool',
                  'false',
                  'Draws the line as a dashed stroke.',
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
