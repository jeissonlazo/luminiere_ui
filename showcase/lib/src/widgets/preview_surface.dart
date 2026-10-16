import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

/// The panel a live example sits on.
///
/// One widget so every example in the gallery is presented against the same
/// surface: a component judged against a different background on every page
/// would not be comparable between pages.
class PreviewSurface extends StatelessWidget {
  const PreviewSurface({
    super.key,
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.padding,
    this.background,
  });

  final Widget child;
  final Alignment alignment;
  final EdgeInsetsGeometry? padding;

  /// Overrides the surface. A component with a subtle fill of its own reads
  /// better directly on the page background.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(ArcoSpace.spaceXl),
      decoration: BoxDecoration(
        color: background ?? tokens.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(ArcoRadius.radiusLg),
        border: Border.all(color: tokens.colors.borderSubtle),
      ),
      child: Align(alignment: alignment, child: child),
    );
  }
}
