import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/doc_page.dart';
import '../widgets/doc_table.dart';
import '../widgets/example_card.dart';
import '../widgets/playground.dart';

/// Switch: three track types, two sizes, and the accessible-name path the other
/// controls are missing.
class SwitchPage extends StatefulWidget {
  const SwitchPage({super.key});

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  bool _value = true;
  LumiereSwitchType _type = LumiereSwitchType.circle;
  LumiereSwitchSize _size = LumiereSwitchSize.standard;
  bool _disabled = false;
  bool _handleIcon = false;
  LumiereSwitchTrackContent _trackContent = LumiereSwitchTrackContent.none;
  bool _label = true;

  /// The design pairs the line type with an empty track and a plain handle
  /// only, and the constructor asserts it, so the playground has to respect the
  /// same rule.
  bool get _isLine => _type == LumiereSwitchType.line;

  LumiereSwitchTrackContent get _effectiveTrack =>
      _isLine ? LumiereSwitchTrackContent.none : _trackContent;

  bool get _effectiveHandleIcon => !_isLine && _handleIcon;

  String _code() {
    final StringBuffer buffer = StringBuffer('LumiereSwitch(\n')
      ..writeln('  value: $_value,')
      ..writeln('  type: LumiereSwitchType.${_type.name},')
      ..writeln('  size: LumiereSwitchSize.${_size.name},');
    if (_disabled) {
      buffer.writeln('  disabled: true,');
    }
    if (_effectiveHandleIcon) {
      buffer.writeln('  handleIcon: const Icon(LucideIcons.check),');
    }
    if (_effectiveTrack != LumiereSwitchTrackContent.none) {
      buffer.writeln('  trackContent: LumiereSwitchTrackContent.'
          '${_effectiveTrack.name},');
      if (_effectiveTrack == LumiereSwitchTrackContent.icon) {
        buffer.writeln('  trackIcon: const Icon(LucideIcons.check),');
      }
    }
    if (_label) {
      buffer.writeln("  label: 'Switch',");
    } else {
      buffer.writeln("  semanticLabel: 'Switch',");
    }
    buffer
      ..writeln('  onChanged: (bool value) {},')
      ..write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return DocPage(
      title: 'Switch',
      lead: 'A boolean control with three track treatments. It is also the '
          'control that resolves the accessible name correctly: it takes a '
          'semanticLabel for the cases where there is no visible text, which '
          'the checkbox, the radio and the button do not.',
      ruleId: 'DS-COMP-006',
      children: <Widget>[
        DocSection(
          title: 'Playground',
          description: 'The line type only exists with an empty track and a '
              'plain handle in the design file, so those two controls stop '
              'applying while it is selected.',
          children: <Widget>[
            Playground(
              controls: <Widget>[
                BoolRow(
                  label: 'value',
                  value: _value,
                  onChanged: (bool value) => setState(() => _value = value),
                ),
                ChoiceRow<LumiereSwitchType>(
                  label: 'type',
                  values: LumiereSwitchType.values,
                  selected: _type,
                  onChanged: (LumiereSwitchType value) =>
                      setState(() => _type = value),
                ),
                ChoiceRow<LumiereSwitchSize>(
                  label: 'size',
                  values: LumiereSwitchSize.values,
                  selected: _size,
                  onChanged: (LumiereSwitchSize value) =>
                      setState(() => _size = value),
                ),
                ChoiceRow<LumiereSwitchTrackContent>(
                  label: 'trackContent',
                  values: LumiereSwitchTrackContent.values,
                  selected: _effectiveTrack,
                  onChanged: _isLine
                      ? (LumiereSwitchTrackContent _) {}
                      : (LumiereSwitchTrackContent value) =>
                          setState(() => _trackContent = value),
                ),
                BoolRow(
                  label: 'handleIcon',
                  value: _effectiveHandleIcon,
                  onChanged: _isLine
                      ? (bool _) {}
                      : (bool value) => setState(() => _handleIcon = value),
                ),
                BoolRow(
                  label: 'disabled',
                  value: _disabled,
                  onChanged: (bool value) => setState(() => _disabled = value),
                ),
                BoolRow(
                  label: 'label',
                  value: _label,
                  onChanged: (bool value) => setState(() => _label = value),
                ),
              ],
              preview: LumiereSwitch(
                value: _value,
                type: _type,
                size: _size,
                disabled: _disabled,
                handleIcon: _effectiveHandleIcon
                    ? const Icon(LucideIcons.check)
                    : null,
                trackContent: _effectiveTrack,
                trackIcon: _effectiveTrack == LumiereSwitchTrackContent.icon
                    ? const Icon(LucideIcons.check)
                    : null,
                label: _label ? 'Switch' : null,
                semanticLabel: _label ? null : 'Switch',
                onChanged: (bool value) => setState(() => _value = value),
              ),
              code: _code(),
            ),
          ],
        ),

        DocSection(
          title: 'Track types',
          description: 'Two box treatments and one thin bar. The line form is '
              'the exception to the rest of the component and asserts its own '
              'restrictions.',
          children: <Widget>[
            ExampleCard(
              code: '''
LumiereSwitch(value: on, type: LumiereSwitchType.circle, onChanged: (_) {})
LumiereSwitch(value: on, type: LumiereSwitchType.rectangle, onChanged: (_) {})
LumiereSwitch(value: on, type: LumiereSwitchType.line, onChanged: (_) {})''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceXl,
                samples: <Widget>[
                  for (final LumiereSwitchType type
                      in LumiereSwitchType.values)
                    Sample(
                      label: type.name,
                      child: LumiereSwitch(
                        value: true,
                        type: type,
                        onChanged: (bool _) {},
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Sizes, against every track type',
          children: <Widget>[
            for (final LumiereSwitchSize size in LumiereSwitchSize.values)
              Padding(
                padding: const EdgeInsets.only(bottom: ArcoSpace.spaceMd),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 88,
                      child: Text(
                        size.name,
                        style: tokens.mono(
                          ArcoType.size12,
                          color: tokens.colors.textTertiary,
                        ),
                      ),
                    ),
                    for (final LumiereSwitchType type
                        in LumiereSwitchType.values)
                      Padding(
                        padding:
                            const EdgeInsets.only(right: ArcoSpace.spaceXl),
                        child: LumiereSwitch(
                          value: true,
                          type: type,
                          size: size,
                          onChanged: (bool _) {},
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),

        DocSection(
          title: 'Track content',
          description: 'What the track carries in the end opposite the handle. '
              'The icon sits inside the track; the text does not - see the note '
              'below.',
          children: <Widget>[
            ExampleCard(
              code: '''
// A track icon, plus an icon inside the handle.
LumiereSwitch(
  value: true,
  trackContent: LumiereSwitchTrackContent.icon,
  trackIcon: const Icon(LucideIcons.check),
  handleIcon: const Icon(LucideIcons.check),
  onChanged: (_) {},
)

// Labelled: the text is drawn beside the measured track.
LumiereSwitch(
  value: true,
  trackContent: LumiereSwitchTrackContent.text,
  label: 'Enabled',
  onChanged: (_) {},
)

// Icon-only: no visible text, so the name comes from semanticLabel.
LumiereSwitch(value: true, semanticLabel: 'Enable grid snapping', onChanged: (_) {})''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceXl,
                samples: <Widget>[
                  LumiereSwitch(
                    value: true,
                    trackContent: LumiereSwitchTrackContent.icon,
                    trackIcon: const Icon(LucideIcons.check),
                    handleIcon: const Icon(LucideIcons.check),
                    onChanged: (bool _) {},
                  ),
                  LumiereSwitch(
                    value: true,
                    trackContent: LumiereSwitchTrackContent.text,
                    label: 'Enabled',
                    onChanged: (bool _) {},
                  ),
                  LumiereSwitch(
                    value: true,
                    semanticLabel: 'Enable grid snapping',
                    onChanged: (bool _) {},
                  ),
                  const LumiereSwitch(value: true, disabled: true),
                  LumiereSwitch(
                    value: false,
                    disabled: true,
                    label: 'Off, disabled',
                  ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Measured geometry',
          description: 'Frames and inner layers taken from the Arco kit.',
          children: <Widget>[
            const DocTable(
              columns: <String>['Type', 'Size', 'Track', 'Handle'],
              flex: <int>[4, 3, 4, 4],
              monoColumns: <int>{0, 1, 2, 3},
              rows: <List<String>>[
                <String>['circle, rectangle', 'standard', '40 x 24', '16'],
                <String>['circle, rectangle', 'small', '28 x 16', '12'],
                <String>['line', 'standard', '36 x 6', '20'],
                <String>['line', 'small', '28 x 4', '-'],
              ],
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'This geometry is still a reference, not a confirmation',
              body: 'The checkbox and the radio were confirmed against the '
                  'project file at depth 2, but the read of the switch set was '
                  'refused by the API, so these frames come from the upstream '
                  'Arco Sketch backup. Item E-8 of the pending list tracks the '
                  'one call that would close it.',
              tone: CalloutTone.warning,
            ),
          ],
        ),

        DocSection(
          title: 'Notes',
          children: <Widget>[
            const Callout(
              title: 'The label is deliberately not drawn on the track',
              body: 'The design widens the track to hold text, but text on the '
                  'accent fill measures 3.74:1 in the dark theme, below the '
                  '4.5:1 the accessibility contract requires for normal text, '
                  'and the token layer exposes no darker solid step. The label '
                  'is therefore drawn beside the measured track, on the page '
                  'background, where textPrimary measures 14.58:1.',
              tone: CalloutTone.warning,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'This is the control that gets the accessible name right',
              body: 'LumiereSwitch takes a semanticLabel for the icon-only '
                  'case, MergeSemantics so the label and the control are one '
                  'node, and excludes its decorative icons from the tree. The '
                  'button, the checkbox and the radio have no equivalent, which '
                  'is the gap noted on their pages.',
              tone: CalloutTone.success,
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
                  'circle / rectangle / line',
                  'circle',
                ],
                <String>['size', 'VARIANT', 'default / small', 'default'],
                <String>['on', 'VARIANT', 'true / false', 'true'],
                <String>['disabled', 'VARIANT', 'false / true', 'false'],
                <String>['handleIcon', 'VARIANT', 'false / true', 'false'],
                <String>[
                  'trackContent',
                  'VARIANT',
                  'none / icon / text',
                  'none',
                ],
              ],
            ),
            SizedBox(height: ArcoSpace.spaceMd),
            Callout(
              title: 'The code renames two options',
              body: 'The design calls the sizes default and small; default is a '
                  'Dart keyword, so the package calls it standard. The value is '
                  'the design\'s, only the identifier differs.',
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
                <String>['value', 'bool', 'false', 'Whether the switch is on.'],
                <String>[
                  'type',
                  'LumiereSwitchType',
                  'circle',
                  'Track treatment.',
                ],
                <String>[
                  'size',
                  'LumiereSwitchSize',
                  'standard',
                  'Track and handle size.',
                ],
                <String>[
                  'disabled',
                  'bool',
                  'false',
                  'Draws the control as disabled and makes it inert.',
                ],
                <String>[
                  'handleIcon',
                  'Widget?',
                  'null',
                  'Icon inside the handle. Not allowed with the line type.',
                ],
                <String>[
                  'trackContent',
                  'LumiereSwitchTrackContent',
                  'none',
                  'What the track carries opposite the handle.',
                ],
                <String>[
                  'trackIcon',
                  'Widget?',
                  'null',
                  'Icon of the icon track content.',
                ],
                <String>[
                  'label',
                  'String?',
                  'null',
                  'Visible label, drawn beside the track. Also the name.',
                ],
                <String>[
                  'semanticLabel',
                  'String?',
                  'null',
                  'Accessible name when there is no visible label.',
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
          ],
        ),
      ],
    );
  }
}
