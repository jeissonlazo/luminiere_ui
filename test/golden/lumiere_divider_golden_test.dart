// Golden tests depend on the operating system's rasterisation, so CI excludes
// them with `--exclude-tags=golden`; the baseline is produced locally.
@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

const Key kGoldenKey = Key('lumiere_divider_golden');

Widget _panel(bool light) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      for (final LumiereDividerAlign align in LumiereDividerAlign.values) ...<Widget>[
        SizedBox(
          width: 260,
          child: LumiereDivider(label: align.name, align: align),
        ),
        const SizedBox(height: ArcoSpace.spaceMd),
      ],
      const SizedBox(
        width: 260,
        child: LumiereDivider(dashed: true),
      ),
      const SizedBox(height: ArcoSpace.spaceMd),
      SizedBox(
        height: 40,
        child: Row(
          children: <Widget>[
            const Expanded(child: SizedBox()),
            const LumiereDivider(
              orientation: LumiereDividerOrientation.vertical,
            ),
            const Expanded(child: SizedBox()),
            LumiereDivider(
              orientation: LumiereDividerOrientation.vertical,
              dashed: true,
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
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
  testWidgets('golden: orientations, dashed, labels and alignments', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_matrix());

    await expectLater(
      find.byKey(kGoldenKey),
      matchesGoldenFile('goldens/lumiere_divider.png'),
    );
  });
}
