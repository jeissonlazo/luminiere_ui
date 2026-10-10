import 'package:flutter/material.dart';

import '../../tokens/lumiere_tokens.dart';
import '../../tokens/tokens.g.dart';

/// Track treatment of the switch.
///
/// Mirrors the `type` axis of the `switch` component set in the design file,
/// with the options the file names `circle`, `rectangle` and `line`.
enum LumiereSwitchType {
  /// Fully round track.
  circle,

  /// Rounded rectangle track.
  rectangle,

  /// Thin bar with a round knob, the `line` option of the design.
  line,
}

/// Size of the switch.
///
/// Mirrors the `size` axis. The design names the options `default` and `small`;
/// the first one is called [standard] here because `default` is a Dart keyword.
enum LumiereSwitchSize {
  /// The design's `default` size.
  standard,

  /// The design's `small` size.
  small,
}

/// What the track carries in the end opposite the handle.
///
/// Mirrors the `trackContent` axis of the `switch` component set.
enum LumiereSwitchTrackContent {
  /// Nothing. The accessible name comes from `semanticLabel`.
  none,

  /// An icon, drawn inside the track. The accessible name comes from
  /// `semanticLabel`.
  icon,

  /// The label of the control. The design widens the track to 51 x 24 to hold
  /// this text, but text on the accent fill measures 3.74:1 in the dark theme,
  /// below the 4.5:1 the accessibility contract requires for normal text, and
  /// the token layer exposes no darker solid step. The label is therefore drawn
  /// beside the measured track, on the page background, where `textPrimary`
  /// measures 14.58:1.
  text,
}

/// Geometry of the switch, measured from the Arco kit.
///
/// Source: `design/reference/control-geometry.json`, section
/// `form_controls.Switch`: the frames, the recorded radii and the inner
/// layers. The one value the export does not carry names that fact and the
/// token it falls back to.
abstract final class _SwitchGeometry {
  /// `circle` and `rectangle`, size `default`: frames 40 x 24.
  static const double trackWidth = 40;
  static const double trackHeight = 24;

  /// `circle` and `rectangle`, size `small`: frames 28 x 16.
  static const double trackWidthSmall = 28;
  static const double trackHeightSmall = 16;

  /// Handle of `circle` and `rectangle`: layer `group:Thumb` / `rectangle:Thumb
  /// (style)` at 16 x 16, and 10 x 10 for the small size.
  static const double handleSize = 16;
  static const double handleSizeSmall = 10;

  /// `line`: the track is 36 x 6 for `default` and 28 x 4 for `small`, the
  /// handle is the 20 x 20 layer `shapePath:thumb` for both sizes.
  static const double lineTrackWidth = 36;
  static const double lineTrackHeight = 6;
  static const double lineTrackWidthSmall = 28;
  static const double lineTrackHeightSmall = 4;
  static const double lineHandleSize = 20;

  /// Corner radius of the track and of the handle.
  ///
  /// The export records a single radius, 20, on the fully round `circle` track,
  /// where the radius is half the height. The `line` track follows the same
  /// rule: its measured height is 6, so a fully round 3 px end. The `rectangle`
  /// track has no measured radius of its own, so the closest approved token is
  /// used: [ArcoRadius.radiusMd] (4).
  static const double radiusFull = ArcoRadius.radiusFull;
  static const double radiusRectangle = ArcoRadius.radiusMd;

  /// Icon of the `handleIcon` variant, and icon of the `icon` track content.
  ///
  /// The 16 x 16 handle takes the closest step of the type scale,
  /// [ArcoType.size10]; the 10 x 10 handle of the small size takes
  /// [ArcoSpace.spaceSm] (8), the closest approved step that still leaves the
  /// icon inside the handle. Inside the wider track the icons use
  /// [ArcoType.size12] and, for the small size, [ArcoType.size10].
  static const double handleIconSize = ArcoType.size10;
  static const double handleIconSizeSmall = ArcoSpace.spaceSm;
  static const double trackIconSize = ArcoType.size12;
  static const double trackIconSizeSmall = ArcoType.size10;

  /// Distance between the track content and the end of the track. The export
  /// records the content layer but not its padding; [ArcoSpace.spaceXs] (4) is
  /// the closest approved step.
  static const double contentInset = ArcoSpace.spaceXs;

