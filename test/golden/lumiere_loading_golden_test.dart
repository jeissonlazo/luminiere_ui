// Golden tests depend on the operating system's rasterisation, so CI excludes
// them with `--exclude-tags=golden`; the baseline is produced locally.
@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

const Key kGoldenKey = Key('lumiere_loading_golden');

/// The sizes the design's icon set uses for the same glyph.
const List<double> kSizes = <double>[12, 16, 20, 24, 28, 32];

Widget _panel(bool light) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      for (final double size in kSizes) ...<Widget>[
        LumiereLoading(
          size: size,
          color: light
              ? LumiereColors.light.accent.normal
              : LumiereColors.dark.accent.normal,
        ),
        const SizedBox(width: ArcoSpace.spaceMd),
      ],
    ],
  );
}

Widget _matrix() {
  return MaterialApp(
    theme: LumiereThemeData.dark(),
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: kGoldenKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ColoredBox(
                color: LumiereColors.dark.surfaceBase,
                child: Padding(
                  padding: const EdgeInsets.all(ArcoSpace.spaceLg),
                  child: _panel(false),
                ),
              ),
              ColoredBox(
                color: LumiereColors.light.surfaceBase,
                child: Padding(
                  padding: const EdgeInsets.all(ArcoSpace.spaceLg),
                  child: _panel(true),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('golden: every size of the indicator, in both themes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_matrix());
    // The indicator turns, so the frame has to be pinned to be deterministic.
    await tester.pump(const Duration(milliseconds: 150));

    await expectLater(
      find.byKey(kGoldenKey),
      matchesGoldenFile('goldens/lumiere_loading.png'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
