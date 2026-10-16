import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/doc_page.dart';
import '../widgets/doc_table.dart';
import '../widgets/example_card.dart';
import '../widgets/playground.dart';

/// Button: the component with the most axes, and the one that carries the
/// state model the other controls follow.
class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  LumiereButtonType _type = LumiereButtonType.primary;
  LumiereButtonKind _kind = LumiereButtonKind.standard;
  LumiereButtonShape _shape = LumiereButtonShape.rectangle;
  LumiereButtonSize _size = LumiereButtonSize.medium;
  bool _leadingIcon = false;
  bool _trailingIcon = false;
  bool _loading = false;
  bool _fullWidth = false;
  bool _enabled = true;

  /// The square and circle shapes are the icon-only forms: the design draws
  /// them without text, so a label would not fit.
  bool get _iconOnly =>
      _shape == LumiereButtonShape.square ||
      _shape == LumiereButtonShape.circle;

  String get _label => _iconOnly ? '' : 'Save';

  bool get _showLeading => _iconOnly || _leadingIcon;

  String _code() {
    final StringBuffer buffer = StringBuffer('LumiereButton(\n')
      ..writeln("  label: '$_label',")
      ..writeln('  type: LumiereButtonType.${_type.name},')
      ..writeln('  kind: LumiereButtonKind.${_kind.name},')
      ..writeln('  shape: LumiereButtonShape.${_shape.name},')
      ..writeln('  size: LumiereButtonSize.${_size.name},');
    if (_showLeading) {
      buffer.writeln('  leadingIcon: const Icon(LucideIcons.save),');
    }
    if (_trailingIcon && !_iconOnly) {
      buffer.writeln('  trailingIcon: const Icon(LucideIcons.chevronDown),');
    }
    if (_loading) {
      buffer.writeln('  isLoading: true,');
    }
    if (_fullWidth) {
      buffer.writeln('  isFullWidth: true,');
    }
    buffer.writeln(
      _enabled ? '  onPressed: () {},' : '  onPressed: null, // disabled',
    );
    buffer.write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return DocPage(
      title: 'Button',
      lead: 'Five design axes, of which four are properties. The fifth, state, '
          'is not: default, hover, focus, active and disabled are real widget '
          'states in Flutter, so the component resolves them itself instead of '
          'letting a caller describe a state the widget is not in.',
      ruleId: 'DS-COMP-001',
      children: <Widget>[
        DocSection(
          title: 'Playground',
          description: 'Every property the component exposes, live. The source '
              'below the preview follows the controls.',
          children: <Widget>[
            Playground(
              previewAlignment: _fullWidth
                  ? Alignment.center
                  : Alignment.centerLeft,
              controls: <Widget>[
                ChoiceRow<LumiereButtonType>(
                  label: 'type',
                  values: LumiereButtonType.values,
                  selected: _type,
                  onChanged: (LumiereButtonType value) =>
                      setState(() => _type = value),
                ),
                ChoiceRow<LumiereButtonKind>(
                  label: 'kind',
                  values: LumiereButtonKind.values,
                  selected: _kind,
                  onChanged: (LumiereButtonKind value) =>
                      setState(() => _kind = value),
                ),
                ChoiceRow<LumiereButtonShape>(
                  label: 'shape',
                  values: LumiereButtonShape.values,
                  selected: _shape,
                  onChanged: (LumiereButtonShape value) =>
                      setState(() => _shape = value),
                ),
                ChoiceRow<LumiereButtonSize>(
                  label: 'size',
                  values: LumiereButtonSize.values,
                  selected: _size,
                  onChanged: (LumiereButtonSize value) =>
                      setState(() => _size = value),
                ),
                BoolRow(
                  label: 'leadingIcon',
                  value: _showLeading,
                  onChanged: _iconOnly
                      ? (bool _) {}
                      : (bool value) => setState(() => _leadingIcon = value),
                ),
                BoolRow(
                  label: 'trailingIcon',
                  value: _trailingIcon && !_iconOnly,
                  onChanged: _iconOnly
                      ? (bool _) {}
                      : (bool value) => setState(() => _trailingIcon = value),
                ),
                BoolRow(
                  label: 'isLoading',
                  value: _loading,
                  onChanged: (bool value) => setState(() => _loading = value),
                ),
                BoolRow(
                  label: 'isFullWidth',
                  value: _fullWidth,
                  onChanged: (bool value) => setState(() => _fullWidth = value),
                ),
                BoolRow(
                  label: 'onPressed',
                  value: _enabled,
                  onChanged: (bool value) => setState(() => _enabled = value),
                ),
              ],
              preview: LumiereButton(
                label: _label,
                type: _type,
                kind: _kind,
                shape: _shape,
                size: _size,
                leadingIcon: _showLeading
                    ? const Icon(LucideIcons.save)
                    : null,
                trailingIcon: _trailingIcon && !_iconOnly
                    ? const Icon(LucideIcons.chevronDown)
                    : null,
                isLoading: _loading,
                isFullWidth: _fullWidth,
                onPressed: _enabled ? () {} : null,
              ),
              code: _code(),
            ),
          ],
        ),

        DocSection(
          title: 'Type',
          description: 'Visual weight: how the button is filled and outlined. '
              'The label is the option name, because that is the value the code '
              'passes.',
          children: <Widget>[
            ExampleCard(
              code: '''
for (final type in LumiereButtonType.values)
  LumiereButton(label: type.name, type: type, onPressed: () {})''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceMd,
                samples: <Widget>[
                  for (final LumiereButtonType type in LumiereButtonType.values)
                    LumiereButton(
                      label: type.name,
                      type: type,
                      onPressed: () {},
                    ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Kind, against every type',
          description: 'The two axes are independent, and every combination '
              'exists in the design file. The row label is the kind and the '
              'button label is the type.',
          children: <Widget>[
            for (final LumiereButtonKind kind in LumiereButtonKind.values)
              Padding(
                padding: const EdgeInsets.only(bottom: ArcoSpace.spaceSm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 88,
                      child: Text(
                        kind.name,
                        style: tokens.mono(
                          ArcoType.size12,
                          color: tokens.colors.textTertiary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: ArcoSpace.spaceSm,
                        runSpacing: ArcoSpace.spaceSm,
                        children: <Widget>[
                          for (final LumiereButtonType type
                              in LumiereButtonType.values)
                            LumiereButton(
                              label: type.name,
                              type: type,
                              kind: kind,
                              onPressed: () {},
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
          title: 'Size',
          ruleId: 'DS-CONTROL-001',
          description: 'Height and horizontal padding per size, measured from '
              'the design geometry.',
          children: <Widget>[
            ExampleCard(
              code: '''
for (final size in LumiereButtonSize.values)
  LumiereButton(label: size.name, size: size, onPressed: () {})''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceMd,
                samples: <Widget>[
                  for (final LumiereButtonSize size
                      in LumiereButtonSize.values)
                    LumiereButton(
                      label: size.name,
                      size: size,
                      onPressed: () {},
                    ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Shape',
          description: 'The axis covers two things at once: how round the '
              'corners are, and whether the box is free-width or square. The '
              'square and circle forms are for icon-only buttons, so they carry '
              'no label.',
          children: <Widget>[
            ExampleCard(
              code: '''
LumiereButton(label: 'rectangle', shape: LumiereButtonShape.rectangle, onPressed: () {})
LumiereButton(label: 'pill', shape: LumiereButtonShape.pill, onPressed: () {})

// Icon-only forms: no label, an icon instead.
LumiereButton(
  label: '',
  shape: LumiereButtonShape.square,
  leadingIcon: const Icon(LucideIcons.plus),
  onPressed: () {},
)''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceMd,
                samples: <Widget>[
                  LumiereButton(
                    label: 'rectangle',
                    shape: LumiereButtonShape.rectangle,
                    onPressed: () {},
                  ),
                  LumiereButton(
                    label: 'pill',
                    shape: LumiereButtonShape.pill,
                    onPressed: () {},
                  ),
                  LumiereButton(
                    label: '',
                    shape: LumiereButtonShape.square,
                    leadingIcon: const Icon(LucideIcons.plus),
                    onPressed: () {},
                  ),
                  LumiereButton(
                    label: '',
                    shape: LumiereButtonShape.circle,
                    leadingIcon: const Icon(LucideIcons.plus),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'States',
          description: 'Loading is the only state that cannot be a widget '
              'state, so it is the only one that is a property. Disabled is a '
              'null callback, exactly as a Material button does it.',
          children: <Widget>[
            ExampleCard(
              code: '''
LumiereButton(label: 'Disabled')                     // onPressed is null
LumiereButton(label: 'Loading', isLoading: true, onPressed: () {})
LumiereButton(
  label: 'With icon',
  leadingIcon: const Icon(LucideIcons.save),
  onPressed: () {},
)
LumiereButton(
  label: 'Full width',
  isFullWidth: true,
  onPressed: () {},
)''',
              previewAlignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SampleGrid(
                    spacing: ArcoSpace.spaceMd,
                    samples: <Widget>[
                      const LumiereButton(label: 'Disabled'),
                      LumiereButton(
                        label: 'Loading',
                        isLoading: true,
                        onPressed: () {},
                      ),
                      LumiereButton(
                        label: 'With icon',
                        leadingIcon: const Icon(LucideIcons.save),
                        onPressed: () {},
                      ),
                      LumiereButton(
                        label: 'Trailing',
                        trailingIcon: const Icon(LucideIcons.chevronDown),
                        onPressed: () {},
                      ),
                      LumiereButton(
                        label: 'Dashed disabled',
                        type: LumiereButtonType.dashed,
                      ),
                    ],
                  ),
                  const SizedBox(height: ArcoSpace.spaceMd),
                  LumiereButton(
                    label: 'Full width',
                    isFullWidth: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'Hover, focus and pressed are not shown as pictures',
              body: 'They cannot be: they are states the widget enters. Move '
                  'the pointer over a button above, or tab into one, to see '
                  'them. This is also why the component takes no state '
                  'argument - a caller could otherwise ask for a hover '
                  'treatment while the pointer is somewhere else.',
            ),
          ],
        ),

        DocSection(
          title: 'Accessibility',
          children: <Widget>[
            const Callout(
              title: 'An icon-only button has no accessible name',
              body: 'label is both the visible text and the accessible name, '
                  'and this component excludes its icons from the semantic '
                  'tree. The square and circle shapes are drawn without text, '
                  'so a button built that way announces nothing. LumiereSwitch '
                  'and LumiereTag both expose a semanticLabel for exactly this '
                  'case; LumiereButton does not. Worth settling before the '
                  'first icon-only toolbar is built.',
              tone: CalloutTone.warning,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'Focus is visible and does not rely on colour alone',
              body: 'The focus ring is drawn from the status ramp, and the '
                  'disabled form changes its fill and its text colour together '
                  'rather than only its opacity.',
              tone: CalloutTone.success,
            ),
          ],
        ),

        DocSection(
          title: 'Design axes',
          description: 'The axes the design file declares on the Button '
              'component, quoted from the constraints. State is the axis this '
              'package deliberately does not expose.',
          children: <Widget>[
            const DocTable(
              columns: <String>['Axis', 'Type', 'Options', 'Default'],
              flex: <int>[3, 3, 6, 3],
              monoColumns: <int>{0, 3},
              rows: <List<String>>[
                <String>[
                  'replaceIcon',
                  'INSTANCE_SWAP',
                  '-',
                  '130405:195081',
                ],
                <String>['showIcon', 'BOOLEAN', '-', 'false'],
                <String>['swapIcon', 'INSTANCE_SWAP', '-', '130405:195081'],
                <String>[
                  'type',
                  'VARIANT',
                  'primary / secondary / dashed / outline / text',
                  'primary',
                ],
                <String>[
                  'kind',
                  'VARIANT',
                  'standard / danger / warning / success',
                  'standard',
                ],
                <String>[
                  'shape',
                  'VARIANT',
                  'rectangle / pill / square / circle',
                  'rectangle',
                ],
                <String>[
                  'size',
                  'VARIANT',
                  'large / medium / small / mini',
                  'medium',
                ],
                <String>[
                  'state',
                  'VARIANT',
                  'default / hover / focus / active / disabled',
                  'default',
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
                  'label',
                  'String',
                  'required',
                  'Visible label, and therefore the accessible name.',
                ],
                <String>[
                  'onPressed',
                  'VoidCallback?',
                  'null',
                  'null leaves the button disabled.',
                ],
                <String>[
                  'type',
                  'LumiereButtonType',
                  'primary',
                  'Visual weight: the fill and the outline.',
                ],
                <String>[
                  'kind',
                  'LumiereButtonKind',
                  'standard',
                  'Semantic colour family.',
                ],
                <String>[
                  'shape',
                  'LumiereButtonShape',
                  'rectangle',
                  'Corner treatment and box proportion.',
                ],
                <String>[
                  'size',
                  'LumiereButtonSize',
                  'medium',
                  'Control height and padding, from ArcoControl.',
                ],
                <String>[
                  'leadingIcon',
                  'Widget?',
                  'null',
                  'Decorative icon before the label; hidden from screen readers.',
                ],
                <String>[
                  'trailingIcon',
                  'Widget?',
                  'null',
                  'Decorative icon after the label; hidden from screen readers.',
                ],
                <String>[
                  'isLoading',
                  'bool',
                  'false',
                  'Shows progress and blocks interaction.',
                ],
                <String>[
                  'isFullWidth',
                  'bool',
                  'false',
                  'Stretches the button to the available width.',
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
