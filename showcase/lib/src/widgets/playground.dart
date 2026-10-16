import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import 'code_block.dart';
import 'preview_surface.dart';

/// An interactive example: its controls, the live component and the source.
///
/// This is the part of the gallery that cannot be replaced by a screenshot. A
/// disabled state, a focus ring and a loading indicator only prove themselves
/// when they can be operated, and the source below reflects the current
/// selection rather than a fixed excerpt.
class Playground extends StatelessWidget {
  const Playground({
    super.key,
    required this.controls,
    required this.preview,
    required this.code,
    this.previewAlignment = Alignment.centerLeft,
    this.previewBackground,
  });

  final List<Widget> controls;
  final Widget preview;

  /// Dart source matching the current state of [controls].
  final String code;

  final Alignment previewAlignment;
  final Color? previewBackground;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(ArcoSpace.spaceMd),
          decoration: BoxDecoration(
            color: tokens.colors.surfaceContainer,
            borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
            border: Border.all(color: tokens.colors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < controls.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: ArcoSpace.spaceSm),
                controls[i],
              ],
            ],
          ),
        ),
        const SizedBox(height: ArcoSpace.spaceSm),
        PreviewSurface(
          alignment: previewAlignment,
          background: previewBackground,
          child: preview,
        ),
        const SizedBox(height: ArcoSpace.spaceSm),
        CodeBlock(code: code),
      ],
    );
  }
}

/// A labelled row of mutually exclusive choices.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.onChanged,
    this.labelOf,
    this.labelWidth = 96,
  });

  final String label;
  final List<T> values;
  final T selected;
  final ValueChanged<T> onChanged;

  /// How an option is spelled. Defaults to the enum name, which is the value
  /// the code passes.
  final String Function(T value)? labelOf;

  final double labelWidth;

  String _name(T value) =>
      labelOf?.call(value) ?? (value is Enum ? (value as Enum).name : '$value');

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: tokens.tertiary(ArcoType.size12),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: ArcoSpace.spaceXs,
            runSpacing: ArcoSpace.spaceXs,
            children: <Widget>[
              for (final T value in values)
                _Choice(
                  label: _name(value),
                  active: value == selected,
                  onTap: () => onChanged(value),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ArcoRadius.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ArcoSpace.spaceSm,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            color: active ? colors.accent.normal : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(ArcoRadius.radiusSm),
            border: Border.all(
              color: active ? colors.accent.normal : colors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: tokens.primary(
              ArcoType.size12,
              weight: active ? FontWeight.w500 : FontWeight.w400,
              color: active ? colors.textOnAccent : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled on/off row, driven by the design system's own switch.
class BoolRow extends StatelessWidget {
  const BoolRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.labelWidth = 96,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Row(
      children: <Widget>[
        SizedBox(
          width: labelWidth,
          child: Text(label, style: tokens.tertiary(ArcoType.size12)),
        ),
        LumiereSwitch(
          value: value,
          size: LumiereSwitchSize.small,
          // The row already shows the label, so the switch carries the
          // accessible name without drawing a second one.
          semanticLabel: label,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
