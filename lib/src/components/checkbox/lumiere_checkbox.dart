import 'package:flutter/material.dart';

import '../../tokens/lumiere_tokens.dart';
import '../../tokens/tokens.g.dart';

/// Geometry of the checkbox, measured from the Arco kit.
///
/// Source: `design/reference/control-geometry.json`, section
/// `form_controls.Checkbox`. Every value names the layer it was measured on;
/// nothing here is chosen. The two values the export does not carry name that
/// fact and the token they fall back to.
abstract final class _CheckboxGeometry {
  /// Interactive box: 24 x 24, the frames of the component set.
  static const double interactiveSize = 24;

  /// Visible box: 14 x 14, layer `group:Frame 672`.
  static const double visibleSize = 14;

  /// Tick: 4 x 7, layer `shapePath:Combined Shape`.
  static const double tickWidth = 4;
  static const double tickHeight = 7;

  /// Indeterminate dash: 6 x 2, the rectangle layer of the indeterminate
  /// variant.
  static const double dashWidth = 6;
  static const double dashHeight = 2;

  /// Boundary width. Not measured: the export records geometry, not strokes.
  /// The Arco kit draws the boundary of a control as a 1 px hairline.
  static const double borderWidth = 1;

  /// Tick stroke. Not measured: the export records the tick's 4 x 7 bounding
  /// box only. 1.5 px keeps the tick inside that box at the weight the kit
  /// draws the glyph.
  static const double tickStrokeWidth = 1.5;

  /// Corner radius of the visible box. The export lists 0.5 px on one layer,
  /// which is not on the approved scale, so the closest token is used:
  /// [ArcoRadius.radiusSm] (2).
  static const double radius = ArcoRadius.radiusSm;

  /// Corner radius of the hover background and of the focus ring. Not
  /// measured; [ArcoRadius.radiusMd] (4) is the closest approved token to the
  /// 24 px interactive box.
  static const double outerRadius = ArcoRadius.radiusMd;
}

/// Width of the focus indicator.
///
/// The geometry export records no focus outline for this control. Two pixels
/// is the thinnest ring that stays perceptible when it is drawn at 1x.
const double _focusRingWidth = 2;

/// Distance between the focus ring and the edge of the interactive box.
///
/// Derived from [_focusRingWidth]: the ring is drawn inside the measured box,
/// so it never enlarges the layout and never covers the visible box.
const double _focusRingInset = 1;

/// Checkbox of the design system.
///
/// Mirrors the axes of the `checkbox` component set in the design file:
/// `checked`, `indeterminate`, `disabled`, `hover`, and the optional visible
/// label (`replaceText` plus `showLabel`, which a nullable [label] expresses on
/// its own). The design declares a `state` axis whose `hover` option is a real
/// widget state in Flutter rather than a property, so it is resolved through
/// the widget's own state and never asked of the caller; passing it would let a
/// caller describe a state the widget is not actually in.
///
/// The control carries its own accessibility: name, role, checked state,
/// disabled state, keyboard activation and a visible focus ring. Nothing is
/// delegated to the caller.
///
/// Geometry comes from `design/reference/control-geometry.json`: a 24 x 24
/// interactive box, a 14 x 14 visible box, a 4 x 7 tick and a 6 x 2 dash.
class LumiereCheckbox extends StatefulWidget {
  const LumiereCheckbox({
    super.key,
    this.checked = false,
    this.indeterminate = false,
    this.disabled = false,
    this.label,
    this.onChanged,
    this.focusNode,
  });

  /// Whether the box is checked. The design allows `checked` and
  /// [indeterminate] to be true at the same time; the dash then wins.
  final bool checked;

  /// Shows the dash instead of the tick, and exposes the mixed state.
  final bool indeterminate;

  /// Draws the control as disabled and makes it inert.
  final bool disabled;

  /// Visible label. A null label hides the text; the accessible name is then
  /// empty, exactly as the design's `showLabel = false` variant is.
  final String? label;

