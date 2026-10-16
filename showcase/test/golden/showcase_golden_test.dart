// Golden tests depend on the operating system's rasterisation, so CI excludes
// them with `--exclude-tags=golden`; the baseline is produced locally.
//
// They are the visual half of the gallery's verification: the widget tests
// prove that every page builds, and these prove what the pages look like. The
// baseline is one image per page, taken at a desktop width with the sidebar
// docked.
@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui_showcase/src/app.dart';
import 'package:lumiere_ui_showcase/src/catalog.dart';

import '../support/gallery_fonts.dart';

const Key kGoldenKey = Key('showcase_page_golden');

/// The size the baseline is captured at: a desktop window with the sidebar
/// docked, tall enough to show the header and the first sections of a page.
const Size kGoldenSize = Size(1440, 2000);

void main() {
  setUpAll(loadGalleryFonts);

  // Both modes: the design system ships two themes, and several pages make a
  // statement about one of them - the Tag page points at a light-theme contrast
  // exception, the Colour page at the brand blue differing between the two.
  // A baseline in a single mode could not back either claim.
  for (final ThemeMode mode in <ThemeMode>[ThemeMode.dark, ThemeMode.light]) {
    final String suffix = mode == ThemeMode.dark ? '' : '-light';

    for (final DocEntry entry in Catalog.entries) {
      testWidgets('golden: ${entry.id}$suffix', (WidgetTester tester) async {
        tester.view.physicalSize = kGoldenSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          RepaintBoundary(
            key: kGoldenKey,
            child: ShowcaseApp(initialTheme: mode, initialPageId: entry.id),
          ),
        );

        // The loading indicator never settles, so the animation is advanced by
        // a fixed step: enough for the first frame of every page, and
        // deterministic from run to run.
        await tester.pump(const Duration(milliseconds: 250));

        await expectLater(
          find.byKey(kGoldenKey),
          matchesGoldenFile('goldens/${entry.id}$suffix.png'),
        );

        // Unmount to release the indicator's ticker.
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }
}
