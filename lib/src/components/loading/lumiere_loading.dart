import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../tokens/lumiere_tokens.dart';

/// An indeterminate loading indicator.
///
/// Mirrors the `Loading` component (rule `DS-COMP-012`), which the design declares
/// with no axis at all: there is one indicator, not a family of them.
///
/// The design declares a single indicator and no size axis: one vector of 40 by
/// 40. The size is a parameter because the button draws the same indicator smaller,
/// at its own icon size, and not because the design offers a family.
///
/// It does not settle: the rotation repeats for as long as it is mounted, so a
/// widget test must pump frames instead of waiting for the tree to settle.
class LumiereLoading extends StatefulWidget {
  const LumiereLoading({
    super.key,
    this.size = 40,
    this.color,
    this.semanticLabel,
  });

  /// Diameter in logical pixels. The design's component is 40; the button passes
  /// its own icon size.
  final double size;

  /// Defaults to the accent of the current theme.
  final Color? color;

  /// Announcement for assistive technology. When it is null the indicator is
  /// decorative and hidden from screen readers: the design system ships no
  /// user-visible string, so the caller decides.
  final String? semanticLabel;

  @override
  State<LumiereLoading> createState() => _LumiereLoadingState();
}

class _LumiereLoadingState extends State<LumiereLoading>
    with SingleTickerProviderStateMixin {
  /// The design declares no motion values yet, so this is a placeholder that will
  /// be replaced when it does. It is a duration and not a visual value, so no
  /// token governs it today.
  static const Duration _turn = Duration(milliseconds: 900);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _turn,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final Color color = widget.color ?? tokens.colors.accent.normal;

    Widget indicator = SizedBox.square(
      dimension: widget.size,
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          painter: _SpinnerPainter(
            color: color,
            // A tenth of the diameter: 2 at the default size, which is what the
            // design's own glyph uses. The exact value is pending confirmation.
            strokeWidth: widget.size / 10,
          ),
        ),
      ),
    );

    if (widget.semanticLabel != null) {
      indicator = Semantics(
        label: widget.semanticLabel,
        container: true,
        child: indicator,
      );
    } else {
      indicator = ExcludeSemantics(child: indicator);
    }
    return indicator;
  }
}

/// Draws the arc of the indicator.
class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Rect box = Offset.zero & size;
    final Rect arc = box.deflate(strokeWidth / 2);
    // Three quarters of a turn, which leaves the gap that reads as movement.
    canvas.drawArc(arc, 0, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
