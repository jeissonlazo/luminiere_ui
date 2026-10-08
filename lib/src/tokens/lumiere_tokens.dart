import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'tokens.g.dart';

/// Colores semanticos del sistema.
///
/// Los componentes NUNCA usan un literal: leen de aqui. Es lo que hace
/// verificable la regla de "prohibido un color literal fuera del archivo de
/// tokens" (lint sobre el paquete).
@immutable
class LumiereColors {
  const LumiereColors({
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderSubtle,
    required this.accent,
  });

  final Color surfaceBase;
  final Color surfaceRaised;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderSubtle;
  final Color accent;

  LumiereColors lerpTo(LumiereColors other, double t) => LumiereColors(
        surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
        surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
        textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
        textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
        borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
        accent: Color.lerp(accent, other.accent, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is LumiereColors &&
      other.surfaceBase == surfaceBase &&
      other.surfaceRaised == surfaceRaised &&
      other.textPrimary == textPrimary &&
      other.textSecondary == textSecondary &&
      other.borderSubtle == borderSubtle &&
      other.accent == accent;

  @override
  int get hashCode => Object.hash(
        surfaceBase,
        surfaceRaised,
        textPrimary,
        textSecondary,
        borderSubtle,
        accent,
      );
}

/// Roles tipograficos del sistema.
@immutable
class LumiereTypography {
  const LumiereTypography({
    required this.display,
    required this.heading,
    required this.body,
    required this.label,
  });

  final TextStyle display;
  final TextStyle heading;
  final TextStyle body;
  final TextStyle label;

  LumiereTypography lerpTo(LumiereTypography other, double t) => LumiereTypography(
        display: TextStyle.lerp(display, other.display, t)!,
        heading: TextStyle.lerp(heading, other.heading, t)!,
        body: TextStyle.lerp(body, other.body, t)!,
        label: TextStyle.lerp(label, other.label, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is LumiereTypography &&
      other.display == display &&
      other.heading == heading &&
      other.body == body &&
      other.label == label;

  @override
  int get hashCode => Object.hash(display, heading, body, label);
}

/// Escala cerrada de espaciado. Un valor fuera de la escala es un defecto de
/// revision, no una preferencia.
@immutable
class LumiereSpacing {
  const LumiereSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  List<double> get scale => <double>[xxs, xs, sm, md, lg, xl, xxl];

  bool isOnScale(double value) => scale.contains(value);

  LumiereSpacing lerpTo(LumiereSpacing other, double t) => t < 0.5 ? this : other;

  @override
  bool operator ==(Object other) =>
      other is LumiereSpacing &&
      other.xxs == xxs &&
      other.xs == xs &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl &&
      other.xxl == xxl;

  @override
  int get hashCode => Object.hash(xxs, xs, sm, md, lg, xl, xxl);
}

/// Escala cerrada de radios.
@immutable
class LumiereRadii {
  const LumiereRadii({required this.sm, required this.md, required this.lg});

  final double sm;
  final double md;
  final double lg;

  List<double> get scale => <double>[sm, md, lg];

  bool isOnScale(double value) => scale.contains(value);

  LumiereRadii lerpTo(LumiereRadii other, double t) => t < 0.5 ? this : other;

  @override
  bool operator ==(Object other) =>
      other is LumiereRadii && other.sm == sm && other.md == md && other.lg == lg;

  @override
  int get hashCode => Object.hash(sm, md, lg);
}

/// Conjunto completo de tokens del sistema.
///
/// Es la unica entrada visual del paquete: los componentes leen de aqui y el
/// tema los publica por `ThemeExtension`.
@immutable
class LumiereTokens {
  const LumiereTokens({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radii,
    required this.controlHeightSmall,
    required this.controlHeightMedium,
    required this.controlHeightLarge,
    required this.focusRingWidth,
  });

  final LumiereColors colors;
  final LumiereTypography typography;
  final LumiereSpacing spacing;
  final LumiereRadii radii;
  final double controlHeightSmall;
  final double controlHeightMedium;
  final double controlHeightLarge;
  final double focusRingWidth;

  /// Juego **provisional y no verificado**.
  ///
  /// Existe solo para que la galeria y los goldens rendericen mientras Figma no
  /// sea accesible. Al integrar los tokens reales se sustituye por la salida de
  /// `tools/generate-tokens.mjs` y este constructor desaparece.
  factory LumiereTokens.provisional() {
    const String? family = LumiereGeneratedValues.fontFamily;
    return LumiereTokens(
      colors: const LumiereColors(
        surfaceBase: LumiereGeneratedValues.surfaceBase,
        surfaceRaised: LumiereGeneratedValues.surfaceRaised,
        textPrimary: LumiereGeneratedValues.textPrimary,
        textSecondary: LumiereGeneratedValues.textSecondary,
        borderSubtle: LumiereGeneratedValues.borderSubtle,
        accent: LumiereGeneratedValues.accent,
      ),
      typography: LumiereTypography(
        display: TextStyle(
          fontFamily: family,
          fontSize: LumiereGeneratedValues.displaySize,
          height: LumiereGeneratedValues.displayHeight / LumiereGeneratedValues.displaySize,
          fontWeight: FontWeight.w600,
        ),
        heading: TextStyle(
          fontFamily: family,
          fontSize: LumiereGeneratedValues.headingSize,
          height: LumiereGeneratedValues.headingHeight / LumiereGeneratedValues.headingSize,
          fontWeight: FontWeight.w600,
        ),
        body: TextStyle(
          fontFamily: family,
          fontSize: LumiereGeneratedValues.bodySize,
          height: LumiereGeneratedValues.bodyHeight / LumiereGeneratedValues.bodySize,
          fontWeight: FontWeight.w400,
        ),
        label: TextStyle(
          fontFamily: family,
          fontSize: LumiereGeneratedValues.labelSize,
          height: LumiereGeneratedValues.labelHeight / LumiereGeneratedValues.labelSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      spacing: LumiereSpacing(
        xxs: kProvisionalSpacingScale[0],
        xs: kProvisionalSpacingScale[1],
        sm: kProvisionalSpacingScale[2],
        md: kProvisionalSpacingScale[3],
        lg: kProvisionalSpacingScale[4],
        xl: kProvisionalSpacingScale[5],
        xxl: kProvisionalSpacingScale[6],
      ),
      radii: LumiereRadii(
        sm: kProvisionalRadiusScale[0],
        md: kProvisionalRadiusScale[1],
        lg: kProvisionalRadiusScale[2],
      ),
      controlHeightSmall: LumiereGeneratedValues.controlHeightSmall,
      controlHeightMedium: LumiereGeneratedValues.controlHeightMedium,
      controlHeightLarge: LumiereGeneratedValues.controlHeightLarge,
      focusRingWidth: LumiereGeneratedValues.focusRingWidth,
    );
  }

  LumiereTokens lerpTo(LumiereTokens other, double t) => LumiereTokens(
        colors: colors.lerpTo(other.colors, t),
        typography: typography.lerpTo(other.typography, t),
        spacing: spacing.lerpTo(other.spacing, t),
        radii: radii.lerpTo(other.radii, t),
        controlHeightSmall: t < 0.5 ? controlHeightSmall : other.controlHeightSmall,
        controlHeightMedium: t < 0.5 ? controlHeightMedium : other.controlHeightMedium,
        controlHeightLarge: t < 0.5 ? controlHeightLarge : other.controlHeightLarge,
        focusRingWidth: t < 0.5 ? focusRingWidth : other.focusRingWidth,
      );

  @override
  bool operator ==(Object other) =>
      other is LumiereTokens &&
      other.colors == colors &&
      other.typography == typography &&
      other.spacing == spacing &&
      other.radii == radii &&
      other.controlHeightSmall == controlHeightSmall &&
      other.controlHeightMedium == controlHeightMedium &&
      other.controlHeightLarge == controlHeightLarge &&
      other.focusRingWidth == focusRingWidth;

  @override
  int get hashCode => Object.hash(
        colors,
        typography,
        spacing,
        radii,
        controlHeightSmall,
        controlHeightMedium,
        controlHeightLarge,
        focusRingWidth,
      );
}
