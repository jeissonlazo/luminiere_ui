import 'package:flutter/material.dart';

import '../../tokens/lumiere_tokens.dart';
import '../../tokens/tokens.g.dart';

/// Direction of a divider.
enum LumiereDividerOrientation { horizontal, vertical }

/// Where the label of a divider sits.
///
/// Mirrors the `align` axis of the `Divider` component. `none` is the design's own
/// value and is read here as the label shown without lines beside it, which is the
/// one interpretation in this component: it is recorded as pending confirmation
/// against the design file rather than presented as certain.
enum LumiereDividerAlign { start, center, end, none }

/// A separator, with an optional label.
///
/// Mirrors the axes of the `Divider` component (rule `DS-COMP-018`): orientation,
/// dashed, a label and where it sits.
///
/// It carries no margin on purpose. A separator is a line; the space around it
/// belongs to the layout that places it, not to the line.
class LumiereDivider extends StatelessWidget {
  const LumiereDivider({
    super.key,
    this.orientation = LumiereDividerOrientation.horizontal,
    this.label,
    this.align = LumiereDividerAlign.center,
    this.dashed = false,
  });

  final LumiereDividerOrientation orientation;

  /// Optional text in the middle of the line.
  final String? label;

  final LumiereDividerAlign align;

  /// Draws the line as a dashed stroke instead of a solid one.
  final bool dashed;

  bool get _hasLabel => label != null && label!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final Color line = tokens.colors.borderDefault;

    if (orientation == LumiereDividerOrientation.vertical) {
      // The parent decides the height: a vertical divider stretches with the row
      // it belongs to, and asking for an infinite height would fail anywhere the
      // height is not bounded.
      return _Line(
        color: line,
        dashed: dashed,
        horizontal: false,
        length: double.infinity,
      );
    }

    if (!_hasLabel) {
      return _Line(color: line, dashed: dashed, horizontal: true);
    }

    final Widget text = Text(
      label!,
      // The design places the label in a secondary role. Its tertiary text role
      // measures 4.68 in the light theme and 5.26 in the dark one, so it is above
      // the threshold for normal text either way.
      style: tokens.text(size: ArcoType.size14).copyWith(color: tokens.colors.textTertiary),
    );
    const Widget space = SizedBox(width: ArcoSpace.spaceSm);

    // The design keeps a line on both sides of the label, and the short one is on
    // the side the label sits: 21 px in the file for start and end, which is the
    // declared 20. Only the centred value has two equal lines.
    Widget shortLine() => SizedBox(
          width: ArcoSpace.spaceXl,
          child: _Line(color: line, dashed: dashed, horizontal: true),
        );
    Widget longLine() =>
        Expanded(child: _Line(color: line, dashed: dashed, horizontal: true));

    return switch (align) {
      LumiereDividerAlign.none => text,
      LumiereDividerAlign.start => Row(
          children: <Widget>[
            shortLine(),
            space,
            text,
            space,
            longLine(),
          ],
        ),
      LumiereDividerAlign.end => Row(
          children: <Widget>[
            longLine(),
            space,
            text,
            space,
            shortLine(),
          ],
        ),
      LumiereDividerAlign.center => Row(
          children: <Widget>[
            longLine(),
            space,
            text,
            space,
            longLine(),
          ],
        ),
    };
  }
}

/// One line of the divider.
///
/// A line carries no information, so it is hidden from screen readers; a label
/// does, and it keeps its own text semantics.
class _Line extends StatelessWidget {
  const _Line({
    required this.color,
    required this.dashed,
    required this.horizontal,
    this.length,
  });

  final Color color;
  final bool dashed;
  final bool horizontal;

  /// Fixed length, or null to take the space the parent offers.
  final double? length;

  @override
  Widget build(BuildContext context) {
    final double thickness = LumiereStrokes.hairline;
    final _DashedLinePainter? painter = dashed
        ? _DashedLinePainter(
            color: color,
            thickness: thickness,
            horizontal: horizontal,
          )
        : null;

    // A horizontal divider fills the width it is given, the way a rule fills a
    // column. A vertical one takes the height of the row it belongs to. A
    // horizontal divider inside an unbounded parent has to be wrapped by the
    // caller, which is the same rule Flutter applies to a stretch.
    return SizedBox(
      width: horizontal ? (length ?? double.infinity) : thickness,
      height: horizontal ? thickness : (length ?? double.infinity),
      child: painter == null
          ? ColoredBox(color: color)
          : CustomPaint(painter: painter, child: const SizedBox.expand()),
    );
  }
}

/// Draws a dashed straight line.
///
/// Flutter has no dashed line, so it is drawn by hand. The dash metrics come from
/// [LumiereStrokes], which records that the design declares none yet.
class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.horizontal,
  });

  final Color color;
  final double thickness;
  final bool horizontal;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    final double total = horizontal ? size.width : size.height;
    final double step = LumiereStrokes.dash + LumiereStrokes.gap;

    for (double at = 0; at < total; at += step) {
      final double end = (at + LumiereStrokes.dash).clamp(0, total);
      if (horizontal) {
        canvas.drawLine(
          Offset(at, size.height / 2),
          Offset(end, size.height / 2),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(size.width / 2, at),
          Offset(size.width / 2, end),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) =>
      old.color != color ||
      old.thickness != thickness ||
      old.horizontal != horizontal;
}
