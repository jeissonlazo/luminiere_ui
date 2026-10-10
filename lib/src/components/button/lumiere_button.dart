import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../tokens/lumiere_tokens.dart';
import '../../tokens/tokens.g.dart';

/// Visual weight of the button.
///
/// Mirrors the `type` axis of the `Button` component set in the design file,
/// with the options `primary`, `secondary`, `dashed`, `outline` and `text`.
/// The original design names are mapped in `design/variables/terminology.json`.
enum LumiereButtonType {
  /// Filled with the ramp's normal colour.
  primary,

  /// Neutral translucent fill.
  secondary,

  /// Transparent with a dashed outline.
  dashed,

  /// Transparent with a solid outline.
  outline,

  /// No fill and no outline.
  text,
}

/// Semantic colour of the button.
///
/// Mirrors the `kind` axis, with the options `standard`, `danger`, `warning`
/// and `success`. The original design names are mapped in
/// `design/variables/terminology.json`.
enum LumiereButtonKind { standard, danger, warning, success }

/// Corner treatment and box proportion.
///
/// Mirrors the `shape` axis, with the options `rectangle`, `pill`, `square`
/// and `circle`. The original design names are mapped in
/// `design/variables/terminology.json`. Note that this axis covers two things
/// at once: how round the corners are, and whether the box is free-width (text
/// buttons) or square (icon-only buttons).
enum LumiereButtonShape {
  /// Free width, small radius.
  rectangle,

  /// Free width, fully rounded.
  pill,

  /// Square box, small radius. For icon-only buttons.
  square,

  /// Circular box. For icon-only buttons.
  circle,
}

/// Control height. Mirrors the `size` axis, with the options `large`, `medium`,
/// `small` and `mini`. The original design names are mapped in
/// `design/variables/terminology.json`.
enum LumiereButtonSize { large, medium, small, mini }

/// Button of the design system.
///
/// The design declares a `state` axis, whose options (`default`, `hover`,
/// `focus`, `active`, `disabled`) are **real widget states** in Flutter rather
/// than properties, so this widget resolves them through [WidgetStateProperty]
/// instead of asking the caller to pass them; passing them would let a caller
/// describe a state the widget is not actually in. `loading` is the only state
/// that cannot be expressed that way, so it stays a property.
///
/// Height and horizontal padding per size come from the measured control scale
/// ([ArcoControl]): 36/20, 32/16, 28/16 and 24/12 for large, medium, small and
/// mini. The measurement is recorded in `design/reference/control-geometry.json`
/// and enforced by rule `DS-CONTROL-001`.
class LumiereButton extends StatelessWidget {
  const LumiereButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = LumiereButtonType.primary,
    this.kind = LumiereButtonKind.standard,
    this.shape = LumiereButtonShape.rectangle,
    this.size = LumiereButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  /// Visible label, and therefore the accessible name of the button.
  final String label;

  /// `null` leaves the button disabled.
  final VoidCallback? onPressed;

  final LumiereButtonType type;
  final LumiereButtonKind kind;
  final LumiereButtonShape shape;
  final LumiereButtonSize size;

  /// Decorative icon before the label; hidden from screen readers.
  final Widget? leadingIcon;

  /// Decorative icon after the label; hidden from screen readers.
  final Widget? trailingIcon;

  /// Shows progress and blocks interaction.
  final bool isLoading;

  /// Stretches the button to the available width.
  final bool isFullWidth;

  bool get _isEnabled => onPressed != null && !isLoading;

  bool get _isSquare =>
      shape == LumiereButtonShape.square || shape == LumiereButtonShape.circle;

  LumiereRamp get _ramp => switch (kind) {
        LumiereButtonKind.standard => LumiereRamp.accent,
        LumiereButtonKind.danger => LumiereRamp.danger,
        LumiereButtonKind.warning => LumiereRamp.warning,
        LumiereButtonKind.success => LumiereRamp.success,
      };

  double get _height => switch (size) {
        LumiereButtonSize.large => ArcoControl.heightLarge,
        LumiereButtonSize.medium => ArcoControl.heightMedium,
        LumiereButtonSize.small => ArcoControl.heightSmall,
        LumiereButtonSize.mini => ArcoControl.heightMini,
      };

  double get _radius => switch (shape) {
        LumiereButtonShape.rectangle || LumiereButtonShape.square =>
          ArcoRadius.radiusSm,
        LumiereButtonShape.pill || LumiereButtonShape.circle =>
          ArcoRadius.radiusFull,
      };

  double get _horizontalPadding => switch (size) {
        LumiereButtonSize.large => ArcoControl.paddingLarge,
        LumiereButtonSize.medium => ArcoControl.paddingMedium,
        LumiereButtonSize.small => ArcoControl.paddingSmall,
        LumiereButtonSize.mini => ArcoControl.paddingMini,
      };

