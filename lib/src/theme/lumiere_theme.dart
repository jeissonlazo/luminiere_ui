import 'package:flutter/material.dart';

import '../tokens/lumiere_tokens.dart';
import '../tokens/tokens.g.dart';

/// Entry point of the design system theme.
///
/// Maps the design tokens onto [ThemeData] so stock Material widgets inherit the
/// same identity, and publishes [LumiereTokens] as a theme extension for the
/// components of this package.
///
/// Material's `visualDensity` is deliberately left at its default: control sizes
/// are decided by the design tokens, not by Material. A theme-level density
/// would silently shrink every token-driven control.
///
/// The typeface is the one parameter a consumer is expected to change. The
/// package declares [ArcoType.fontFamily] and redistributes no font file, so an
/// application registers its own family in `pubspec.yaml` and names it here:
///
/// ```dart
/// theme: LumiereThemeData.dark(fontFamily: 'My Family'),
/// ```
///
/// The name MUST be the one the application declared, not the name inside the
/// font file. A family the engine cannot resolve falls back to the platform
/// default without an error, which is why the family is worth asserting in a
/// test of the consuming application.
abstract final class LumiereThemeData {
  /// Dark theme, the default of the product.
  static ThemeData dark({String fontFamily = ArcoType.fontFamily}) =>
      _build(LumiereColors.dark, Brightness.dark, fontFamily);

  /// Light theme.
  static ThemeData light({String fontFamily = ArcoType.fontFamily}) =>
      _build(LumiereColors.light, Brightness.light, fontFamily);

  static ThemeData _build(
    LumiereColors colors,
    Brightness brightness,
    String fontFamily,
  ) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: colors.accent.normal,
          brightness: brightness,
        ).copyWith(
          primary: colors.accent.normal,
          onPrimary: colors.textOnAccent,
          error: colors.danger.normal,
          onError: colors.textOnAccent,
          surface: colors.surfaceBase,
          onSurface: colors.textPrimary,
          onSurfaceVariant: colors.textSecondary,
          outlineVariant: colors.borderSubtle,
        );

    TextStyle style(double size, FontWeight weight) => TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          height:
              (ArcoType.lineHeightFor(size) ?? size * 1.4) / size,
          fontWeight: weight,
          color: colors.textPrimary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.surfaceBase,
      canvasColor: colors.surfaceContainer,
      dividerColor: colors.borderSubtle,
      textTheme: TextTheme(
        headlineSmall: style(ArcoType.size24, FontWeight.w600),
        titleLarge: style(ArcoType.size20, FontWeight.w600),
        titleMedium: style(ArcoType.size16, FontWeight.w600),
        bodyLarge: style(ArcoType.size16, FontWeight.w400),
        bodyMedium: style(ArcoType.size14, FontWeight.w400),
        bodySmall: style(ArcoType.size13, FontWeight.w400),
        labelMedium: style(ArcoType.size12, FontWeight.w500),
      ),
      extensions: <ThemeExtension<dynamic>>[
        LumiereTokens(
          colors: colors,
          brightness: brightness,
          fontFamily: fontFamily,
        ),
      ],
    );
  }
}
