import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/doc_page.dart';
import '../widgets/doc_table.dart';
import '../widgets/example_card.dart';
import '../widgets/playground.dart';

/// Checkbox, including the mixed state and the size of its hit target.
class CheckboxPage extends StatefulWidget {
  const CheckboxPage({super.key});

  @override
  State<CheckboxPage> createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  bool _checked = true;
  bool _indeterminate = false;
  bool _disabled = false;
  bool _showLabel = true;

  String _code() => '''
LumiereCheckbox(
  checked: $_checked,
  indeterminate: $_indeterminate,
  disabled: $_disabled,${_showLabel ? "\n  label: 'Accept the terms'," : ''}
  onChanged: (bool value) {},
)''';

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return DocPage(
      title: 'Checkbox',
      lead: 'A 14 px box inside a 24 px hit target. Two independent booleans, '
          'checked and indeterminate, plus the disabled form and the optional '
          'label, which is also the accessible name.',
      ruleId: 'DS-COMP-004',
      children: <Widget>[
        DocSection(
          title: 'Playground',
          children: <Widget>[
            Playground(
              controls: <Widget>[
                BoolRow(
                  label: 'checked',
                  value: _checked,
                  onChanged: (bool value) => setState(() => _checked = value),
                ),
                BoolRow(
                  label: 'indeterminate',
                  value: _indeterminate,
                  onChanged: (bool value) =>
                      setState(() => _indeterminate = value),
                ),
                BoolRow(
                  label: 'disabled',
                  value: _disabled,
                  onChanged: (bool value) => setState(() => _disabled = value),
                ),
                BoolRow(
                  label: 'label',
                  value: _showLabel,
                  onChanged: (bool value) => setState(() => _showLabel = value),
                ),
              ],
              preview: LumiereCheckbox(
                checked: _checked,
                indeterminate: _indeterminate,
                disabled: _disabled,
                label: _showLabel ? 'Accept the terms' : null,
                onChanged: (bool value) => setState(() => _checked = value),
              ),
              code: _code(),
            ),
          ],
        ),

        DocSection(
          title: 'States',
          children: <Widget>[
            ExampleCard(
              code: '''
const LumiereCheckbox(checked: true, label: 'Checked')
const LumiereCheckbox(checked: false, label: 'Unchecked')
const LumiereCheckbox(checked: true, indeterminate: true, label: 'Mixed')
const LumiereCheckbox(checked: true, disabled: true, label: 'Disabled')
const LumiereCheckbox(checked: false, disabled: true)
const LumiereCheckbox(checked: true)   // no label''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceLg,
                samples: <Widget>[
                  const LumiereCheckbox(checked: true, label: 'Checked'),
                  const LumiereCheckbox(checked: false, label: 'Unchecked'),
                  const LumiereCheckbox(
                    checked: true,
                    indeterminate: true,
                    label: 'Mixed',
                  ),
                  const LumiereCheckbox(
                    checked: true,
                    disabled: true,
                    label: 'Disabled',
                  ),
                  const LumiereCheckbox(checked: false, disabled: true),
                  const LumiereCheckbox(checked: true),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Notes',
          children: <Widget>[
            const Callout(
              title: 'The dash wins over the tick',
              body: 'The design allows checked and indeterminate to be true at '
                  'the same time, and the component resolves that by drawing '
                  'the dash. It is one visual state with two booleans behind '
                  'it, not two competing states.',
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'A null label leaves the accessible name empty',
              body: 'The design has a showLabel = false variant, so the '
                  'component supports a box with no text. When that happens '
                  'the control announces nothing, and there is no semanticLabel '
                  'to fall back on. A checkbox used without a visible label '
                  'needs the caller to wrap it.',
              tone: CalloutTone.warning,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'The hit target is not the box',
              body: 'The visible box is 14 px; the interactive area is 24 px. '
                  'That matters because the design file measures the control '
                  'row at 22 px, which is below the 24 px target WCAG 2.2 asks '
                  'for. The question of whether the row itself grows to 24 is '
                  'PC-OPEN-11 and is still open.',
              tone: CalloutTone.warning,
            ),
          ],
        ),

        DocSection(
          title: 'Design axes',
          description: 'Quoted from the constraints. Note that hover is an axis '
              'here only because a design tool cannot express an interaction; '
              'in the component it is a widget state.',
          children: const <Widget>[
            DocTable(
              columns: <String>['Axis', 'Type', 'Options', 'Default'],
              flex: <int>[4, 3, 5, 3],
              monoColumns: <int>{0, 3},
              rows: <List<String>>[
                <String>['replaceText', 'TEXT', '-', 'Checkbox'],
                <String>['showLabel', 'BOOLEAN', '-', 'true'],
                <String>['checked', 'VARIANT', 'false / true', 'true'],
                <String>['indeterminate', 'VARIANT', 'false / true', 'false'],
                <String>['disabled', 'VARIANT', 'false / true', 'false'],
                <String>['hover', 'VARIANT', 'false / true', 'false'],
              ],
            ),
          ],
        ),

        DocSection(
          title: 'API',
          children: <Widget>[
            DocTable(
              columns: const <String>[
                'Property',
                'Type',
                'Default',
                'Description',
              ],
              flex: const <int>[4, 5, 3, 9],
              monoColumns: const <int>{0, 1, 2},
              rows: <List<String>>[
                <String>[
                  'checked',
                  'bool',
                  'false',
                  'Whether the box is checked.',
                ],
                <String>[
                  'indeterminate',
                  'bool',
                  'false',
                  'Draws the dash, and takes precedence over the tick.',
                ],
                <String>[
                  'disabled',
                  'bool',
                  'false',
                  'Draws the control as disabled and makes it inert.',
                ],
                <String>[
                  'label',
                  'String?',
                  'null',
                  'Visible label, and the accessible name. Null hides the text.',
                ],
                <String>[
                  'onChanged',
                  'ValueChanged<bool>?',
                  'null',
                  'A null callback also disables the control.',
                ],
                <String>[
                  'focusNode',
                  'FocusNode?',
                  'null',
                  'External focus node; the widget owns one when null.',
                ],
              ],
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            Text(
              'The box is 14 px with a 1 px border and a 1.5 px tick stroke, '
              'inside a 24 px interactive area, and the corner radii come from '
              'ArcoRadius. That geometry is private to the component, so a '
              'caller aligning a form has to measure the rendered control '
              'rather than read a constant.',
              style: tokens.secondary(ArcoType.size13),
            ),
          ],
        ),
      ],
    );
  }
}
