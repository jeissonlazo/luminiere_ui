import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import 'shell/docs_shell.dart';
import 'theme/theme_controller.dart';

/// The component gallery.
///
/// It wires the design system exactly as an application does: the two themes
/// from `LumiereThemeData`, selected by [ThemeMode]. Every page below the shell
/// therefore reads its colours from the same token API a product surface does.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key, this.initialTheme, this.initialPageId});

  /// Lets a test open the gallery in a known mode.
  final ThemeMode? initialTheme;

  /// Lets a test open the gallery on a known page.
  final String? initialPageId;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late final ThemeController _theme =
      ThemeController(widget.initialTheme ?? ThemeMode.dark);

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _theme,
      builder: (BuildContext context, ThemeMode mode, Widget? _) {
        return MaterialApp(
          title: 'lumiere_ui - component gallery',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: LumiereThemeData.light(),
          darkTheme: LumiereThemeData.dark(),
          scrollBehavior: const _GalleryScrollBehavior(),
          home: DocsShell(theme: _theme, initialPageId: widget.initialPageId),
        );
      },
    );
  }
}

/// Lets the documentation scroll with a mouse drag and a trackpad.
///
/// The gallery is read on a desktop browser, where the default behaviour only
/// scrolls with the wheel and leaves scrollbars as the sole drag target.
class _GalleryScrollBehavior extends MaterialScrollBehavior {
  const _GalleryScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.mouse,
        PointerDeviceKind.touch,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
