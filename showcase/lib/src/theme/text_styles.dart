import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

/// Text styles used by the gallery's own chrome.
///
/// The gallery is documentation, so it renders text in more roles than a
/// product screen does: captions under a specimen, hexadecimal values, the
/// source of an example. They are derived from the design type scale rather
/// than written as literals, so the gallery itself obeys the token layer.
extension GalleryTextStyles on LumiereTokens {
  /// Body and headings.
  TextStyle primary(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) =>
      text(size: size, weight: weight).copyWith(color: color ?? colors.textPrimary);

  /// Supporting prose and table cells.
  TextStyle secondary(
    double size, {
    FontWeight weight = FontWeight.w400,
  }) =>
      text(size: size, weight: weight).copyWith(color: colors.textSecondary);

  /// Captions: specimen labels, rule identifiers, footnote prose.
  TextStyle tertiary(
    double size, {
    FontWeight weight = FontWeight.w400,
  }) =>
      text(size: size, weight: weight).copyWith(color: colors.textTertiary);

  /// Code and hexadecimal values.
  ///
  /// The design system declares no monospace family, so this is a platform
  /// stack rather than a token: it is chrome, not design-system surface.
  TextStyle mono(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: const <String>[
          'Consolas',
          'Menlo',
          'DejaVu Sans Mono',
          'Courier New',
        ],
        fontSize: size,
        height: 1.6,
        fontWeight: weight,
        color: color ?? colors.textSecondary,
      );

  /// The colour of a token as `#RRGGBB`, with its alpha when it is not opaque.
  ///
  /// The dark theme builds its text ramp and its fills out of white at
  /// different opacities rather than out of distinct greys. A hexadecimal
  /// without the alpha would therefore print `#FFFFFF` for every one of them
  /// and hide exactly the difference the colour page exists to show.
  static String hex(Color color) {
    final int argb = color.toARGB32();
    final String rgb = '#'
        '${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    final int alpha = (argb >> 24) & 0xFF;
    if (alpha == 0xFF) {
      return rgb;
    }
    return '$rgb ${(alpha * 100 / 255).round()}%';
  }
}
