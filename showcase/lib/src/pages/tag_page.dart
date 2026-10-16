import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import '../widgets/callout.dart';
import '../widgets/doc_page.dart';
import '../widgets/doc_table.dart';
import '../widgets/example_card.dart';
import '../widgets/playground.dart';

/// Tag: the widest colour axis in the package.
class TagPage extends StatefulWidget {
  const TagPage({super.key});

  @override
  State<TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<TagPage> {
  LumiereTagColorName _color = LumiereTagColorName.ultimateBlue;
  LumiereTagSize _size = LumiereTagSize.small;
  bool _filled = true;
  bool _bordered = false;
  bool _icon = false;
  bool _closable = false;

  String _code() {
    final StringBuffer buffer = StringBuffer('LumiereTag(\n')
      ..writeln("  label: 'Tag',")
      ..writeln('  color: LumiereTagColorName.${_color.name},')
      ..writeln('  size: LumiereTagSize.${_size.name},')
      ..writeln('  filled: $_filled,')
      ..writeln('  bordered: $_bordered,');
    if (_icon) {
      buffer.writeln('  icon: const Icon(LucideIcons.tag),');
    }
    if (_closable) {
      buffer
        ..writeln('  onClose: () {},')
        ..writeln("  closeSemanticLabel: 'Remove Tag',");
    }
    buffer.write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return DocPage(
      title: 'Tag',
      lead: 'A chip for a state, a category or a filter. Eleven colour '
          'families, four sizes, two background treatments, an optional leading '
          'icon and an optional close action.',
      ruleId: 'DS-COMP-017',
      children: <Widget>[
        DocSection(
          title: 'Playground',
          description: 'filled and bordered are read together: filled uses the '
              'soft background of the family, bordered the stronger one, and '
              'selecting neither leaves text and icon alone.',
          children: <Widget>[
            Playground(
              controls: <Widget>[
                ChoiceRow<LumiereTagColorName>(
                  label: 'color',
                  values: LumiereTagColorName.values,
                  selected: _color,
                  onChanged: (LumiereTagColorName value) =>
                      setState(() => _color = value),
                ),
                ChoiceRow<LumiereTagSize>(
                  label: 'size',
                  values: LumiereTagSize.values,
                  selected: _size,
                  onChanged: (LumiereTagSize value) =>
                      setState(() => _size = value),
                ),
                BoolRow(
                  label: 'filled',
                  value: _filled,
                  onChanged: (bool value) => setState(() => _filled = value),
                ),
                BoolRow(
                  label: 'bordered',
                  value: _bordered,
                  onChanged: (bool value) => setState(() => _bordered = value),
                ),
                BoolRow(
                  label: 'icon',
                  value: _icon,
                  onChanged: (bool value) => setState(() => _icon = value),
                ),
                BoolRow(
                  label: 'onClose',
                  value: _closable,
                  onChanged: (bool value) => setState(() => _closable = value),
                ),
              ],
              preview: LumiereTag(
                label: 'Tag',
                color: _color,
                size: _size,
                filled: _filled,
                bordered: _bordered,
                icon: _icon ? const Icon(LucideIcons.tag) : null,
                onClose: _closable ? () {} : null,
                closeSemanticLabel: _closable ? 'Remove Tag' : null,
              ),
              code: _code(),
            ),
          ],
        ),

        DocSection(
          title: 'Colours',
          description: 'All eleven families, in the order the enum declares '
              'them. The name shown is the value the code passes; the design '
              'calls the first one default.',
          children: <Widget>[
            ExampleCard(
              code: '''
for (final color in LumiereTagColorName.values)
  LumiereTag(label: color.name, color: color)''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceSm,
                samples: <Widget>[
                  for (final LumiereTagColorName color
                      in LumiereTagColorName.values)
                    LumiereTag(
                      label: color == LumiereTagColorName.neutral
                          ? 'neutral (default)'
                          : color.name,
                      color: color,
                    ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Sizes',
          children: <Widget>[
            ExampleCard(
              code: '''
for (final size in LumiereTagSize.values)
  LumiereTag(label: size.name, size: size, color: LumiereTagColorName.ultimateBlue)''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceSm,
                samples: <Widget>[
                  for (final LumiereTagSize size in LumiereTagSize.values)
                    LumiereTag(
                      label: size.name,
                      size: size,
                      color: LumiereTagColorName.ultimateBlue,
                    ),
                ],
              ),
            ),
          ],
        ),

        DocSection(
          title: 'Forms',
          description: 'The two booleans are independent, so all four '
              'combinations are reachable - including the one with no '
              'background at all.',
          children: <Widget>[
            ExampleCard(
              code: '''
LumiereTag(label: 'filled', color: color)
LumiereTag(label: 'bordered', color: color, filled: false, bordered: true)
LumiereTag(label: 'both', color: color, filled: true, bordered: true)
LumiereTag(label: 'neither', color: color, filled: false)

// With an icon and a close action.
LumiereTag(
  label: 'closable',
  color: LumiereTagColorName.romanticRed,
  icon: const Icon(LucideIcons.tag),
  onClose: () {},
  closeSemanticLabel: 'Remove closable',
)''',
              previewAlignment: Alignment.centerLeft,
              child: SampleGrid(
                spacing: ArcoSpace.spaceSm,
                samples: <Widget>[
                  const LumiereTag(
                    label: 'filled',
                    color: LumiereTagColorName.youthPurple,
                  ),
                  const LumiereTag(
                    label: 'bordered',
                    color: LumiereTagColorName.youthPurple,
                    filled: false,
                    bordered: true,
                  ),
                  const LumiereTag(
                    label: 'both',
                    color: LumiereTagColorName.youthPurple,
                    bordered: true,
                  ),
                  const LumiereTag(
                    label: 'neither',
                    color: LumiereTagColorName.youthPurple,
                    filled: false,
                  ),
                  const LumiereTag(
                    label: 'icon',
                    color: LumiereTagColorName.wildGreen,
                    icon: Icon(LucideIcons.tag),
                  ),
                  LumiereTag(
                    label: 'closable',
                    color: LumiereTagColorName.romanticRed,
                    icon: const Icon(LucideIcons.tag),
                    onClose: () {},
                    closeSemanticLabel: 'Remove closable',
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
              title: 'The filled and bordered pairing is an inference',
              body: 'The design gives each colour two backgrounds, and the '
                  'variant counts split evenly between the ones with filled set '
                  'and the ones with bordered set. The component reads that as '
                  '"filled uses the soft background, bordered uses the stronger '
                  'one". It is the one interpretation in this component and is '
                  'recorded as pending confirmation rather than presented as '
                  'certain.',
              tone: CalloutTone.warning,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'A close action forces you to supply the name',
              body: 'onClose asserts that closeSemanticLabel is not null, and '
                  'that is deliberate: the package ships no user-visible '
                  'string, so it cannot invent "remove" in the reader\'s '
                  'language. The inaccessible version is not constructible.',
              tone: CalloutTone.success,
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            const Callout(
              title: 'One known contrast failure in the light theme',
              body: 'The label is normal-size text and must reach 4.5:1 against '
                  'its background. In the light theme the design\'s ink does '
                  'not reach that on every family. The widget uses the colours '
                  'the design declares until the design decides the fix, and '
                  'the accessibility contract records it as exception AE-11. '
                  'Switch the theme and compare the light families to see it.',
              tone: CalloutTone.danger,
            ),
          ],
        ),

        DocSection(
          title: 'Design axes',
          description: 'Eight axes; the four shown first carry no options and '
              'are instance slots, which the package models as a String or a '
              'Widget instead.',
          children: const <Widget>[
            DocTable(
              columns: <String>['Axis', 'Type', 'Options', 'Default'],
              flex: <int>[4, 3, 6, 3],
              monoColumns: <int>{0, 3},
              rows: <List<String>>[
                <String>['replaceIcon', 'INSTANCE_SWAP', '-', '130405:195094'],
                <String>['showIcon', 'BOOLEAN', '-', 'false'],
                <String>['closable', 'BOOLEAN', '-', 'false'],
                <String>['replaceText', 'TEXT', '-', 'default'],
                <String>[
                  'size',
                  'VARIANT',
                  'large / medium / small / mini',
                  'small',
                ],
                <String>[
                  'color',
                  'VARIANT',
                  'default / romanticRed / wildGreen / blueTide / '
                      'vitalityOrange / lateAutumnRed / dusk / youthPurple / '
                      'magenta / ultimateBlue / seaBlue',
                  'default',
                ],
                <String>['filled', 'VARIANT', 'true / false', 'true'],
                <String>['bordered', 'VARIANT', 'false / true', 'false'],
              ],
            ),
            SizedBox(height: ArcoSpace.spaceMd),
            Callout(
              title: 'The default size is not the code default',
              body: 'The design declares small as the default of the size axis; '
                  'the widget matches that. The heights are measured and live '
                  'in ArcoTag: 32, 28, 24 and 20 px for large, medium, small '
                  'and mini, with zero variance over 91 variants each.',
            ),
          ],
        ),

        DocSection(
          title: 'API',
          children: <Widget>[
            const DocTable(
              columns: <String>['Property', 'Type', 'Default', 'Description'],
              flex: <int>[4, 5, 3, 9],
              monoColumns: <int>{0, 1, 2},
              rows: <List<String>>[
                <String>[
                  'label',
                  'String',
                  'required',
                  'Text of the tag, and its accessible name.',
                ],
                <String>[
                  'color',
                  'LumiereTagColorName',
                  'neutral',
                  'Colour family, as the design names it.',
                ],
                <String>[
                  'size',
                  'LumiereTagSize',
                  'small',
                  'Height step, from ArcoTag.',
                ],
                <String>[
                  'filled',
                  'bool',
                  'true',
                  'Uses the soft background of the family.',
                ],
                <String>[
                  'bordered',
                  'bool',
                  'false',
                  'Uses the stronger background and a border.',
                ],
                <String>[
                  'icon',
                  'Widget?',
                  'null',
                  'Decorative icon before the label; hidden from screen readers.',
                ],
                <String>[
                  'onClose',
                  'VoidCallback?',
                  'null',
                  'Shows a close action.',
                ],
                <String>[
                  'closeSemanticLabel',
                  'String?',
                  'null',
                  'Accessible name of the close action. Mandatory with onClose.',
                ],
              ],
            ),
            const SizedBox(height: ArcoSpace.spaceMd),
            Text(
              'ArcoTag publishes the four heights '
              '(${ArcoTag.heightLarge.toInt()} / '
              '${ArcoTag.heightMedium.toInt()} / '
              '${ArcoTag.heightSmall.toInt()} / '
              '${ArcoTag.heightMini.toInt()}), so a layout that stacks tags '
              'can align to the component instead of hardcoding its own.',
              style: tokens.secondary(ArcoType.size13),
            ),
          ],
        ),
      ],
    );
  }
}
