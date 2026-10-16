import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui_showcase/src/app.dart';
import 'package:lumiere_ui_showcase/src/catalog.dart';
import 'package:lumiere_ui_showcase/src/shell/sidebar.dart';

/// A desktop surface, wide enough for the sidebar to be docked.
void _useDesktopSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// The loading indicator rotates for as long as it is mounted, so no test can
/// wait for the tree to be quiet. Time is advanced by a fixed step instead.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  testWidgets('every page renders in both themes without an exception',
      (WidgetTester tester) async {
    _useDesktopSurface(tester);

    for (final DocEntry entry in Catalog.entries) {
      for (final ThemeMode mode in <ThemeMode>[
        ThemeMode.dark,
        ThemeMode.light,
      ]) {
        await tester.pumpWidget(
          ShowcaseApp(initialTheme: mode, initialPageId: entry.id),
        );
        await _settle(tester);

        expect(
          tester.takeException(),
          isNull,
          reason: '${entry.id} in ${mode.name}',
        );

        // Unmount between iterations: the state of the shell is created once,
        // and the indicator holds a ticker.
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets('the header switches the theme in place',
      (WidgetTester tester) async {
    _useDesktopSurface(tester);

    await tester.pumpWidget(const ShowcaseApp());
    await _settle(tester);

    expect(find.text('Light theme'), findsOneWidget);

    await tester.tap(find.text('Light theme'));
    await _settle(tester);

    expect(find.text('Dark theme'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the sidebar opens another page', (WidgetTester tester) async {
    _useDesktopSurface(tester);

    await tester.pumpWidget(const ShowcaseApp());
    await _settle(tester);

    // The page title is only in the page, never in the sidebar, so finding it
    // twice is what proves the page changed from one to the other.
    expect(find.text('Components'), findsWidgets);

    await tester.tap(
      find.descendant(
        of: find.byType(Sidebar),
        matching: find.text('Divider'),
      ),
    );
    await _settle(tester);

    expect(
      find.descendant(
        of: find.byType(Sidebar),
        matching: find.text('DS-COMP-018'),
      ),
      findsOneWidget,
      reason: 'the selected row shows its rule identifier',
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a narrow surface gets a drawer instead of a docked sidebar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(760, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ShowcaseApp());
    await _settle(tester);

    expect(find.byType(Drawer), findsNothing);

    await tester.tap(find.byTooltip('Open navigation'));
    await _settle(tester);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(Drawer), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the overview lists every documented component',
      (WidgetTester tester) async {
    _useDesktopSurface(tester);

    await tester.pumpWidget(const ShowcaseApp());
    await _settle(tester);

    for (final DocEntry entry in Catalog.componentEntries) {
      expect(entry.summary, isNotNull);
      expect(
        find.text(entry.summary!),
        findsOneWidget,
        reason: 'the overview is missing the card for ${entry.id}',
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
