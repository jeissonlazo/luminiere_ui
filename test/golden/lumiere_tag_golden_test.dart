// Golden tests depend on the operating system's rasterisation, so CI excludes
// them with `--exclude-tags=golden`; the baseline is produced locally.
@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

const Key kGoldenKey = Key('lumiere_tag_golden');

Widget _matrix() {
  return MaterialApp(
    theme: LumiereThemeData.dark(),
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: kGoldenKey,
          child: ColoredBox(
            color: LumiereColors.dark.surfaceBase,
            child: Padding(
              padding: const EdgeInsets.all(ArcoSpace.spaceLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Every colour of the design, in its filled form.
                  Wrap(
                    spacing: ArcoSpace.spaceSm,
                    runSpacing: ArcoSpace.spaceSm,
                    children: <Widget>[
                      for (final LumiereTagColorName name
                          in LumiereTagColorName.values)
                        LumiereTag(label: name.name, color: name),
                    ],
                  ),
                  const SizedBox(height: ArcoSpace.spaceLg),
                  // The four sizes, filled and bordered.
                  Wrap(
                    spacing: ArcoSpace.spaceSm,
                    runSpacing: ArcoSpace.spaceSm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      for (final LumiereTagSize size in LumiereTagSize.values)
                        LumiereTag(
                          label: size.name,
                          size: size,
                          color: LumiereTagColorName.ultimateBlue,
                        ),
                      for (final LumiereTagSize size in LumiereTagSize.values)
                        LumiereTag(
                          label: size.name,
                          size: size,
                          color: LumiereTagColorName.ultimateBlue,
                          filled: false,
                          bordered: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: ArcoSpace.spaceLg),
                  // The remaining axes.
                  Wrap(
                    spacing: ArcoSpace.spaceSm,
                    runSpacing: ArcoSpace.spaceSm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      const LumiereTag(
                        label: 'with icon',
                        icon: Icon(Icons.local_offer),
                      ),
                      const LumiereTag(label: 'no background', filled: false),
                      LumiereTag(
                        label: 'closable',
                        onClose: () {},
                        closeSemanticLabel: 'Remove closable',
                      ),
                      LumiereTag(
                        label: 'both',
                        color: LumiereTagColorName.wildGreen,
                        icon: const Icon(Icons.check),
                        onClose: () {},
                        closeSemanticLabel: 'Remove both',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('golden: colours, sizes, forms and axes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_matrix());

    await expectLater(
      find.byKey(kGoldenKey),
      matchesGoldenFile('goldens/lumiere_tag.png'),
    );
  });
}
