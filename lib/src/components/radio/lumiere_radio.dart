import 'package:flutter/material.dart';

import '../../tokens/lumiere_tokens.dart';
import '../../tokens/tokens.g.dart';

/// Geometry of the radio, measured from the Arco kit.
///
/// Source: `design/reference/control-geometry.json`, section
/// `form_controls.Radio`. Every value names the layer it was measured on;
/// the two the export does not carry name that fact and the token they
/// fall back to.
abstract final class _RadioGeometry {
  /// Interactive box: 24 x 24, layer `group:Radio/basic/default`.
  static const double interactiveSize = 24;

  /// Visible circle: 14 x 14, layer `rectangle:Rectangle Copy 80`.
  static const double visibleSize = 14;

  /// Dot: 4 x 4, recorded in the measured geometry table of the design
  /// reference as the inner element of the radio.
  static const double dotSize = 4;

  /// Icon of the `icon` variant. Not measured; the circle is 14 px, so the
  /// closest step of the type scale that stays inside it is
  /// [ArcoType.size10].
  static const double iconSize = ArcoType.size10;

  /// Boundary width. Not measured: the export records geometry, not strokes.
  /// The Arco kit draws the boundary of a control as a 1 px hairline.
  static const double borderWidth = 1;

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
/// so it never enlarges the layout and never covers the visible circle.
const double _focusRingInset = 1;

/// Radio of the design system.
///
/// Mirrors the axes of the `components/radio` component set in the design
/// file: `checked`, `disabled`, `icon` and `hover`. `hover` is a real widget
/// state in Flutter rather than a property, so the widget resolves it itself.
///
/// ## Groups
///
/// A radio that stands alone carries its own [checked] state and reports a
/// selection through [onChanged]. Inside a [LumiereRadioGroup] the group owns
/// the selection: [checked] is ignored and the group's value decides, while
/// the group's `onChanged` reports the change. The type parameter of the radio
/// must match the type parameter of the group.
///
/// The widget carries its own accessibility: name, role, checked state,
/// disabled state, keyboard activation, visible focus, and, inside a group,
/// group navigation. Nothing is delegated to the caller.
class LumiereRadio<T> extends StatefulWidget {
  const LumiereRadio({
    super.key,
    required this.value,
    this.checked = false,
    this.disabled = false,
    this.icon,
    this.label,
    this.onChanged,
    this.focusNode,
  });

  /// The value this radio represents. Inside a [LumiereRadioGroup] it is the
  /// value the group reports when this radio is selected.
  final T value;

  /// Whether this radio is selected when it stands outside a group. Inside a
  /// group the group value decides and this flag is ignored.
  final bool checked;

  /// Draws the control as disabled and makes it inert.
  final bool disabled;

  /// Shows an icon inside the circle instead of the plain dot.
  ///
  /// The design declares this axis as a boolean. The icon itself comes from
  /// the instance, so the widget takes the icon and a non-null value is what
  /// turns the variant on.
  final Widget? icon;

  /// Visible label. A null label hides the text and leaves the accessible
  /// name empty.
  final String? label;

  /// Called with true when this radio is selected and it stands outside a
  /// group. A null callback leaves a standalone radio inert and disables it,
  /// as a null `onPressed` disables [LumiereButton].
  final ValueChanged<bool>? onChanged;

  /// Optional external focus node. The widget owns one when this is null.
  final FocusNode? focusNode;

  @override
  State<LumiereRadio<T>> createState() => _LumiereRadioState<T>();
}

/// A group of [LumiereRadio] widgets.
///
/// The group is the single tab stop of its radios and moves the selection with
/// the arrow keys, which is what the accessibility contract requires of a
/// composite control: one tab stop, arrows inside. It is built on the
/// `RadioGroup` widget of the Flutter SDK, which provides exactly that
/// behaviour and the group role in the semantics tree, and it avoids the
/// `groupValue` and `onChanged` properties of `Radio`, which this SDK marks as
/// deprecated.
class LumiereRadioGroup<T> extends StatelessWidget {
  const LumiereRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.child,
  });

  /// The selected value, or null when nothing is selected.
  final T? groupValue;

  /// Called with the value of the radio that was selected.
  final ValueChanged<T?> onChanged;

  /// The radios of the group.
  final Widget child;

  @override
  Widget build(BuildContext context) => RadioGroup<T>(
        groupValue: groupValue,
        onChanged: onChanged,
        child: child,
      );
}

