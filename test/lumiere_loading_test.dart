import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

/// The indicator never settles: it rotates for as long as it is mounted. Every
/// test here pumps frames, and none of them waits for the tree to settle.
Widget _host(Widget child, {bool light = false}) => MaterialApp(
      theme: light ? LumiereThemeData.light() : LumiereThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LumiereLoading', () {
    testWidgets('the default size is the one the design declares', (
      WidgetTester tester,
    ) async {
      // The component is a single 40 by 40 vector: it has no size axis.
      await tester.pumpWidget(_host(const LumiereLoading()));
      expect(tester.getSize(find.byType(LumiereLoading)), const Size(40, 40));
    });

    testWidgets('every size the design set uses is available', (
      WidgetTester tester,
    ) async {
      // The parameter exists because the button draws the indicator at its own
      // icon size, not because the design offers a family.
      for (final double size in <double>[16, 20, 32, 40]) {
        await tester.pumpWidget(_host(LumiereLoading(size: size)));
        expect(
          tester.getSize(find.byType(LumiereLoading)),
          Size(size, size),
          reason: 'size $size',
        );
      }
    });

    testWidgets('it takes the accent colour by default and accepts another', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const LumiereLoading()));
      final LumiereTokens tokens =
          LumiereTokens.of(tester.element(find.byType(LumiereLoading)));
      final CustomPaint paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(LumiereLoading),
          matching: find.byType(CustomPaint),
        ),
      );
      expect((paint.painter! as dynamic).color, tokens.colors.accent.normal);

      await tester.pumpWidget(
        _host(const LumiereLoading(color: Color(0xFF123456))),
      );
      final CustomPaint custom = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(LumiereLoading),
          matching: find.byType(CustomPaint),
        ),
      );
      expect((custom.painter! as dynamic).color, const Color(0xFF123456));
    });

    testWidgets('it turns: the frame changes without any input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const LumiereLoading()));

      final Animation<double> turns = tester
          .widgetList<RotationTransition>(find.byType(RotationTransition))
          .first
          .turns;
      final double firstValue = turns.value;

      await tester.pump(const Duration(milliseconds: 300));
      expect(turns.value, isNot(firstValue));

      // Unmount so the ticker does not outlive the test.
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('without a label it is decorative and hidden from readers', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const LumiereLoading()));

      expect(find.bySemanticsLabel('Loading'), findsNothing);
      handle.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('with a label the reader announces it', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const LumiereLoading(semanticLabel: 'Loading the document')),
      );

      expect(find.bySemanticsLabel('Loading the document'), findsOneWidget);
      handle.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('the button uses it for its loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(LumiereButton(label: 'Save', isLoading: true, onPressed: () {})),
      );

      expect(find.byType(LumiereLoading), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