  /// Resolves the measured box of one variant.
  static LumiereSwitchMetrics metrics(LumiereSwitchType type, LumiereSwitchSize size) {
    final bool small = size == LumiereSwitchSize.small;
    if (type == LumiereSwitchType.line) {
      final double track = small ? lineTrackWidthSmall : lineTrackWidth;
      final double bar = small ? lineTrackHeightSmall : lineTrackHeight;
      return LumiereSwitchMetrics(
        // The frame of the line variant is the bounding box of the thin track
        // and the much larger handle: 36 x 20 of measured geometry.
        width: track < lineHandleSize ? lineHandleSize : track,
        height: bar < lineHandleSize ? lineHandleSize : bar,
        trackWidth: track,
        trackHeight: bar,
        handleSize: lineHandleSize,
        trackRadius: radiusFull,
        handleRadius: radiusFull,
      );
    }
    final double track = small ? trackWidthSmall : trackWidth;
    final double bar = small ? trackHeightSmall : trackHeight;
    return LumiereSwitchMetrics(
      width: track,
      height: bar,
      trackWidth: track,
      trackHeight: bar,
      handleSize: small ? handleSizeSmall : handleSize,
      trackRadius: type == LumiereSwitchType.circle
          ? radiusFull
          : radiusRectangle,
      handleRadius: type == LumiereSwitchType.circle
          ? radiusFull
          : radiusRectangle,
    );
  }
}

/// The measured box of one switch variant.
///
/// It is public so [LumiereSwitchPainter] can state what it draws; it is not
/// exported by the package entry point.
@immutable
class LumiereSwitchMetrics {
  const LumiereSwitchMetrics({
    required this.width,
    required this.height,
    required this.trackWidth,
    required this.trackHeight,
    required this.handleSize,
    required this.trackRadius,
    required this.handleRadius,
  });

  /// Layout size, which is also the interactive box.
  final double width;
  final double height;

  /// Visible track.
  final double trackWidth;
  final double trackHeight;

  /// Visible handle.
  final double handleSize;

  final double trackRadius;
  final double handleRadius;

  /// Distance between the handle and the end of the box.
  ///
  /// Derived from the measured values: the handle is centred in the box, so
  /// the gap is half the difference between the box and the handle. It is 4 px
  /// for the default size, which is [ArcoSpace.spaceXs], and 0 px for the line
  /// variant, whose handle is taller than its track.
  double get handleInset => (height - handleSize) / 2;

  /// Left edge of the handle for a given value.
  double handleLeft(bool on) => on ? width - handleSize - handleInset : handleInset;

  @override
  bool operator ==(Object other) =>
      other is LumiereSwitchMetrics &&
      other.width == width &&
      other.height == height &&
      other.trackWidth == trackWidth &&
      other.trackHeight == trackHeight &&
      other.handleSize == handleSize &&
      other.trackRadius == trackRadius &&
      other.handleRadius == handleRadius;

  @override
  int get hashCode => Object.hash(
        width,
        height,
        trackWidth,
        trackHeight,
        handleSize,
        trackRadius,
        handleRadius,
      );
}

/// Width of the focus indicator.
///
/// The geometry export records no focus outline for this control. Two pixels
/// is the thinnest ring that stays perceptible when it is drawn at 1x.
const double _focusRingWidth = 2;

/// Distance between the focus ring and the edge of the interactive box.
///
/// Derived from [_focusRingWidth]: the ring is drawn inside the measured box,
/// so it never enlarges the layout.
const double _focusRingInset = 1;

/// Switch of the design system.
///
/// Mirrors the axes of the `switch` component set in the design file: `type`
/// (`circle`, `rectangle`, `line`), `size` (`default`, `small`), `on`, which is
/// [value], `disabled`, `handleIcon` and `trackContent`. The design also
/// declares a `state` axis whose `hover` option is a real widget state in
/// Flutter rather than a property, so the widget resolves it itself.
///
/// The control carries its own accessibility: name, role, on/off state,
/// disabled state, keyboard activation and a visible focus ring. The state is
/// never carried by colour alone either: the handle sits at the end of the
/// track that matches the value.
///
/// Geometry comes from `design/reference/control-geometry.json`: a 40 x 24 box
/// with a 16 x 16 handle for the default size, 28 x 16 with a 10 x 10 handle
/// for the small size, and a 36 x 6 or 28 x 4 bar with a 20 x 20 handle for the
/// line type.
///
/// The design pairs the line type with an empty track and a plain handle only,
/// so [trackContent] must stay [LumiereSwitchTrackContent.none] and
/// [handleIcon] must stay null for that type; the constructor asserts it.
class LumiereSwitch extends StatefulWidget {
  const LumiereSwitch({
    super.key,
    this.value = false,
    this.type = LumiereSwitchType.circle,
    this.size = LumiereSwitchSize.standard,
    this.disabled = false,
    this.handleIcon,
    this.trackContent = LumiereSwitchTrackContent.none,
    this.trackIcon,
    this.label,
    this.semanticLabel,
    this.onChanged,
    this.focusNode,
  }) : assert(
          type != LumiereSwitchType.line ||
              trackContent == LumiereSwitchTrackContent.none,
          'The design only pairs the line type with an empty track.',
        ),
        assert(
          type != LumiereSwitchType.line || handleIcon == null,
          'The design only pairs the line type with a plain handle.',
        );

