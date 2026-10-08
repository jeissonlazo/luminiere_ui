import 'package:flutter/material.dart';

import '../../theme/lumiere_theme.dart';
import '../../tokens/lumiere_tokens.dart';

/// Tamano del boton.
enum LumiereButtonSize { small, medium, large }

/// Variante visual del boton.
///
/// PROVISIONAL: los nombres y el numero de variantes deben confirmarse contra el
/// contrato real del componente `Button` en Figma antes de congelar la API.
/// Cambiarlos despues es un cambio de datos en este enum, no una reescritura.
enum LumiereButtonVariant { primary, secondary, ghost, danger }

/// Boton del sistema de diseno.
///
/// Nota de arquitectura: el contrato de Figma declara un estado `State` como
/// variante, pero en Flutter hover, foco, pulsado y deshabilitado **no son
/// props**: son estados reales del widget. Solo `Loading` se modela como prop
/// ([isLoading]). Mapear la variante de diseno a estados reales evita una API
/// que se pueda contradecir a si misma.
class LumiereButton extends StatelessWidget {
  const LumiereButton({
    super.key,
    required this.label,
    this.onPressed,
    this.size = LumiereButtonSize.medium,
    this.variant = LumiereButtonVariant.primary,
    this.leadingIcon,
    this.isLoading = false,
  });

  /// Texto visible y, por tanto, etiqueta accesible del boton.
  final String label;

  /// `null` deja el boton deshabilitado.
  final VoidCallback? onPressed;

  final LumiereButtonSize size;
  final LumiereButtonVariant variant;

  /// Icono decorativo previo a la etiqueta. Se oculta a lectores de pantalla.
  final Widget? leadingIcon;

  /// Estado de carga: muestra progreso y bloquea la interaccion.
  final bool isLoading;

  bool get _isEnabled => onPressed != null && !isLoading;

  double _height(LumiereTokens tokens) => switch (size) {
        LumiereButtonSize.small => tokens.controlHeightSmall,
        LumiereButtonSize.medium => tokens.controlHeightMedium,
        LumiereButtonSize.large => tokens.controlHeightLarge,
      };

  Color _background(Set<WidgetState> states, LumiereColors colors) {
    if (states.contains(WidgetState.disabled)) {
      return variant == LumiereButtonVariant.ghost
          ? const Color(0x00000000)
          : colors.surfaceRaised;
    }
    return switch (variant) {
      LumiereButtonVariant.primary => colors.accent,
      LumiereButtonVariant.secondary => colors.surfaceRaised,
      LumiereButtonVariant.ghost => const Color(0x00000000),
      LumiereButtonVariant.danger => colors.textPrimary,
    };
  }

  Color _foreground(Set<WidgetState> states, LumiereColors colors) {
    if (states.contains(WidgetState.disabled)) {
      return colors.textSecondary;
    }
    return switch (variant) {
      LumiereButtonVariant.primary => colors.surfaceBase,
      LumiereButtonVariant.secondary => colors.textPrimary,
      LumiereButtonVariant.ghost => colors.textPrimary,
      LumiereButtonVariant.danger => colors.surfaceBase,
    };
  }

  BorderSide? _side(Set<WidgetState> states, LumiereColors colors, LumiereTokens tokens) {
    if (variant == LumiereButtonVariant.ghost) {
      return BorderSide.none;
    }
    if (states.contains(WidgetState.focused)) {
      return BorderSide(color: colors.accent, width: tokens.focusRingWidth);
    }
    return BorderSide(color: colors.borderSubtle);
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTheme.of(context).tokens;
    final LumiereColors colors = tokens.colors;
    final double height = _height(tokens);

    return TextButton(
      onPressed: _isEnabled ? onPressed : null,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll<Size>(Size(0, height)),
        // La densidad la deciden los tokens, no Material: si el tema de la
        // aplicacion trae otra `visualDensity`, el control no debe encogerse ni
        // crecer por debajo de la altura del token.
        visualDensity: VisualDensity.standard,
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(horizontal: tokens.spacing.sm),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: const WidgetStatePropertyAll<double>(0),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radii.sm),
          ),
        ),
        textStyle: WidgetStatePropertyAll<TextStyle>(tokens.typography.label),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => _background(states, colors),
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) => _foreground(states, colors),
        ),
        side: WidgetStateProperty.resolveWith<BorderSide?>(
          (Set<WidgetState> states) => _side(states, colors, tokens),
        ),
        overlayColor: WidgetStatePropertyAll<Color>(
          colors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: _buildContent(colors, height),
    );
  }

  Widget _buildContent(LumiereColors colors, double height) {
    final double iconSize = height * 0.5;
    if (isLoading) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(colors.textSecondary),
        ),
      );
    }
    if (leadingIcon == null) {
      return Text(label);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Decorativo: el nombre accesible lo aporta la etiqueta.
        ExcludeSemantics(
          child: IconTheme.merge(
            data: IconThemeData(size: iconSize, color: colors.textSecondary),
            child: leadingIcon!,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