  /// Called with the next value of the box. A null callback also disables the
  /// control, as a null `onPressed` disables [LumiereButton].
  final ValueChanged<bool>? onChanged;

  /// Optional external focus node. The widget owns one when this is null.
  final FocusNode? focusNode;

  /// Whether the control can be operated at all.
  bool get isEnabled => onChanged != null && !disabled;

  @override
  State<LumiereCheckbox> createState() => _LumiereCheckboxState();
}

class _LumiereCheckboxState extends State<LumiereCheckbox>
    with TickerProviderStateMixin, ToggleableStateMixin {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  bool? get value => widget.indeterminate ? null : widget.checked;

  /// The dash is a third value, so the mixin has to allow it.
  @override
  bool get tristate => widget.indeterminate;

  @override
  ValueChanged<bool?>? get onChanged =>
      widget.isEnabled ? _handleChanged : null;

  /// The dash summarises a group, so activating it selects the box rather than
  /// clearing it; only a full box can be cleared.
  void _handleChanged(bool? next) =>
      widget.onChanged?.call(widget.indeterminate ? true : (next ?? true));

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;
    final bool enabled = widget.isEnabled;

    // One node carries the whole control: name, role, state, focus and the tap
    // action. Merging keeps a screen reader from reading the state and the
    // action as two separate things.
    return MergeSemantics(
      child: Semantics(
        // The visible label is excluded from the tree, so the name is declared
        // once, here.
        label: widget.label,
        checked: widget.indeterminate ? null : widget.checked,
        mixed: widget.indeterminate ? true : null,
        enabled: enabled,
        child: buildToggleableWithChild(
          focusNode: _focusNode,
          mouseCursor: WidgetStateMouseCursor.clickable,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CustomPaint(
                size: const Size.square(_CheckboxGeometry.interactiveSize),
                painter: _painter(colors),
              ),
              if (widget.label != null) ...<Widget>[
                // The labelled frame measures 89 x 24 for a 24 px control and a
                // 62 px label, a 3 px gap. The closest approved step is
                // ArcoSpace.spaceXs (4).
                const SizedBox(width: ArcoSpace.spaceXs),
                ExcludeSemantics(
                  child: Text(
                    widget.label!,
                    style: tokens.text(size: ArcoType.size14).copyWith(
                          color:
                              enabled ? colors.textPrimary : colors.textDisabled,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Resolves every colour of the control from the tokens.
  ///
  /// The design declares `checked`, `indeterminate`, `disabled` and `hover`
  /// only: it has no `pressed` option, so a press keeps the resting colours
  /// instead of inventing a step. That also keeps the tick, which is a graphic
  /// indicator, at or above the 3:1 the accessibility contract requires: in the
  /// dark theme the accent `normal` and `hover` fills measure 3.74:1 and 4.34:1
  /// against `textOnAccent`, while the `active` step measures 2.63:1.
  LumiereCheckboxPainter _painter(LumiereColors colors) {
    final bool enabled = isInteractive;
    final bool hovered = states.contains(WidgetState.hovered);
    final bool focused = states.contains(WidgetState.focused);
    final bool active = widget.checked || widget.indeterminate;

    Color? fill;
    Color? boundary;
    Color? graphic;
    Color? hoverBackground;

    if (!enabled) {
      // The disabled pairing is the one the secondary button uses: a subtle
      // fill, a default boundary and the ramp's disabled step for a solid fill.
      fill = active ? colors.accent.disabled : colors.fillSubtle;
      boundary = active ? null : colors.borderDefault;
      graphic = active ? colors.textOnAccent : null;
    } else if (active) {
      fill = hovered ? colors.accent.hover : colors.accent.normal;
      graphic = colors.textOnAccent;
    } else {
      // A boundary that identifies a control uses border.4, per the
      // accessibility contract; on hover the accent ramp identifies it.
      boundary = hovered ? colors.accent.normal : colors.borderHeavy;
      if (hovered) {
        // The 24 x 24 hover style measured on the component set.
        hoverBackground = colors.fillSubtle;
      }
    }

    return LumiereCheckboxPainter(
      indeterminate: widget.indeterminate,
      fill: fill,
      boundary: boundary,
      graphic: graphic,
      hoverBackground: hoverBackground,
      focusRing: focused ? colors.accent.normal : null,
    );
  }
}

/// Painter of [LumiereCheckbox].
///
/// It is public so the tests can assert the colours the component resolved from
/// the tokens; it is not exported by the package entry point.
class LumiereCheckboxPainter extends CustomPainter {
  const LumiereCheckboxPainter({
    required this.indeterminate,
    required this.fill,
    required this.boundary,
    required this.graphic,
    required this.hoverBackground,
    required this.focusRing,
  });

  /// Draws the 6 x 2 dash instead of the 4 x 7 tick.
  final bool indeterminate;

  /// Fill of the 14 x 14 visible box, or null when it stays transparent.
  final Color? fill;

  /// Boundary of the visible box, or null when there is none.
  final Color? boundary;

  /// Colour of the tick or the dash.
  final Color? graphic;

  /// Fill of the 24 x 24 hover background, or null when not hovered.
  final Color? hoverBackground;

  /// Colour of the focus ring, or null when the control is not focused.
  final Color? focusRing;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);

    if (hoverBackground != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_CheckboxGeometry.outerRadius),
        ),
        Paint()..color = hoverBackground!,
      );
    }

    if (focusRing != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(_focusRingInset),
          const Radius.circular(_CheckboxGeometry.outerRadius),
        ),
        Paint()
          ..color = focusRing!
          ..style = PaintingStyle.stroke
          ..strokeWidth = _focusRingWidth,
      );
    }

    final Rect box = Rect.fromCenter(
      center: center,
      width: _CheckboxGeometry.visibleSize,
      height: _CheckboxGeometry.visibleSize,
    );
    final RRect outline = RRect.fromRectAndRadius(
      box,
      const Radius.circular(_CheckboxGeometry.radius),
    );

    if (fill != null) {
      canvas.drawRRect(outline, Paint()..color = fill!);
    }
    if (boundary != null) {
      canvas.drawRRect(
        outline,
        Paint()
          ..color = boundary!
          ..style = PaintingStyle.stroke
          ..strokeWidth = _CheckboxGeometry.borderWidth,
      );
    }

    if (graphic == null) {
      return;
    }
    final Paint graphicPaint = Paint()
      ..color = graphic!
      ..style = PaintingStyle.stroke
      ..strokeWidth = _CheckboxGeometry.tickStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (indeterminate) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: _CheckboxGeometry.dashWidth,
            height: _CheckboxGeometry.dashHeight,
          ),
          // Fully round ends: the same rule the export records for the switch
          // track, whose measured radius is half its height.
          const Radius.circular(_CheckboxGeometry.dashHeight / 2),
        ),
        Paint()..color = graphic!,
      );
      return;
    }

    final Rect tick = Rect.fromCenter(
      center: center,
      width: _CheckboxGeometry.tickWidth,
      height: _CheckboxGeometry.tickHeight,
    );
    // The check mark of the kit: it starts halfway down the left edge, turns
    // two fifths along the width at the bottom edge, and ends at the top right
    // corner. The two ratios are the shape of the glyph, not measurements.
    canvas.drawPath(
      Path()
        ..moveTo(tick.left, tick.top + tick.height * 0.5)
        ..lineTo(tick.left + tick.width * 0.4, tick.bottom)
        ..lineTo(tick.right, tick.top),
      graphicPaint,
    );
  }

  @override
  bool shouldRepaint(LumiereCheckboxPainter oldDelegate) =>
      oldDelegate.indeterminate != indeterminate ||
      oldDelegate.fill != fill ||
      oldDelegate.boundary != boundary ||
      oldDelegate.graphic != graphic ||
      oldDelegate.hoverBackground != hoverBackground ||
      oldDelegate.focusRing != focusRing;
}