class _LumiereRadioState<T> extends State<LumiereRadio<T>> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;
    final RadioGroupRegistry<T>? group = RadioGroup.maybeOf<T>(context);
    final bool enabled = !widget.disabled && (group != null || widget.onChanged != null);

    // One node carries the whole control: name, role, state, focus and the tap
    // action. Merging keeps a screen reader from reading the state and the
    // action as two separate things.
    return MergeSemantics(
      child: Semantics(
        // The visible label is excluded from the tree, so the name is declared
        // once, here. The checked state and the group role come from the raw
        // radio below, which owns the group registration.
        label: widget.label,
        enabled: enabled,
        child: RawRadio<T>(
          value: widget.value,
          enabled: enabled,
          groupRegistry: group ??
              _StandaloneRadioRegistry<T>(
                groupValue: widget.checked ? widget.value : null,
                onChanged: (T? _) => widget.onChanged?.call(true),
              ),
          toggleable: false,
          mouseCursor: WidgetStateMouseCursor.clickable,
          focusNode: _focusNode,
          autofocus: false,
          builder: (BuildContext context, ToggleableStateMixin state) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox.square(
                dimension: _RadioGeometry.interactiveSize,
                child: CustomPaint(
                  painter: _painter(colors, state),
                  child: widget.icon == null
                      ? null
                      : Center(
                          child: ExcludeSemantics(
                            child: IconTheme.merge(
                              data: IconThemeData(
                                size: _RadioGeometry.iconSize,
                                color: _iconColor(colors, state),
                              ),
                              child: widget.icon!,
                            ),
                          ),
                        ),
                ),
              ),
              if (widget.label != null) ...<Widget>[
                // The labelled frame measures 62 x 24 for a 24 px control and a
                // 37 px label. The closest approved step is ArcoSpace.spaceXs
                // (4).
                const SizedBox(width: ArcoSpace.spaceXs),
                ExcludeSemantics(
                  child: Text(
                    widget.label!,
                    style: tokens.text(size: ArcoType.size14).copyWith(
                          color: enabled
                              ? colors.textPrimary
                              : colors.textDisabled,
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
  /// The design declares `checked`, `disabled`, `icon` and `hover` only: it
  /// has no `pressed` option, so a press keeps the resting colours instead of
  /// inventing a step. The dot is a graphic indicator, so it is held to the
  /// 3:1 the accessibility contract requires of non-text information: in the
  /// dark theme the accent `normal` and `hover` fills measure 3.74:1 and
  /// 4.34:1 against `textOnAccent`.
  LumiereRadioPainter _painter(
    LumiereColors colors,
    ToggleableStateMixin state,
  ) {
    final bool enabled = state.isInteractive;
    final bool selected = state.value ?? false;
    final bool hovered = state.states.contains(WidgetState.hovered);
    final bool focused = state.states.contains(WidgetState.focused);

    Color? fill;
    Color? boundary;
    Color? dot;
    Color? hoverBackground;

    if (!enabled) {
      fill = selected ? colors.accent.disabled : null;
      boundary = selected ? null : colors.borderDefault;
      dot = selected ? colors.textOnAccent : null;
    } else if (selected) {
      fill = hovered ? colors.accent.hover : colors.accent.normal;
      dot = colors.textOnAccent;
    } else {
      // A boundary that identifies a control uses border.4, per the
      // accessibility contract; on hover the accent ramp identifies it.
      boundary = hovered ? colors.accent.normal : colors.borderHeavy;
      if (hovered) {
        // The 24 x 24 hover style measured on the component set.
        hoverBackground = colors.fillSubtle;
      }
    }

    return LumiereRadioPainter(
      selected: selected,
      showDot: widget.icon == null,
      fill: fill,
      boundary: boundary,
      dot: dot,
      hoverBackground: hoverBackground,
      focusRing: focused ? colors.accent.normal : null,
    );
  }

  /// Colour of the icon of the `icon` variant.
  ///
  /// An icon is a graphic, so it is held to 3:1 against what it sits on: the
  /// accent fill when selected, the page when not.
  Color _iconColor(LumiereColors colors, ToggleableStateMixin state) {
    final bool selected = state.value ?? false;
    if (!state.isInteractive) {
      return selected ? colors.textOnAccent : colors.textDisabled;
    }
    return selected ? colors.textOnAccent : colors.textSecondary;
  }
}

/// Registry for a radio that stands outside a group.
///
/// `RawRadio` requires a registry whenever it is enabled, so a standalone
/// radio gets one that reflects its own [LumiereRadio.checked] flag and
/// forwards the selection to its own callback. It registers no clients: there
/// is no group to navigate.
class _StandaloneRadioRegistry<T> implements RadioGroupRegistry<T> {
  const _StandaloneRadioRegistry({
    required this.groupValue,
    required this.onChanged,
  });

  @override
  final T? groupValue;

  @override
  final ValueChanged<T?> onChanged;

  @override
  void registerClient(RadioClient<T> radio) {}

  @override
  void unregisterClient(RadioClient<T> radio) {}
}

/// Painter of [LumiereRadio].
///
/// It is public so the tests can assert the colours the component resolved from
/// the tokens; it is not exported by the package entry point.
class LumiereRadioPainter extends CustomPainter {
  const LumiereRadioPainter({
    required this.selected,
    required this.showDot,
    required this.fill,
    required this.boundary,
    required this.dot,
    required this.hoverBackground,
    required this.focusRing,
  });

  /// Whether this radio is selected. A selected radio is a solid accent disc.
  final bool selected;

  /// Whether the plain dot is drawn. The `icon` variant replaces it.
  final bool showDot;

  /// Fill of the 14 x 14 circle, or null when it stays transparent.
  final Color? fill;

  /// Boundary of the circle, or null when there is none.
  final Color? boundary;

  /// Colour of the 4 x 4 dot.
  final Color? dot;

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
          const Radius.circular(_RadioGeometry.outerRadius),
        ),
        Paint()..color = hoverBackground!,
      );
    }

    if (focusRing != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(_focusRingInset),
          const Radius.circular(_RadioGeometry.outerRadius),
        ),
        Paint()
          ..color = focusRing!
          ..style = PaintingStyle.stroke
          ..strokeWidth = _focusRingWidth,
      );
    }

    final Rect circle = Rect.fromCenter(
      center: center,
      width: _RadioGeometry.visibleSize,
      height: _RadioGeometry.visibleSize,
    );

    if (fill != null) {
      canvas.drawCircle(center, circle.width / 2, Paint()..color = fill!);
    }
    if (boundary != null) {
      canvas.drawCircle(
        center,
        (circle.width - _RadioGeometry.borderWidth) / 2,
        Paint()
          ..color = boundary!
          ..style = PaintingStyle.stroke
          ..strokeWidth = _RadioGeometry.borderWidth,
      );
    }

    if (!selected || !showDot || dot == null) {
      return;
    }
    canvas.drawCircle(center, _RadioGeometry.dotSize / 2, Paint()..color = dot!);
  }

  @override
  bool shouldRepaint(LumiereRadioPainter oldDelegate) =>
      oldDelegate.selected != selected ||
      oldDelegate.showDot != showDot ||
      oldDelegate.fill != fill ||
      oldDelegate.boundary != boundary ||
      oldDelegate.dot != dot ||
      oldDelegate.hoverBackground != hoverBackground ||
      oldDelegate.focusRing != focusRing;
}
