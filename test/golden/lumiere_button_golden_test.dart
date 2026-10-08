// Golden tests depend on the operating system's rasterisation, so CI excludes
// them with `--exclude-tags=golden`; the baseline is produced locally.
@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

const Key kGoldenKey = Key('lumiere_button_golden');

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
              padding: const EdgeInsets.all(ArcoSpace.spaceMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // One row per kind, one button per type.
                  for (final LumiereButtonKind kind in LumiereButtonKind.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: ArcoSpace.spaceXs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final LumiereButtonType type
                              in LumiereButtonType.values) ...<Widget>[
                            LumiereButton(
                              label: type.name,
                              type: type,
                              kind: kind,
                              onPressed: () {},
                            ),
                            const SizedBox(width: ArcoSpace.spaceXs),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: ArcoSpace.spaceSm),
                  // Sizes.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (final LumiereButtonSize size
                          in LumiereButtonSize.values) ...<Widget>[
                        LumiereButton(
                          label: size.name,
                          size: size,
                          onPressed: () {},
                        ),
                        const SizedBox(width: ArcoSpace.spaceXs),
                      ],
                    ],
                  ),
                  const SizedBox(height: ArcoSpace.spaceSm),
                  // Shapes and states.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (final LumiereButtonShape shape
                          in LumiereButtonShape.values) ...<Widget>[
                        LumiereButton(
                          label: shape.name,
                          shape: shape,
                          onPressed: () {},
                        ),
                        const SizedBox(width: ArcoSpace.spaceXs),
                      ],
                      const LumiereButton(label: 'disabled'),
                      const SizedBox(width: ArcoSpace.spaceXs),
                      LumiereButton(
                        label: 'loading',
                        isLoading: true,
                        onPressed: () {},
                      ),
                      const SizedBox(width: ArcoSpace.spaceXs),
                      LumiereButton(
                        label: 'icon',
                        leadingIcon: const Icon(Icons.save),
                        onPressed: () {},
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
  testWidgets('golden: types, kinds, sizes, shapes and states',
      (WidgetTester tester) async {
    await tester.pumpWidget(_matrix());

    await expectLater(
      find.byKey(kGoldenKey),
      matchesGoldenFile('goldens/lumiere_button.png'),
    );

    // Unmount to release the loading indicator's ticker.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
