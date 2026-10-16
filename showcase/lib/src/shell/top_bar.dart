import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../catalog.dart';
import '../theme/text_styles.dart';
import '../theme/theme_controller.dart';

/// Header of the gallery.
///
/// It carries the identity of the package, its version and the one control a
/// design-system gallery cannot do without: the switch between the two themes.
/// The switch is built with the package's own [LumiereButton], so the chrome is
/// also an example of the components it documents.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.theme, this.onMenu});

  /// Which theme the gallery renders.
  final ThemeController theme;

  /// Opens the navigation drawer. Null on a wide viewport, where the sidebar is
  /// always visible and no menu button is needed.
  final VoidCallback? onMenu;

  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: ArcoSpace.spaceMd),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: <Widget>[
          if (onMenu != null) ...<Widget>[
            IconButton(
              onPressed: onMenu,
              icon: const Icon(LucideIcons.menu, size: 18),
              color: colors.textSecondary,
              tooltip: 'Open navigation',
            ),
            const SizedBox(width: ArcoSpace.spaceXs),
          ],

          // Wordmark. The mark is the accent fill, so the header reads as part
          // of the same system as the controls beside it.
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: colors.accent.normal,
              borderRadius: BorderRadius.circular(ArcoRadius.radiusSm),
            ),
          ),
          const SizedBox(width: ArcoSpace.spaceSm),
          Text(
            'lumiere_ui',
            style: tokens.primary(ArcoType.size16, weight: FontWeight.w600),
          ),
          const SizedBox(width: ArcoSpace.spaceSm),
          _Pill(
            text: 'v${Catalog.packageVersion}',
            background: colors.accent.subtle,
            foreground: colors.accent.onSubtle,
          ),
          const SizedBox(width: ArcoSpace.spaceXs),
          _Pill(
            text: '${Catalog.componentEntries.length} components',
            background: colors.fillSubtle,
            foreground: colors.textTertiary,
          ),

          const Spacer(),

          LumiereButton(
            label: isDark ? 'Light theme' : 'Dark theme',
            type: LumiereButtonType.secondary,
            size: LumiereButtonSize.small,
            leadingIcon: Icon(
              isDark ? LucideIcons.sun : LucideIcons.moon,
              size: 14,
            ),
            onPressed: theme.toggle,
          ),
        ],
      ),
    );
  }
}

/// Small rounded label used for the package version and the component count.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ArcoSpace.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(ArcoRadius.radiusSm),
      ),
      child: Text(
        text,
        style: tokens.primary(
          ArcoType.size12,
          weight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
