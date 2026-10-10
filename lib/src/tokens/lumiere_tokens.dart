import 'package:flutter/material.dart';

import 'tokens.g.dart';

/// The seven-step status ramp used by the design system.
///
/// The design file defines the same ramp for primary, success, warning and
/// danger, with the same meaning in every step. That meaning is taken from the
/// descriptions the file itself attaches to each token, not from an
/// interpretation:
///
/// | step | meaning (design description)     |
/// |------|----------------------------------|
/// | 1    | subtle background                |
/// | 2    | disabled text                    |
/// | 3    | disabled                         |
/// | 4    | special cases                    |
/// | 5    | hover                            |
/// | 6    | normal                           |
/// | 7    | pressed                          |
@immutable
class LumiereStatusColors {
  const LumiereStatusColors({
    required this.subtle,
    required this.textDisabled,
    required this.disabled,
    required this.normal,
    required this.hover,
    required this.active,
  });

  /// Subtle background built from this ramp.
  final Color subtle;

  /// Text colour when the control is disabled.
  final Color textDisabled;

  /// Fill colour when the control is disabled.
  final Color disabled;

  /// Default fill or foreground.
  final Color normal;

  /// Hover state.
  final Color hover;

  /// Pressed state.
  final Color active;

  static LumiereStatusColors _lerp(
    LumiereStatusColors a,
    LumiereStatusColors b,
    double t,
  ) =>
      LumiereStatusColors(
        subtle: Color.lerp(a.subtle, b.subtle, t)!,
        textDisabled: Color.lerp(a.textDisabled, b.textDisabled, t)!,
        disabled: Color.lerp(a.disabled, b.disabled, t)!,
        normal: Color.lerp(a.normal, b.normal, t)!,
        hover: Color.lerp(a.hover, b.hover, t)!,
        active: Color.lerp(a.active, b.active, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is LumiereStatusColors &&
      other.subtle == subtle &&
      other.textDisabled == textDisabled &&
      other.disabled == disabled &&
      other.normal == normal &&
      other.hover == hover &&
      other.active == active;

  @override
  int get hashCode =>
      Object.hash(subtle, textDisabled, disabled, normal, hover, active);
}

/// The colours the design file offers for a tag.
///
/// The names are the design's own and are kept untranslated in code because they
/// are an axis of the \`Tag\` component, not prose. The mapping from each name to a
/// palette family was verified by comparing the measured hexadecimal values with
/// the palette constants, not by interpreting the names.
enum LumiereTagColorName {
  neutral,
  romanticRed,
  wildGreen,
  blueTide,
  vitalityOrange,
  lateAutumnRed,
  dusk,
  youthPurple,
  magenta,
  ultimateBlue,
  seaBlue,
}

/// The colours of a tag: the soft background of the filled form, the stronger
/// background of the bordered form, and the ink of its text and icon.
@immutable
class LumiereTagColor {
  const LumiereTagColor({
    required this.subtle,
    required this.strong,
    required this.ink,
  });

  final Color subtle;
  final Color strong;
  final Color ink;

  static LumiereTagColor _lerp(LumiereTagColor a, LumiereTagColor b, double t) =>
      LumiereTagColor(
        subtle: Color.lerp(a.subtle, b.subtle, t)!,
        strong: Color.lerp(a.strong, b.strong, t)!,
        ink: Color.lerp(a.ink, b.ink, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is LumiereTagColor &&
      other.subtle == subtle &&
      other.strong == strong &&
      other.ink == ink;

  @override
  int get hashCode => Object.hash(subtle, strong, ink);
}

/// Semantic colour roles of the design system.
///
/// Every role points at a primitive from the Figma variables export. The
/// mapping follows the design's own descriptions:
///
/// * `bg.1..5`     page background, container levels 1 to 3, dropdown/tooltip
/// * `text.1..4`   emphasis, secondary, tertiary, disabled
/// * `border.1..4` subtle, normal, strong/hover, heavy/button outline
/// * `fill.1..4`   subtle-disabled, normal, strong, heavy overlays
/// * status ramps  see [LumiereStatusColors]
@immutable
class LumiereColors {
  const LumiereColors({
    required this.surfaceBase,
    required this.surfaceContainer,
    required this.surfaceRaised,
    required this.surfaceOverlay,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnAccent,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderHeavy,
    required this.fillSubtle,
    required this.fillDefault,
    required this.fillStrong,
    required this.fillHeavy,
    required this.tagColors,
  });

  /// Page background (`bg.1`).
  final Color surfaceBase;

  /// First container level (`bg.2`).
  final Color surfaceContainer;

  /// Second container level (`bg.3`).
  final Color surfaceRaised;

  /// Dropdown and tooltip background (`bg.5`).
  final Color surfaceOverlay;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  /// Foreground that sits on top of an accent fill (`bg.white`).
  final Color textOnAccent;

  /// Brand ramp (`primary`).
  final LumiereStatusColors accent;

  final LumiereStatusColors success;
  final LumiereStatusColors warning;
  final LumiereStatusColors danger;

  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderHeavy;

  /// Translucent overlays used for hover and pressed states on neutral
  /// surfaces.
  final Color fillSubtle;
  final Color fillDefault;
  final Color fillStrong;
  final Color fillHeavy;

  /// Tag colours, keyed by the name the design file uses for the axis.
  final Map<LumiereTagColorName, LumiereTagColor> tagColors;

  /// Tag colours for a name. Falls back to the neutral entry.
  LumiereTagColor tag(LumiereTagColorName name) =>
      tagColors[name] ?? tagColors[LumiereTagColorName.neutral]!;

  /// Roles for the dark theme.
  static const LumiereColors dark = LumiereColors(
    surfaceBase: ArcoSemanticDark.bg1,
    surfaceContainer: ArcoSemanticDark.bg2,
    surfaceRaised: ArcoSemanticDark.bg3,
    surfaceOverlay: ArcoSemanticDark.bg5,
    textPrimary: ArcoSemanticDark.text1,
    textSecondary: ArcoSemanticDark.text2,
    textTertiary: ArcoSemanticDark.text3,
    textDisabled: ArcoSemanticDark.text4,
    textOnAccent: ArcoSemanticDark.bgWhite,
    accent: LumiereStatusColors(
      subtle: ArcoSemanticDark.primary1,
      textDisabled: ArcoSemanticDark.primary2,
      disabled: ArcoSemanticDark.primary3,
      normal: ArcoSemanticDark.primary6,
      hover: ArcoSemanticDark.primary5,
      active: ArcoSemanticDark.primary7,
    ),
    success: LumiereStatusColors(
      subtle: ArcoSemanticDark.success1,
      textDisabled: ArcoSemanticDark.success2,
      disabled: ArcoSemanticDark.success3,
      normal: ArcoSemanticDark.success6,
      hover: ArcoSemanticDark.success5,
      active: ArcoSemanticDark.success7,
    ),
    warning: LumiereStatusColors(
      subtle: ArcoSemanticDark.warning1,
      textDisabled: ArcoSemanticDark.warning2,
      disabled: ArcoSemanticDark.warning3,
      normal: ArcoSemanticDark.warning6,
      hover: ArcoSemanticDark.warning5,
      active: ArcoSemanticDark.warning7,
    ),
    danger: LumiereStatusColors(
      subtle: ArcoSemanticDark.danger1,
      textDisabled: ArcoSemanticDark.danger2,
      disabled: ArcoSemanticDark.danger3,
      normal: ArcoSemanticDark.danger6,
      hover: ArcoSemanticDark.danger5,
      active: ArcoSemanticDark.danger7,
    ),
    borderSubtle: ArcoSemanticDark.border1,
    borderDefault: ArcoSemanticDark.border2,
    borderStrong: ArcoSemanticDark.border3,
    borderHeavy: ArcoSemanticDark.border4,
    fillSubtle: ArcoSemanticDark.fill1,
    fillDefault: ArcoSemanticDark.fill2,
    fillStrong: ArcoSemanticDark.fill3,
    fillHeavy: ArcoSemanticDark.fill4,
    tagColors: <LumiereTagColorName, LumiereTagColor>{
      LumiereTagColorName.neutral: LumiereTagColor(
        subtle: ArcoSemanticDark.fill2,
        strong: ArcoSemanticDark.fill3,
        ink: ArcoSemanticDark.text1,
      ),
      LumiereTagColorName.romanticRed: LumiereTagColor(
        subtle: ArcoPaletteDark.red1,
        strong: ArcoPaletteDark.red2,
        ink: ArcoPaletteDark.red6,
      ),
      LumiereTagColorName.wildGreen: LumiereTagColor(
        subtle: ArcoPaletteDark.green1,
        strong: ArcoPaletteDark.green2,
        ink: ArcoPaletteDark.green6,
      ),
      LumiereTagColorName.blueTide: LumiereTagColor(
        subtle: ArcoPaletteDark.cyan1,
        strong: ArcoPaletteDark.cyan2,
        ink: ArcoPaletteDark.cyan6,
      ),
      LumiereTagColorName.vitalityOrange: LumiereTagColor(
        subtle: ArcoPaletteDark.orange1,
        strong: ArcoPaletteDark.orange2,
        ink: ArcoPaletteDark.orange6,
      ),
      LumiereTagColorName.lateAutumnRed: LumiereTagColor(
        subtle: ArcoPaletteDark.orangeRedOrangeRed1,
        strong: ArcoPaletteDark.orangeRedOrangeRed2,
        ink: ArcoPaletteDark.orangeRedOrangeRed6,
      ),
      LumiereTagColorName.dusk: LumiereTagColor(
        subtle: ArcoPaletteDark.gold1,
        strong: ArcoPaletteDark.gold2,
        ink: ArcoPaletteDark.gold6,
      ),
      LumiereTagColorName.youthPurple: LumiereTagColor(
        subtle: ArcoPaletteDark.pinkPurplePinkPurple1,
        strong: ArcoPaletteDark.pinkPurplePinkPurple2,
        ink: ArcoPaletteDark.pinkPurplePinkPurple6,
      ),
      LumiereTagColorName.magenta: LumiereTagColor(
        subtle: ArcoPaletteDark.magenta1,
        strong: ArcoPaletteDark.magenta2,
        ink: ArcoPaletteDark.magenta6,
      ),
      LumiereTagColorName.ultimateBlue: LumiereTagColor(
        subtle: ArcoPaletteDark.primary1,
        strong: ArcoPaletteDark.primary2,
        ink: ArcoPaletteDark.primary6,
      ),
      LumiereTagColorName.seaBlue: LumiereTagColor(
        subtle: ArcoPaletteDark.blue1,
        strong: ArcoPaletteDark.blue2,
        ink: ArcoPaletteDark.blue6,
      ),
    },
  );

  /// Roles for the light theme.
  ///
  /// Note: the design file keeps Arco's original brand blue (`#165DFF`) in the
  /// light mode while the dark mode uses a customised `#3C7EFF`. That
  /// difference comes straight from the variables export.
  static const LumiereColors light = LumiereColors(
    surfaceBase: ArcoSemanticLight.bg1,
    surfaceContainer: ArcoSemanticLight.bg2,
    surfaceRaised: ArcoSemanticLight.bg3,
    surfaceOverlay: ArcoSemanticLight.bg5,
    textPrimary: ArcoSemanticLight.text1,
    textSecondary: ArcoSemanticLight.text2,
    textTertiary: ArcoSemanticLight.text3,
    textDisabled: ArcoSemanticLight.text4,
    textOnAccent: ArcoSemanticLight.bgWhite,
    accent: LumiereStatusColors(
      subtle: ArcoSemanticLight.primary1,
      textDisabled: ArcoSemanticLight.primary2,
      disabled: ArcoSemanticLight.primary3,
      normal: ArcoSemanticLight.primary6,
      hover: ArcoSemanticLight.primary5,
      active: ArcoSemanticLight.primary7,
    ),
    success: LumiereStatusColors(
      subtle: ArcoSemanticLight.success1,
      textDisabled: ArcoSemanticLight.success2,
      disabled: ArcoSemanticLight.success3,
      normal: ArcoSemanticLight.success6,
      hover: ArcoSemanticLight.success5,
      active: ArcoSemanticLight.success7,
    ),
    warning: LumiereStatusColors(
      subtle: ArcoSemanticLight.warning1,
      textDisabled: ArcoSemanticLight.warning2,
      disabled: ArcoSemanticLight.warning3,
      normal: ArcoSemanticLight.warning6,
      hover: ArcoSemanticLight.warning5,
      active: ArcoSemanticLight.warning7,
    ),
    danger: LumiereStatusColors(
      subtle: ArcoSemanticLight.danger1,
      textDisabled: ArcoSemanticLight.danger2,
      disabled: ArcoSemanticLight.danger3,
      normal: ArcoSemanticLight.danger6,
      hover: ArcoSemanticLight.danger5,
      active: ArcoSemanticLight.danger7,
    ),
    borderSubtle: ArcoSemanticLight.border1,
    borderDefault: ArcoSemanticLight.border2,
    borderStrong: ArcoSemanticLight.border3,
    borderHeavy: ArcoSemanticLight.border4,
    fillSubtle: ArcoSemanticLight.fill1,
    fillDefault: ArcoSemanticLight.fill2,
    fillStrong: ArcoSemanticLight.fill3,
    fillHeavy: ArcoSemanticLight.fill4,
    tagColors: <LumiereTagColorName, LumiereTagColor>{
      LumiereTagColorName.neutral: LumiereTagColor(
        subtle: ArcoSemanticLight.fill2,
        strong: ArcoSemanticLight.fill3,
        ink: ArcoSemanticLight.text1,
      ),
      LumiereTagColorName.romanticRed: LumiereTagColor(
        subtle: ArcoPaletteLight.red1,
        strong: ArcoPaletteLight.red2,
        ink: ArcoPaletteLight.red6,
      ),
      LumiereTagColorName.wildGreen: LumiereTagColor(
        subtle: ArcoPaletteLight.green1,
        strong: ArcoPaletteLight.green2,
        ink: ArcoPaletteLight.green6,
      ),
      LumiereTagColorName.blueTide: LumiereTagColor(
        subtle: ArcoPaletteLight.cyan1,
        strong: ArcoPaletteLight.cyan2,
        ink: ArcoPaletteLight.cyan6,
      ),
      LumiereTagColorName.vitalityOrange: LumiereTagColor(
        subtle: ArcoPaletteLight.orange1,
        strong: ArcoPaletteLight.orange2,
        ink: ArcoPaletteLight.orange6,
      ),
      LumiereTagColorName.lateAutumnRed: LumiereTagColor(
        subtle: ArcoPaletteLight.orangeRedOrangeRed1,
        strong: ArcoPaletteLight.orangeRedOrangeRed2,
        ink: ArcoPaletteLight.orangeRedOrangeRed6,
      ),
      LumiereTagColorName.dusk: LumiereTagColor(
        subtle: ArcoPaletteLight.gold1,
        strong: ArcoPaletteLight.gold2,
        ink: ArcoPaletteLight.gold6,
      ),
      LumiereTagColorName.youthPurple: LumiereTagColor(
        subtle: ArcoPaletteLight.pinkPurplePinkPurple1,
        strong: ArcoPaletteLight.pinkPurplePinkPurple2,
        ink: ArcoPaletteLight.pinkPurplePinkPurple6,
      ),
      LumiereTagColorName.magenta: LumiereTagColor(
        subtle: ArcoPaletteLight.magenta1,
        strong: ArcoPaletteLight.magenta2,
        ink: ArcoPaletteLight.magenta6,
      ),
      LumiereTagColorName.ultimateBlue: LumiereTagColor(
        subtle: ArcoPaletteLight.primary1,
        strong: ArcoPaletteLight.primary2,
        ink: ArcoPaletteLight.primary6,
      ),
      LumiereTagColorName.seaBlue: LumiereTagColor(
        subtle: ArcoPaletteLight.blue1,
        strong: ArcoPaletteLight.blue2,
        ink: ArcoPaletteLight.blue6,
      ),
    },
  );

  /// The status ramp that backs a given kind.
  LumiereStatusColors rampFor(LumiereRamp ramp) => switch (ramp) {
        LumiereRamp.accent => accent,
        LumiereRamp.success => success,
        LumiereRamp.warning => warning,
        LumiereRamp.danger => danger,
      };

  static LumiereColors _lerp(LumiereColors a, LumiereColors b, double t) =>
      LumiereColors(
        surfaceBase: Color.lerp(a.surfaceBase, b.surfaceBase, t)!,
        surfaceContainer:
            Color.lerp(a.surfaceContainer, b.surfaceContainer, t)!,
        surfaceRaised: Color.lerp(a.surfaceRaised, b.surfaceRaised, t)!,
        surfaceOverlay: Color.lerp(a.surfaceOverlay, b.surfaceOverlay, t)!,
        textPrimary: Color.lerp(a.textPrimary, b.textPrimary, t)!,
        textSecondary: Color.lerp(a.textSecondary, b.textSecondary, t)!,
        textTertiary: Color.lerp(a.textTertiary, b.textTertiary, t)!,
        textDisabled: Color.lerp(a.textDisabled, b.textDisabled, t)!,
        textOnAccent: Color.lerp(a.textOnAccent, b.textOnAccent, t)!,
        accent: LumiereStatusColors._lerp(a.accent, b.accent, t),
        success: LumiereStatusColors._lerp(a.success, b.success, t),
        warning: LumiereStatusColors._lerp(a.warning, b.warning, t),
        danger: LumiereStatusColors._lerp(a.danger, b.danger, t),
        borderSubtle: Color.lerp(a.borderSubtle, b.borderSubtle, t)!,
        borderDefault: Color.lerp(a.borderDefault, b.borderDefault, t)!,
        borderStrong: Color.lerp(a.borderStrong, b.borderStrong, t)!,
        borderHeavy: Color.lerp(a.borderHeavy, b.borderHeavy, t)!,
        fillSubtle: Color.lerp(a.fillSubtle, b.fillSubtle, t)!,
        fillDefault: Color.lerp(a.fillDefault, b.fillDefault, t)!,
        fillStrong: Color.lerp(a.fillStrong, b.fillStrong, t)!,
        fillHeavy: Color.lerp(a.fillHeavy, b.fillHeavy, t)!,
        tagColors: <LumiereTagColorName, LumiereTagColor>{
          for (final LumiereTagColorName name in LumiereTagColorName.values)
            name: LumiereTagColor._lerp(a.tag(name), b.tag(name), t),
        },
      );
}

/// Which status ramp a component should use.
///
/// Mirrors the design's `kind` axis: standard uses the brand ramp, the rest use
/// their own.
enum LumiereRamp { accent, success, warning, danger }

/// Design tokens published through the theme.
///
/// Colours are mode dependent, so they travel as a [ThemeExtension]. Scales that
/// do not change with the mode (type, spacing, radius, control heights) are
/// exposed as plain constants by [ArcoType], [ArcoSpace], [ArcoRadius] and
/// [ArcoControl].
@immutable
class LumiereTokens extends ThemeExtension<LumiereTokens> {
  const LumiereTokens({required this.colors, required this.brightness});

  final LumiereColors colors;
  final Brightness brightness;

  /// Tokens of the current theme.
  ///
  /// Fails loudly in debug builds when the theme was not built with
  /// [LumiereThemeData], which is a wiring mistake rather than a state to
  /// tolerate.
  static LumiereTokens of(BuildContext context) {
    final LumiereTokens? tokens =
        Theme.of(context).extension<LumiereTokens>();
    assert(
      tokens != null,
      'LumiereTokens is missing from the theme. Build it with '
      'LumiereThemeData.dark() or LumiereThemeData.light().',
    );
    return tokens ??
        const LumiereTokens(colors: LumiereColors.dark, brightness: Brightness.dark);
  }

  /// Builds a text style from the design type scale.
  ///
  /// The line height is the one the design file pairs with [size]; when the size
  /// is not in the scale the style inherits Flutter's default.
  TextStyle text({required double size, FontWeight weight = FontWeight.w400}) {
    final double? lineHeight = ArcoType.lineHeightFor(size);
    return TextStyle(
      fontFamily: ArcoType.fontFamily,
      fontSize: size,
      height: lineHeight == null ? null : lineHeight / size,
      fontWeight: weight,
      color: colors.textPrimary,
    );
  }

  @override
  LumiereTokens copyWith({LumiereColors? colors, Brightness? brightness}) =>
      LumiereTokens(
        colors: colors ?? this.colors,
        brightness: brightness ?? this.brightness,
      );

  @override
  LumiereTokens lerp(ThemeExtension<LumiereTokens>? other, double t) {
    if (other is! LumiereTokens) {
      return this;
    }
    return LumiereTokens(
      colors: LumiereColors._lerp(colors, other.colors, t),
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LumiereTokens &&
      other.colors == colors &&
      other.brightness == brightness;

  @override
  int get hashCode => Object.hash(colors, brightness);
}
