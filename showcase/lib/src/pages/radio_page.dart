import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../widgets/callout.dart';
import '../widgets/doc_page.dart';
import '../widgets/doc_table.dart';
import '../widgets/example_card.dart';
import '../widgets/playground.dart';

/// Radio: the single control, and the group that owns the value and the
/// keyboard.
class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  static const List<String> _options = <String>['paint', 'layout', 'uv'];

  String _selected = 'paint';
  bool _icon = false;
  bool _disabledThird = false;

  String _code() {
    final StringBuffer buffer = StringBuffer('LumiereRadioGroup<String>(\n')
      ..writeln("  groupValue: '$_selected',")
      ..writeln('  onChanged: (String? value) {},')
      ..writeln('  child: Column(')
      ..writeln('    children: <Widget>[');
    for (final String option in _options) {
      final bool disabled = _disabledThird && option == 'layout';
      final bool icon = _icon && option == 'uv';
      if (!disabled && !icon) {
        buffer.writeln(
          "      LumiereRadio<String>(value: '$option', label: '$option'),",
        );
        continue;
      }
      buffer.writeln('      LumiereRadio<String>(');
      buffer.writeln("        value: '$option',");
      buffer.writeln("        label: '$option',");
      if (icon) {
        buffer.writeln('        icon: const Icon(LucideIcons.layers),');
      }
      if (disabled) {
        buffer.writeln('        disabled: true,');
      }
      buffer.writeln('      ),');
    }
    buffer
      ..writeln('    ],')
      ..writeln('  ),')
      ..write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return DocPage(
      title: 'Radio',
      lead: 'One choice out of a set. The value belongs to the group, not to '
          'the radio, so a single radio is inert until something owns its '
          'selection - either a group or a caller holding the state.',
      ruleId: 'DS-COMP-005',
      children: <Widget>[
        DocSection(
          title: 'Playground',
          description: 'The group owns the selection, so the radios inside it '
              'declare only their value and label. Selecting one is what '
              'reports the new value.',
          children: <Widget>[
            Playground(
              controls: <Widget>[
                ChoiceRow<String>(
                  label: 'groupValue',
                  values: _options,
                  selected: _selected,
                  onChanged: (String value) =>
                      setState(() => _selected = value),
                ),
                BoolRow(
                  label: 'icon',
                  value: _icon,
                  onChanged: (bool value) => setState(() => _icon = value),
                ),
                BoolRow(
                  label: 'disabled',
                  value: _disabledThird,
                  onChanged: (bool value) =>
                      setState(() => _disabledThird = value),
                ),
              ],
              preview: LumiereRadioGroup<String>(
                groupValue: _selected,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _selected = value);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final String option in _options)
                      LumiereRadio<String>(
                        value: option,
                        label: option,
                        icon: _icon && option == 'uv'
                            ? const Icon(LucideIcons.layers)
                            : null,
                        disabled: _disabledThird && option == 'layout',
                      ),
                  ],
                ),
              ),
              code: _code(),
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'disabled marks the third option, not all of them',
              body: 'The switch in the controls disables the layout option so '
                  'the disabled form can be compared against its neighbours in '
                  'the same group, which is how it will actually appear.',
            ),
          ],
        ),

        DocSection(
          title: 'Inside a group, against standalone',
          description: 'A radio outside a group has to be told whether it is '
              'checked and has to report its own selection. Inside a group '
              'both of those come from the group.',
          children: <Widget>[
            ExampleCard(
              code: '''
// Inside a group: the group decides, the radio only declares itself.
LumiereRadioGroup<String>(
  groupValue: selected,
  onChanged: (value) => setState(() => selected = value),
  child: Column(
    children: <Widget>[
      LumiereRadio<String>(value: 'paint', label: 'paint'),
      LumiereRadio<String>(value: 'layout', label: 'layout'),
      LumiereRadio<String>(value: 'layout', label: 'layout', disabled: true),
      LumiereRadio<String>(
        value: 'uv',
        label: 'uv',
        icon: const Icon(LucideIcons.layers),
      ),
    ],
  ),
)''',
              previewAlignment: Alignment.centerLeft,
              child: LumiereRadioGroup<String>(
                groupValue: _selected,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _selected = value);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final String option in _options)
                      LumiereRadio<String>(value: option, label: option),
                    const LumiereRadio<String>(
                      value: 'disabled',
                      label: 'disabled',
                      disabled: true,
                    ),
                    LumiereRadio<String>(
                      value: 'icon',
                      label: 'with icon',
                      icon: const Icon(LucideIcons.layers),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Notes',
          children: <Widget>[
            const Callout(
              title: 'The group is one tab stop',
              body: 'The accessibility contract asks a composite control to be '
                  'a single tab stop with the arrow keys moving the selection '
                  'inside it. LumiereRadioGroup builds on the Flutter SDK\'s '
                  'RadioGroup, which provides exactly that behaviour and the '
                  'group role in the semantics tree, rather than reimplementing '
                  'focus traversal by hand.',
              tone: CalloutTone.success,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'A null label leaves the accessible name empty',
              body: 'As with the checkbox, the design allows the text to be '
                  'hidden and there is no semanticLabel to compensate. A radio '
                  'without a visible label needs the caller to supply the name.',
              tone: CalloutTone.warning,
            ),
          ],
        ),

        DocSection(
          title: 'Design axes',
          description: 'The design declares no label axis: the text is an '
              'instance override, not a variant.',
          children: const <Widget>[
            DocTable(
              columns: <String>['Axis', 'Type', 'Options', 'Default'],
              flex: <int>[4, 3, 5, 3],
              monoColumns: <int>{0, 3},
              rows: <List<String>>[
                <String>['checked', 'VARIANT', 'false / true', 'false'],
                <String>['disabled', 'VARIANT', 'false / true', 'false'],
                <String>['icon', 'VARIANT', 'false / true', 'false'],
                <String>['hover', 'VARIANT', 'false / true', 'false'],
              ],
            ),
          ],
        ),

        DocSection(
          title: 'API: LumiereRadio',
          children: const <Widget>[
            DocTable(
              columns: <String>['Property', 'Type', 'Default', 'Description'],
              flex: <int>[4, 5, 3, 9],
              monoColumns: <int>{0, 1, 2},
              rows: <List<String>>[
                <String>[
                  'value',
                  'T',
                  'required',
                  'The value this radio represents; the group reports it.',
                ],
                <String>[
                  'checked',
                  'bool',
                  'false',
                  'Selection when it stands outside a group. Ignored inside one.',
                ],
                <String>[
                  'disabled',
                  'bool',
                  'false',
                  'Draws the control as disabled and makes it inert.',
                ],
                <String>[
                  'icon',
                  'Widget?',
                  'null',
                  'Draws an icon inside the circle instead of the dot.',
                ],
                <String>[
                  'label',
                  'String?',
                  'null',
                  'Visible label, and the accessible name.',
                ],
                <String>[
                  'onChanged',
                  'ValueChanged<bool>?',
                  'null',
                  'Selection of a standalone radio; ignored inside a group.',
                ],
                <String>[
                  'focusNode',
                  'FocusNode?',
                  'null',
                  'External focus node; the widget owns one when null.',
                ],
              ],
            ),
          ],
        ),

        DocSection(
          title: 'API: LumiereRadioGroup',
          children: const <Widget>[
            DocTable(
              columns: <String>['Property', 'Type', 'Default', 'Description'],
              flex: <int>[4, 5, 3, 9],
              monoColumns: <int>{0, 1, 2},
              rows: <List<String>>[
                <String>[
                  'groupValue',
                  'T?',
                  'required',
                  'The selected value, or null when nothing is selected.',
                ],
                <String>[
                  'onChanged',
                  'ValueChanged<T?>',
                  'required',
                  'Called with the value of the radio that was selected.',
                ],
                <String>[
                  'child',
                  'Widget',
                  'required',
                  'The radios of the group.',
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
