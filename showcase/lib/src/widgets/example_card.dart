import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';
import 'code_block.dart';
import 'preview_surface.dart';

/// A live example with its Dart source.
///
/// The component is rendered for real, so hover, focus, keyboard operation and
/// the disabled state can all be exercised in place; the source sits behind a
/// toggle rather than beside it, so a page of examples stays readable.
class ExampleCard extends StatefulWidget {
  const ExampleCard({
    super.key,
    required this.code,
    required this.child,
    this.title,
    this.description,
    this.previewAlignment = Alignment.centerLeft,
    this.previewPadding,
    this.background,
  });

  /// Dart source of the example, as it would be written by a consumer.
  final String code;

  /// The live component.
  final Widget child;

  final String? title;
  final String? description;

  /// Where the example sits on the preview surface.
  final Alignment previewAlignment;

  final EdgeInsetsGeometry? previewPadding;

  /// Overrides the preview surface. Some components read better on the page
  /// background than on a panel.
  final Color? background;

  @override
  State<ExampleCard> createState() => _ExampleCardState();
}

class _ExampleCardState extends State<ExampleCard> {
  bool _codeOpen = false;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.title != null)
          Text(
            widget.title!,
            style: tokens.primary(ArcoType.size14, weight: FontWeight.w600),
          ),
        if (widget.description != null) ...<Widget>[
          const SizedBox(height: ArcoSpace.spaceXs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(
              widget.description!,
              style: tokens.secondary(ArcoType.size13),
            ),
          ),
        ],
        if (widget.title != null || widget.description != null)
          const SizedBox(height: ArcoSpace.spaceSm),

        // The preview surface.
        PreviewSurface(
          alignment: widget.previewAlignment,
          padding: widget.previewPadding,
          background: widget.background,
          child: widget.child,
        ),

        const SizedBox(height: ArcoSpace.spaceSm),
        Align(
          alignment: Alignment.centerLeft,
          child: LumiereButton(
            label: _codeOpen ? 'Hide code' : 'Show code',
            type: LumiereButtonType.text,
            size: LumiereButtonSize.small,
            leadingIcon: const Icon(LucideIcons.code, size: 14),
            onPressed: () => setState(() => _codeOpen = !_codeOpen),
          ),
        ),
        if (_codeOpen) ...<Widget>[
          const SizedBox(height: ArcoSpace.spaceSm),
          CodeBlock(code: widget.code),
        ],
      ],
    );
  }
}

/// One specimen in a variant matrix: the component with its label underneath.
///
/// The caption is what makes a matrix verifiable: it names the axis option the
/// specimen was built with, so a reader can compare the rendering against the
/// design file's option list.
class Sample extends StatelessWidget {
  const Sample({
    super.key,
    required this.label,
    required this.child,
    this.note,
    this.minWidth,
  });

  final String label;
  final Widget child;

  /// Second caption line, for the value an option resolves to.
  final String? note;

  /// Keeps a matrix of uneven specimens on a common column width.
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth ?? 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          child,
          const SizedBox(height: ArcoSpace.spaceSm),
          Text(label, style: tokens.tertiary(ArcoType.size12)),
          if (note != null)
            Text(note!, style: tokens.tertiary(ArcoType.size10)),
        ],
      ),
    );
  }
}

/// Lays out specimens in a wrapping grid.
class SampleGrid extends StatelessWidget {
  const SampleGrid({super.key, required this.samples, this.spacing});

  final List<Widget> samples;

  /// Horizontal gap. Wider than the vertical one because a specimen is wider
  /// than it is tall.
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing ?? ArcoSpace.spaceXl * 1.5,
      runSpacing: ArcoSpace.spaceXl,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: samples,
    );
  }
}