  /// Whether the switch is on.
  final bool value;

  final LumiereSwitchType type;
  final LumiereSwitchSize size;

  /// Draws the control as disabled and makes it inert.
  final bool disabled;

  /// Optional icon inside the handle.
  final Widget? handleIcon;

  final LumiereSwitchTrackContent trackContent;

  /// Icon of the `icon` track content.
  final Widget? trackIcon;

  /// Visible label of the control, drawn beside the measured track. It is also
  /// the accessible name.
  final String? label;

  /// Accessible name used when there is no visible [label], which is what an
  /// icon-only switch needs.
  final String? semanticLabel;

  /// Called with the next value of the switch. A null callback also disables
  /// the control, as a null `onPressed` disables [LumiereButton].
  final ValueChanged<bool>? onChanged;

  /// Optional external focus node. The widget owns one when this is null.
  final FocusNode? focusNode;

  /// Whether the control can be operated at all.
  bool get isEnabled => onChanged != null && !disabled;

  @override
  State<LumiereSwitch> createState() => _LumiereSwitchState();
}

class _LumiereSwitchState extends State<LumiereSwitch>
    with TickerProviderStateMixin, ToggleableStateMixin {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  bool get value => widget.value;

  @override
  bool get tristate => false;

  @override
  ValueChanged<bool?>? get onChanged =>
      widget.isEnabled ? _handleChanged : null;

  void _handleChanged(bool? next) => widget.onChanged?.call(next ?? false);

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
    final LumiereSwitchMetrics metrics =
        _SwitchGeometry.metrics(widget.type, widget.size);

    // One node carries the whole control: name, role, state, focus and the tap
    // action. Merging keeps a screen reader from reading the state and the
    // action as two separate things.
    return MergeSemantics(
      child: Semantics(
        // The visible label is excluded from the tree, so the name is declared
        // once, here.
        label: widget.label ?? widget.semanticLabel,
        toggled: widget.value,
        enabled: enabled,
        child: buildToggleableWithChild(
          focusNode: _focusNode,
          mouseCursor: WidgetStateMouseCursor.clickable,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: metrics.width,
                height: metrics.height,
                child: CustomPaint(
                  painter: _painter(colors, metrics),
                  child: _content(colors, metrics),
                ),
              ),
              if (widget.label != null) ...<Widget>[
                // The text variant measures 51 x 24 for the 40 px track: the
                // closest approved step is ArcoSpace.spaceSm (8).
                const SizedBox(width: ArcoSpace.spaceSm),
                ExcludeSemantics(
                  child: Text(
                    widget.label!,
                    style: tokens
                        .text(
                          size: widget.size == LumiereSwitchSize.small
                              ? ArcoType.size12
                              : ArcoType.size14,
                        )
                        .copyWith(
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

  /// The icon inside the track and the icon inside the handle.
  ///
  /// Both are decorative: they are excluded from the semantics tree and take
  /// their colour from the surface they sit on.
  Widget? _content(LumiereColors colors, LumiereSwitchMetrics metrics) {
    final bool enabled = widget.isEnabled;
    final bool small = widget.size == LumiereSwitchSize.small;
    final double handleLeft = metrics.handleLeft(widget.value);
    final double handleIconSize =
        small ? _SwitchGeometry.handleIconSizeSmall : _SwitchGeometry.handleIconSize;
    final double trackIconSize =
        small ? _SwitchGeometry.trackIconSizeSmall : _SwitchGeometry.trackIconSize;

    final Widget? handleIcon = widget.handleIcon == null
        ? null
        : Positioned(
            left: handleLeft + (metrics.handleSize - handleIconSize) / 2,
            top: (metrics.height - handleIconSize) / 2,
            width: handleIconSize,
            height: handleIconSize,
            child: ExcludeSemantics(
              child: IconTheme.merge(
                data: IconThemeData(
                  size: handleIconSize,
                  // The handle is `textOnAccent` in both themes, so the icon
                  // inside it needs a role that is dark in both: the accent
                  // ramp measures 3.74:1 and 5.19:1 against it.
                  color: enabled ? colors.accent.normal : colors.accent.disabled,
                ),
                child: widget.handleIcon!,
              ),
            ),
          );

    final Widget? trackIcon = widget.trackContent != LumiereSwitchTrackContent.icon ||
            widget.trackIcon == null
        ? null
        : Positioned(
            // The content sits at the end opposite the handle.
            left: widget.value
                ? _SwitchGeometry.contentInset
                : metrics.width - _SwitchGeometry.contentInset - trackIconSize,
            top: (metrics.height - trackIconSize) / 2,
            width: trackIconSize,
            height: trackIconSize,
            child: ExcludeSemantics(
              child: IconTheme.merge(
                data: IconThemeData(
                  size: trackIconSize,
                  // The track is either the accent fill or the border colour,
                  // and `textOnAccent` is the only role that reaches 3:1
                  // against both: 3.74:1 and 3.11:1 in the dark theme, 5.19:1
                  // and 3.24:1 in the light theme.
                  color: colors.textOnAccent,
                ),
                child: widget.trackIcon!,
              ),
            ),
          );

    if (handleIcon == null && trackIcon == null) {
      return null;
    }
    return Stack(children: <Widget>[?trackIcon, ?handleIcon]);
  }

  /// Resolves every colour of the control from the tokens.
  ///
  /// The design declares `on`, `disabled` and `hover` for this component and no
  /// `pressed` option, so a press keeps the resting colours instead of
  /// inventing a step.
  ///
  /// The off track uses `borderHeavy`, the role the accessibility contract
  /// reserves for the boundary of a control that needs a visible edge: it
  /// measures 3.11:1 against the page in the dark theme and 3.24:1 in the light
  /// theme, and the same figures against the white handle. The hover step of
  /// the border scale is `borderStrong`; against it the handle drops to 1.60:1
  /// in the light theme, which the contract records as an open item rather than
  /// hiding: hover is transient and the position of the handle, not its
  /// contrast, is what carries the value.
  LumiereSwitchPainter _painter(LumiereColors colors, LumiereSwitchMetrics metrics) {
    final bool enabled = isInteractive;
    final bool hovered = states.contains(WidgetState.hovered);
    final bool focused = states.contains(WidgetState.focused);

    Color track;
    if (!enabled) {
      track = widget.value ? colors.accent.disabled : colors.fillDefault;
    } else if (widget.value) {
      track = hovered ? colors.accent.hover : colors.accent.normal;
    } else {
      track = hovered ? colors.borderStrong : colors.borderHeavy;
    }

    return LumiereSwitchPainter(
      metrics: metrics,
      handleLeft: metrics.handleLeft(widget.value),
      trackFill: track,
      handleFill: colors.textOnAccent,
      // The ring is drawn inside the box. On the circle and rectangle types it
      // lands on the track, so it uses the page colour as a knockout; on the
      // line type it lands on the page, so it uses the accent ramp.
      focusRing: !focused
          ? null
          : widget.type == LumiereSwitchType.line
              ? colors.accent.normal
              : colors.surfaceBase,
    );
  }
}

/// Painter of [LumiereSwitch].
///
/// It is public so the tests can assert the colours the component resolved from
/// the tokens; it is not exported by the package entry point.
class LumiereSwitchPainter extends CustomPainter {
  const LumiereSwitchPainter({
    required this.metrics,
    required this.handleLeft,
    required this.trackFill,
    required this.handleFill,
    required this.focusRing,
  });

  /// Measured box of the variant.
  final LumiereSwitchMetrics metrics;

  /// Left edge of the handle. Its position is what shows the value.
  final double handleLeft;

  /// Fill of the track.
  final Color trackFill;

  /// Fill of the handle.
  final Color handleFill;

  /// Colour of the focus ring, or null when the control is not focused.
  final Color? focusRing;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: metrics.trackWidth,
          height: metrics.trackHeight,
        ),
        Radius.circular(metrics.trackRadius),
      ),
      Paint()..color = trackFill,
    );

    if (focusRing != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(_focusRingInset),
          Radius.circular(metrics.trackRadius),
        ),
        Paint()
          ..color = focusRing!
          ..style = PaintingStyle.stroke
          ..strokeWidth = _focusRingWidth,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          handleLeft,
          (size.height - metrics.handleSize) / 2,
          metrics.handleSize,
          metrics.handleSize,
        ),
        Radius.circular(metrics.handleRadius),
      ),
      Paint()..color = handleFill,
    );
  }

  @override
  bool shouldRepaint(LumiereSwitchPainter oldDelegate) =>
      oldDelegate.metrics != metrics ||
      oldDelegate.handleLeft != handleLeft ||
      oldDelegate.trackFill != trackFill ||
      oldDelegate.handleFill != handleFill ||
      oldDelegate.focusRing != focusRing;
}
