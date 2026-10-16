import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../catalog.dart';
import '../theme/theme_controller.dart';
import 'sidebar.dart';
import 'top_bar.dart';

/// Layout of the gallery: a header, a docked navigation column and the page.
///
/// The sidebar is docked while there is room for it and becomes a drawer
/// underneath, so the same content is readable in a narrow browser window.
class DocsShell extends StatefulWidget {
  const DocsShell({super.key, required this.theme, this.initialPageId});

  final ThemeController theme;

  /// Opens the gallery on a known page. Used by tests; the gallery itself
  /// always starts on the first entry.
  final String? initialPageId;

  @override
  State<DocsShell> createState() => _DocsShellState();
}

class _DocsShellState extends State<DocsShell> {
  /// Below this width the sidebar stops being docked.
  static const double _wideBreakpoint = 920;

  static const double _sidebarWidth = 268;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late String _selectedId =
      widget.initialPageId ?? Catalog.entries.first.id;

  void _select(String id) {
    if (id != _selectedId) {
      setState(() => _selectedId = id);
    }
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool wide = constraints.maxWidth >= _wideBreakpoint;
        final DocEntry entry = Catalog.byId(_selectedId);

        final Widget sidebar = Sidebar(
          selectedId: _selectedId,
          onSelect: _select,
          onClose: wide ? null : () => _scaffoldKey.currentState?.closeDrawer(),
          showFooter: wide,
        );

        return Scaffold(
          key: _scaffoldKey,
          drawer: wide
              ? null
              : Drawer(
                  width: _sidebarWidth,
                  backgroundColor: tokens.colors.surfaceContainer,
                  child: sidebar,
                ),
          body: Column(
            children: <Widget>[
              TopBar(
                theme: widget.theme,
                onMenu: wide
                    ? null
                    : () => _scaffoldKey.currentState?.openDrawer(),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (wide) ...<Widget>[
                      SizedBox(width: _sidebarWidth, child: sidebar),
                      Container(width: 1, color: tokens.colors.borderSubtle),
                    ],
                    Expanded(
                      // A distinct key per page, so the scroll position of the
                      // previous page is not reused by the next one.
                      child: KeyedSubtree(
                        key: ValueKey<String>(entry.id),
                        child: entry.builder(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
