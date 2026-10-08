import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

Widget _host(Widget child) => MaterialApp(
      theme: LumiereThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LumiereButton', () {
    testWidgets('invoca onPressed al pulsar', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(LumiereButton(label: 'Guardar', onPressed: () => taps++)),
      );

      await tester.tap(find.byType(LumiereButton));

      expect(taps, 1);
    });

    testWidgets('queda deshabilitado cuando onPressed es null',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const LumiereButton(label: 'Guardar')));

      final TextButton button = tester.widget<TextButton>(find.byType(TextButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('isLoading bloquea la interaccion y muestra progreso',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(LumiereButton(
          label: 'Guardar',
          isLoading: true,
          onPressed: () => taps++,
        )),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(LumiereButton), warnIfMissed: false);

      expect(taps, 0);
    });

    testWidgets('expone su etiqueta como nombre accesible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(LumiereButton(label: 'Guardar', onPressed: () {})),
      );

      expect(find.bySemanticsLabel('Guardar'), findsOneWidget);
    });

    testWidgets('el icono previo es decorativo y no ensucia el nombre accesible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(LumiereButton(
          label: 'Guardar',
          leadingIcon: const Icon(Icons.save),
          onPressed: () {},
        )),
      );

      expect(find.bySemanticsLabel('Guardar'), findsOneWidget);
    });

    testWidgets('los tamanos respetan las alturas de los tokens',
        (WidgetTester tester) async {
      final LumiereTokens tokens = LumiereTokens.provisional();
      await tester.pumpWidget(_host(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumiereButton(
              label: 'S',
              size: LumiereButtonSize.small,
              onPressed: () {},
            ),
            LumiereButton(
              label: 'M',
              size: LumiereButtonSize.medium,
              onPressed: () {},
            ),
            LumiereButton(
              label: 'L',
              size: LumiereButtonSize.large,
              onPressed: () {},
            ),
          ],
        ),
      ));

      expect(
        tester.getSize(find.widgetWithText(LumiereButton, 'S')).height,
        tokens.controlHeightSmall,
      );
      expect(
        tester.getSize(find.widgetWithText(LumiereButton, 'M')).height,
        tokens.controlHeightMedium,
      );
      expect(
        tester.getSize(find.widgetWithText(LumiereButton, 'L')).height,
        tokens.controlHeightLarge,
      );
    });
  });

  group('LumiereTokens', () {
    test('la escala de espaciado es cerrada', () {
      final LumiereTokens tokens = LumiereTokens.provisional();

      expect(tokens.spacing.isOnScale(16), isTrue);
      expect(tokens.spacing.isOnScale(7), isFalse);
    });

    test('la escala de radios es cerrada', () {
      final LumiereTokens tokens = LumiereTokens.provisional();

      expect(tokens.radii.isOnScale(8), isTrue);
      expect(tokens.radii.isOnScale(10), isFalse);
    });

    test('el tema publica la extension con los mismos tokens', () {
      final LumiereTokens tokens = LumiereTokens.provisional();
      final ThemeData theme = LumiereThemeData.dark(tokens: tokens);

      expect(theme.extension<LumiereTheme>()!.tokens, tokens);
    });
  });
}
