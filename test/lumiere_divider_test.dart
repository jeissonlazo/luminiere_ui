import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

Widget _host(Widget child, {bool light = false}) => MaterialApp(
      theme: light ? LumiereThemeData.light() : LumiereThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LumiereDivider', () {
    testWidgets('a plain horizontal divider is one hairline high', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 200, child: LumiereDivider())),
      );

      final Size size = tester.getSize(find.byType(LumiereDivider));
      expect(size.height, LumiereStrokes.hairline);
      expect(size.width, 200);
    });

    testWidgets('it takes its colour from the theme', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const SizedBox(width: 200, child: LumiereDivider())));
      final LumiereTokens tokens =
          LumiereTokens.of(tester.element(find.byType(LumiereDivider)));
      final ColoredBox box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(LumiereDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(box.color, tokens.colors.borderDefault);

      await tester.pumpWidget(
        _host(const SizedBox(width: 200, child: LumiereDivider()), light: true),
      );
      final LumiereTokens lightTokens =
          LumiereTokens.of(tester.element(find.byType(LumiereDivider)));
      final ColoredBox lightBox = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(LumiereDivider),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(lightBox.color, lightTokens.colors.borderDefault);
    });

    testWidgets('a vertical divider is one hairline wide and stretches', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            height: 120,
            child: Row(
              children: <Widget>[
                Expanded(child: SizedBox()),
                LumiereDivider(orientation: LumiereDividerOrientation.vertical),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );

      final Size size = tester.getSize(find.byType(LumiereDivider));
      expect(size.width, LumiereStrokes.hairline);
      expect(size.height, 120);
    });

    testWidgets('a dashed divider draws darts instead of a solid box', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const LumiereDivider(dashed: true)));

      expect(find.byType(CustomPaint), findsWidgets);
      // A dashed line is painted, so there is no solid colour box for it.
      expect(
        find.descendant(
          of: find.byType(LumiereDivider),
          matching: find.byType(ColoredBox),
        ),
        findsNothing,
      );
    });

    testWidgets('a label is read, and the line beside it is not', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const LumiereDivider(label: 'Section')));

      expect(find.text('Section'), findsOneWidget);
      expect(find.bySemanticsLabel('Section'), findsOneWidget);
      handle.dispose();
    });

    for (final LumiereDividerAlign align in LumiereDividerAlign.values) {
      testWidgets('every alignment the design declares renders: ${align.name}', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          _host(LumiereDivider(label: 'Label', align: align)),
        );

        expect(find.text('Label'), findsOneWidget);
        final Finder lines = find.descendant(
          of: find.byType(LumiereDivider),
          matching: find.byType(ColoredBox),
        );
        // Measured in the file: only the design's none carries no lines. The other
        // three carry two, and in start and end one of them is the short 20 px line
        // on the side the label sits.
        expect(
          lines,
          findsNWidgets(align == LumiereDividerAlign.none ? 0 : 2),
        );
        if (align == LumiereDividerAlign.start ||
            align == LumiereDividerAlign.end) {
          final Iterable<double> widths = tester
              .widgetList<ColoredBox>(lines)
              .map((ColoredBox _) => 0)
              .isEmpty
              ? <double>[]
              : tester
                  .widgetList<SizedBox>(find.descendant(
                    of: find.byType(LumiereDivider),
                    matching: find.byType(SizedBox),
                  ))
                  .map((SizedBox box) => box.width ?? 0)
                  .where((double w) => w == ArcoSpace.spaceXl);
          expect(widths, isNotEmpty, reason: 'the short line is on the label side');
        }
      });
    }

    testWidgets('a divider with no label has no text at all', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const LumiereDivider(label: '')));
      expect(find.byType(Text), findsNothing);
    });
  });
}
