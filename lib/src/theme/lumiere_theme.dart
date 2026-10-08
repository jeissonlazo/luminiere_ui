import 'package:flutter/material.dart';

import '../tokens/lumiere_tokens.dart';

/// Densidad de la interfaz.
///
/// Hoy solo existe la estandar (decision acordada: una sola densidad al
/// principio). El tipo existe para que añadir `compact` mas adelante sea un
/// cambio de datos, no de API.
enum LumiereDensity { standard }

/// Extension de tema que publica los tokens a traves del `ThemeData`.
///
/// Los componentes leen de aqui y no de constantes globales: asi el mismo
/// componente sirve para cualquier juego de tokens, y el cambio de tema o de
/// densidad no obliga a ramificar codigo.
@immutable
class LumiereTheme extends ThemeExtension<LumiereTheme> {
  const LumiereTheme({
    required this.tokens,
    this.density = LumiereDensity.standard,
  });

  final LumiereTokens tokens;
  final LumiereDensity density;

  /// Devuelve la extension activa.
  ///
  /// Si falta, falla en modo debug con un mensaje que dice que hacer en vez de
  /// devolver valores silenciosamente equivocados.
  static LumiereTheme of(BuildContext context) {
    final LumiereTheme? extension = Theme.of(context).extension<LumiereTheme>();
    assert(
      extension != null,
      'Falta LumiereTheme en el ThemeData. Construye el tema con '
      'LumiereThemeData.dark() o LumiereThemeData.light().',
    );
    return extension ?? LumiereTheme(tokens: LumiereTokens.provisional());
  }

  @override
  LumiereTheme copyWith({LumiereTokens? tokens, LumiereDensity? density}) =>
      LumiereTheme(
        tokens: tokens ?? this.tokens,
        density: density ?? this.density,
      );

  @override
  LumiereTheme lerp(ThemeExtension<LumiereTheme>? other, double t) {
    if (other is! LumiereTheme) {
      return this;
    }
    return LumiereTheme(
      tokens: tokens.lerpTo(other.tokens, t),
      density: t < 0.5 ? density : other.density,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LumiereTheme && other.tokens == tokens && other.density == density;

  @override
  int get hashCode => Object.hash(tokens, density);
}

/// Punto de entrada del tema del sistema.
///
/// Mapea los tokens a `ThemeData` para que los widgets de stock tambien hereden
/// la identidad visual, y registra [LumiereTheme] como extension.
abstract final class LumiereThemeData {
  static ThemeData dark({LumiereTokens? tokens}) =>
      _build(tokens ?? LumiereTokens.provisional(), Brightness.dark);

  static ThemeData light({LumiereTokens? tokens}) =>
      _build(tokens ?? LumiereTokens.provisional(), Brightness.light);

  static ThemeData _build(LumiereTokens tokens, Brightness brightness) {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: tokens.colors.accent,
      brightness: brightness,
    ).copyWith(
      primary: tokens.colors.accent,
      surface: tokens.colors.surfaceBase,
      onSurface: tokens.colors.textPrimary,
      onSurfaceVariant: tokens.colors.textSecondary,
      outlineVariant: tokens.colors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.colors.surfaceBase,
      canvasColor: tokens.colors.surfaceBase,
      dividerColor: tokens.colors.borderSubtle,
      textTheme: TextTheme(
        headlineSmall: tokens.typography.display,
        titleMedium: tokens.typography.heading,
        bodyMedium: tokens.typography.body,
        labelMedium: tokens.typography.label,
      ),
      extensions: <ThemeExtension<dynamic>>[
        LumiereTheme(tokens: tokens),
      ],
    );
  }
}
