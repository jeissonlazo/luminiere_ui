// GENERADO — no editar a mano.
//
// ============================================================================
//  ESTE ARCHIVO NO CONTIENE VALORES DE ARCO.
// ============================================================================
// Figma sigue bloqueado por el limite del plan Starter (ver docs/specs/001,
// seccion 9), asi que los valores de abajo son un juego NEUTRO PROVISIONAL que
// solo existe para que la galeria y los goldens puedan renderizar.
//
//   * NO son decisiones de diseno.
//   * NO deben citarse como tokens DS-*.
//   * NO deben copiarse a la aplicacion.
//
// Reemplazo previsto (una sola orden, sin tocar codigo):
//   node tools/generate-tokens.mjs docs/constraints/design-tokens.json
// ============================================================================

import 'dart:ui' show Color;

/// Escala de espaciado provisional, en pixeles logicos.
const List<double> kProvisionalSpacingScale = <double>[4, 8, 12, 16, 24, 32, 48];

/// Escala de radios provisional, en pixeles logicos.
const List<double> kProvisionalRadiusScale = <double>[4, 8, 12];

/// Valores crudos provisionales. Consumidos solo por `LumiereTokens`.
abstract final class LumiereGeneratedValues {
  // Superficies y texto. Grises neutros a proposito: no deben parecer una
  // decision de marca.
  static const Color surfaceBase = Color(0xFF141518);
  static const Color surfaceRaised = Color(0xFF1C1E23);
  static const Color textPrimary = Color(0xFFE8EAED);
  static const Color textSecondary = Color(0xFF9AA0A6);
  static const Color borderSubtle = Color(0xFF2A2D34);

  /// Deliberadamente neutro: no hay color de marca aprobado todavia.
  static const Color accent = Color(0xFF7C8595);

  // Tipografia.
  static const String? fontFamily = null; // fuente del sistema
  static const double displaySize = 24;
  static const double displayHeight = 32;
  static const double headingSize = 16;
  static const double headingHeight = 24;
  static const double bodySize = 14;
  static const double bodyHeight = 20;
  static const double labelSize = 12;
  static const double labelHeight = 16;

  // Controles.
  static const double controlHeightSmall = 24;
  static const double controlHeightMedium = 28;
  static const double controlHeightLarge = 34;
  static const double focusRingWidth = 2;
}
