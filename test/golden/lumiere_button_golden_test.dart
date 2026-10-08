// Los goldens dependen de la rasterización del sistema operativo: la CI los
// excluye con `--exclude-tags=golden` y la línea base se genera en local.
@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

const Key kGoldenKey = Key('lumiere_button_golden');

Widget _matrix() {
  final Color surface = LumiereTokens.provisional().colors.surfaceBase;
  return MaterialApp(
    theme: LumiereThemeData.dark(),
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: kGoldenKey,
          child: ColoredBox(
            color: surface,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (final LumiereButtonVariant variant
                      in LumiereButtonVariant.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          LumiereButton(
                            label: 'Enabled',
                            variant: variant,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          LumiereButton(label: 'Disabled', variant: variant),
                          const SizedBox(width: 8),
                          LumiereButton(
                            label: 'Loading',
                            variant: variant,
                            isLoading: true,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          LumiereButton(
                            label: 'Icon',
                            variant: variant,
                            leadingIcon: const Icon(Icons.save),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      LumiereButton(
                        label: 'Small',
                        size: LumiereButtonSize.small,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      LumiereButton(
                        label: 'Medium',
                        size: LumiereButtonSize.medium,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                      LumiereButton(
                        label: 'Large',
                        size: LumiereButtonSize.large,
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
  testWidgets('golden: variantes, estados y tamanos', (WidgetTester tester) async {
    await tester.pumpWidget(_matrix());

    await expectLater(
      find.byKey(kGoldenKey),
      matchesGoldenFile('goldens/lumiere_button.png'),
    );

    // Desmonta el arbol para liberar el ticker del indicador de carga y no
    // dejar animaciones pendientes al terminar la prueba.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
