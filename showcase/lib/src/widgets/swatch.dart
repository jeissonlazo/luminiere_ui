import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';

/// A colour token, shown as a filled rectangle.
///
/// The hexadecimal value is derived from the token itself rather than written
/// beside it, so a swatch cannot disagree with the value it documents.
class Swatch extends StatelessWidget {
  const Swatch({
    super.key,
    required this.name,
    required this.color,
    this.note,
    this.width = 140,
    this.height = 52,
  });

  final String name;
  final Color color;
  final String? note;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
              border: Border.all(color: colors.borderDefault),
            ),
          ),
          const SizedBox(height: ArcoSpace.spaceXs),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: tokens.primary(ArcoType.size12, weight: FontWeight.w500),
          ),
          Text(
            GalleryTextStyles.hex(color),
            style: tokens.mono(ArcoType.size10, color: colors.textTertiary),
          ),
          if (note != null)
            Text(note!, style: tokens.tertiary(ArcoType.size10)),
        ],
      ),
    );
  }
}

/// A colour token that is meant to be read as text, shown as text.
///
/// A fill token can be judged from a rectangle; a text token cannot. This shows
/// the colour as type on the container it is specified against.
class InkSwatch extends StatelessWidget {
  const InkSwatch({
    super.key,
    required this.name,
    required this.color,
    this.sample = 'The quick brown fox',
    this.width = 220,
    this.background,
  });

  final String name;
  final Color color;
  final String sample;
  final double width;

  /// The surface the ink is drawn on. Defaults to the container level, which is
  /// where text usually sits.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: ArcoSpace.spaceMd,
              vertical: ArcoSpace.spaceSm,
            ),
            decoration: BoxDecoration(
              color: background ?? colors.surfaceContainer,
              borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Text(
              sample,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tokens.primary(ArcoType.size14, color: color),
            ),
          ),
          const SizedBox(height: ArcoSpace.spaceXs),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: tokens.primary(ArcoType.size12, weight: FontWeight.w500),
          ),
          Text(
            GalleryTextStyles.hex(color),
            style: tokens.mono(ArcoType.size10, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// A titled row of swatches.
class SwatchGroup extends StatelessWidget {
  const SwatchGroup({
    super.key,
    required this.title,
    required this.children,
    this.note,
  });

  final String title;
  final String? note;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: tokens.primary(ArcoType.size13, weight: FontWeight.w600),
        ),
        if (note != null) ...<Widget>[
          const SizedBox(height: 2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Text(note!, style: tokens.tertiary(ArcoType.size12)),
          ),
        ],
        const SizedBox(height: ArcoSpace.spaceMd),
        Wrap(
          spacing: ArcoSpace.spaceMd,
          runSpacing: ArcoSpace.spaceMd,
          children: children,
        ),
      ],
    );
  }
}
