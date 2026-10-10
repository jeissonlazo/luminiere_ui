import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

Widget _host(Widget child, {bool light = false}) => MaterialApp(
      theme: light ? LumiereThemeData.light() : LumiereThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LumiereTag', () {
    testWidgets('shows its label and takes the measured height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const LumiereTag(label: 'design')));

      expect(find.text('design'), findsOneWidget);
      // small is the design's default size: 24 px, measured.
      expect(tester.getSize(find.byType(LumiereTag)).height, ArcoTag.heightSmall);
    });

    testWidgets('every size uses its measured height', (
      WidgetTester tester,
    ) async {
      const Map<LumiereTagSize, double> expected = <LumiereTagSize, double>{
        LumiereTagSize.large: 32,
        LumiereTagSize.medium: 28,
        LumiereTagSize.small: 24,
        LumiereTagSize.mini: 20,
      };

      for (final MapEntry<LumiereTagSize, double> entry in expected.entries) {
        await tester.pumpWidget(
          _host(LumiereTag(label: 'size', size: entry.key)),
        );
        expect(
          tester.getSize(find.byType(LumiereTag)).height,
          entry.value,
          reason: 'height of ${entry.key.name}',
        );
      }
    });

    testWidgets('the eleven colours of the design are all available', (
      WidgetTester tester,
    ) async {
      // The axis has eleven values in the design file; none may be missing.
      expect(LumiereTagColorName.values.length, 11);

      for (final LumiereTagColorName name in LumiereTagColorName.values) {
        await tester.pumpWidget(_host(LumiereTag(label: name.name, color: name)));
        expect(find.text(name.name), findsOneWidget, reason: name.name);
      }
    });

    testWidgets('filled uses the soft background and bordered the strong one', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const LumiereTag(label: 'filled')));
      final LumiereTokens tokens =
          LumiereTokens.of(tester.element(find.byType(LumiereTag)));

      BoxDecoration decorationOf() {
        final Container box = tester.widget<Container>(
          find.descendant(
            of: find.byType(LumiereTag),
            matching: find.byType(Container),
          ),
        );
        return box.decoration! as BoxDecoration;
      }

      expect(
        decorationOf().color,
        tokens.colors.tag(LumiereTagColorName.neutral).subtle,
      );

      await tester.pumpWidget(
        _host(const LumiereTag(label: 'bordered', filled: false, bordered: true)),
      );
      expect(
        decorationOf().color,
        tokens.colors.tag(LumiereTagColorName.neutral).strong,
      );
      expect(decorationOf().border, isNotNull);
    });

    testWidgets('without fill or border the tag has no background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const LumiereTag(label: 'plain', filled: false)),
      );

      final Container box = tester.widget<Container>(
        find.descendant(
          of: find.byType(LumiereTag),
          matching: find.byType(Container),
        ),
      );
      expect((box.decoration! as BoxDecoration).color, isNull);
    });

    testWidgets('a closable tag exposes a named close action', (
      WidgetTester tester,
    ) async {
      int closed = 0;
      await tester.pumpWidget(
        _host(
          LumiereTag(
            label: 'closable',
            onClose: () => closed++,
            closeSemanticLabel: 'Remove closable',
          ),
        ),
      );

      final SemanticsHandle handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Remove closable'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(closed, 1);
      handle.dispose();
    });

    testWidgets('a closable tag without an accessible name is rejected', (
      WidgetTester tester,
    ) async {
      expect(
        () => LumiereTag(label: 'bad', onClose: () {}),
        throwsAssertionError,
      );
    });

    testWidgets('the icon is decorative and the label stays the name', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const LumiereTag(
            label: 'with icon',
            icon: Icon(Icons.local_offer),
          ),
        ),
      );

      expect(find.bySemanticsLabel('with icon'), findsOneWidget);
      expect(find.byIcon(Icons.local_offer), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the label uses the ink of its own colour family', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const LumiereTag(
            label: 'ink',
            color: LumiereTagColorName.romanticRed,
          ),
        ),
      );
      final LumiereTokens tokens =
          LumiereTokens.of(tester.element(find.byType(LumiereTag)));
      final Color ink = tokens.colors.tag(LumiereTagColorName.romanticRed).ink;

      expect(tester.widget<Text>(find.text('ink')).style!.color, ink);
      // Guards against the palette silently falling back to the neutral entry.
      expect(ink, isNot(tokens.colors.textPrimary));
    });

    testWidgets('renders in the light theme too', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const LumiereTag(
            label: 'light',
            color: LumiereTagColorName.romanticRed,
          ),
          light: true,
        ),
      );
      expect(find.text('light'), findsOneWidget);
    });
  });
}