  bool get _hasOutline =>
      type == LumiereButtonType.outline || type == LumiereButtonType.dashed;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereStatusColors ramp = tokens.colors.rampFor(_ramp);
    final double height = _height;

    Widget button = TextButton(
      onPressed: _isEnabled ? onPressed : null,
      style: _style(tokens, ramp, height),
      child: _content(tokens, ramp, height),
    );

    if (type == LumiereButtonType.dashed) {
      button = CustomPaint(
        foregroundPainter: _DashedBorderPainter(
          color: _isEnabled ? ramp.normal : ramp.disabled,
          radius: _radius >= height ? height / 2 : _radius,
          strokeWidth: 1,
        ),
        child: button,
      );
    }

    if (_isSquare) {
      return SizedBox(width: height, height: height, child: button);
    }
    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  ButtonStyle _style(
    LumiereTokens tokens,
    LumiereStatusColors ramp,
    double height,
  ) {
    final LumiereColors colors = tokens.colors;

    Color background(Set<WidgetState> states) {
      final bool disabled = states.contains(WidgetState.disabled);
      if (disabled) {
        return switch (type) {
          LumiereButtonType.primary => ramp.disabled,
          LumiereButtonType.secondary => colors.fillSubtle,
          LumiereButtonType.dashed ||
          LumiereButtonType.outline ||
          LumiereButtonType.text =>
            Colors.transparent,
        };
      }
      return switch (type) {
        LumiereButtonType.primary => states.contains(WidgetState.pressed)
            ? ramp.active
            : states.contains(WidgetState.hovered)
                ? ramp.hover
                : ramp.normal,
        LumiereButtonType.secondary => states.contains(WidgetState.pressed)
            ? colors.fillHeavy
            : states.contains(WidgetState.hovered)
                ? colors.fillStrong
                : colors.fillDefault,
        LumiereButtonType.dashed ||
        LumiereButtonType.outline ||
        LumiereButtonType.text =>
          Colors.transparent,
      };
    }

    Color foreground(Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return type == LumiereButtonType.primary
            ? colors.textOnAccent
            : ramp.textDisabled;
      }
      return type == LumiereButtonType.primary
          ? colors.textOnAccent
          : states.contains(WidgetState.hovered)
              ? ramp.hover
              : ramp.normal;
    }

    return ButtonStyle(
      minimumSize: WidgetStatePropertyAll<Size>(Size(0, height)),
      // Control sizes come from the tokens, never from Material's density.
      visualDensity: VisualDensity.standard,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      elevation: const WidgetStatePropertyAll<double>(0),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: _isSquare ? 0 : _horizontalPadding),
      ),
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle>(
        tokens.text(
          size: size == LumiereButtonSize.large
              ? ArcoType.size16
              : ArcoType.size14,
          weight: FontWeight.w400,
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(background),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(foreground),
      overlayColor: WidgetStatePropertyAll<Color>(colors.fillDefault),
      side: _hasOutline
          ? WidgetStateProperty.resolveWith<BorderSide?>(
              (Set<WidgetState> states) => type == LumiereButtonType.dashed
                  ? BorderSide.none
                  : BorderSide(
                      color: states.contains(WidgetState.disabled)
                          ? ramp.disabled
                          : ramp.normal,
                    ),
            )
          : const WidgetStatePropertyAll<BorderSide?>(BorderSide.none),
    );
  }

  Widget _content(
    LumiereTokens tokens,
    LumiereStatusColors ramp,
    double height,
  ) {
    final double iconSize =
        size == LumiereButtonSize.large ? ArcoType.size20 : ArcoType.size16;
    final Color iconColor = _isEnabled ? ramp.normal : ramp.textDisabled;

    if (isLoading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    }

    if (leadingIcon == null && trailingIcon == null) {
      return Text(label);
    }

    Widget icon(Widget widget) => ExcludeSemantics(
          child: IconTheme.merge(
            data: IconThemeData(size: iconSize, color: iconColor),
            child: widget,
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (leadingIcon != null) ...<Widget>[
          icon(leadingIcon!),
          if (label.isNotEmpty) SizedBox(width: ArcoSpace.spaceXs),
        ],
        if (label.isNotEmpty) Text(label),
        if (trailingIcon != null) ...<Widget>[
          if (label.isNotEmpty) SizedBox(width: ArcoSpace.spaceXs),
          icon(trailingIcon!),
        ],
      ],
    );
  }
}

/// Draws a dashed rounded border.
///
/// Flutter's [BorderSide] cannot express a dash pattern, so dashed outlines need
/// their own painter. This is one of the cases where a design system component
/// has to do real drawing instead of styling a Material widget.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  /// Dash and gap lengths of the outline. Not design tokens: the variables
  /// export carries no dash pattern for the dashed button type.
  static const double _dashLength = 4;
  static const double _gapLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = math.min(distance + _dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}
