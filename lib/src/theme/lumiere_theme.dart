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
abstract final class LumiereThemeData {
  /// Dark theme, the default of the product.
  static ThemeData dark() => _build(LumiereColors.dark, Brightness.dark);

  /// Light theme.
  static ThemeData light() => _build(LumiereColors.light, Brightness.light);

  static ThemeData _build(LumiereColors colors, Brightness brightness) {
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
          fontFamily: ArcoType.fontFamily,
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
        LumiereTokens(colors: colors, brightness: brightness),
      ],
    );
  }
}
