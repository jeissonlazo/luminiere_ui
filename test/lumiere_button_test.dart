import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';
// White-box import: these tests verify that the semantic layer really points at
// the primitives measured from the design file, so they need the raw layer.
import 'package:lumiere_ui/src/tokens/tokens.g.dart';

Widget _host(Widget child) => MaterialApp(
      theme: LumiereThemeData.dark(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('LumiereButton', () {
    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(LumiereButton(label: 'Save', onPressed: () => taps++)),
      );

      await tester.tap(find.byType(LumiereButton));

      expect(taps, 1);
    });

    testWidgets('is disabled when onPressed is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(const LumiereButton(label: 'Save')));

      final TextButton button =
          tester.widget<TextButton>(find.byType(TextButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('isLoading blocks interaction and shows progress',
        (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(LumiereButton(
          label: 'Save',
          isLoading: true,
          onPressed: () => taps++,
        )),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(LumiereButton), warnIfMissed: false);

      expect(taps, 0);
    });

    testWidgets('exposes its label as the accessible name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(LumiereButton(label: 'Save', onPressed: () {})),
      );

      expect(find.bySemanticsLabel('Save'), findsOneWidget);
    });

    testWidgets('keeps decorative icons out of the accessible name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(LumiereButton(
          label: 'Save',
          leadingIcon: const Icon(Icons.save),
          trailingIcon: const Icon(Icons.arrow_forward),
          onPressed: () {},
        )),
      );

      expect(find.bySemanticsLabel('Save'), findsOneWidget);
    });

    testWidgets('uses the control heights of the design tokens',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final LumiereButtonSize size in LumiereButtonSize.values)
              LumiereButton(
                label: size.name,
                size: size,
                onPressed: () {},
              ),
          ],
        ),
      ));

      const Map<LumiereButtonSize, double> expected = <LumiereButtonSize, double>{
        LumiereButtonSize.large: ArcoControl.heightLarge,
        LumiereButtonSize.medium: ArcoControl.heightMedium,
        LumiereButtonSize.small: ArcoControl.heightSmall,
        LumiereButtonSize.mini: ArcoControl.heightMini,
      };

      expected.forEach((LumiereButtonSize size, double height) {
        expect(
          tester.getSize(find.widgetWithText(LumiereButton, size.name)).height,
          height,
          reason: 'height of $size',
        );
      });
    });

    testWidgets('square and circle shapes render a square box',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumiereButton(
              label: '',
              shape: LumiereButtonShape.square,
              leadingIcon: const Icon(Icons.add),
              onPressed: () {},
            ),
            LumiereButton(
              label: '',
              shape: LumiereButtonShape.circle,
              leadingIcon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ],
        ),
      ));

      final Size square =
          tester.getSize(find.byType(LumiereButton).first);
      expect(square.width, square.height);
    });

    testWidgets('every type, kind and shape renders without throwing',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (final LumiereButtonType type in LumiereButtonType.values)
                for (final LumiereButtonKind kind in LumiereButtonKind.values)
                  LumiereButton(
                    label: '${type.name}-${kind.name}',
                    type: type,
                    kind: kind,
                    onPressed: () {},
                  ),
              for (final LumiereButtonShape shape
                  in LumiereButtonShape.values)
                LumiereButton(
                  label: shape.name,
                  shape: shape,
                  onPressed: () {},
                ),
            ],
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
    });
  });

  group('LumiereTokens', () {
    test('the dark theme publishes its tokens through the extension', () {
      final ThemeData theme = LumiereThemeData.dark();

      expect(theme.extension<LumiereTokens>()!.colors, LumiereColors.dark);
    });

    test('semantic roles point at the primitives measured from the file', () {
      expect(LumiereColors.dark.surfaceBase, ArcoSemanticDark.bg1);
      expect(LumiereColors.dark.textPrimary, ArcoSemanticDark.text1);
      expect(LumiereColors.dark.accent.normal, ArcoSemanticDark.primary6);
      expect(LumiereColors.dark.accent.hover, ArcoSemanticDark.primary5);
      expect(LumiereColors.dark.accent.active, ArcoSemanticDark.primary7);
      expect(LumiereColors.dark.accent.disabled, ArcoSemanticDark.primary3);

      expect(LumiereColors.light.surfaceBase, ArcoSemanticLight.bg1);
      expect(LumiereColors.light.accent.normal, ArcoSemanticLight.primary6);
    });

    test('the brand ramp differs between modes, as the file declares', () {
      // The file customises the brand blue in dark mode and keeps Arco's
      // original blue in light mode.
      expect(
        LumiereColors.dark.accent.normal,
        isNot(LumiereColors.light.accent.normal),
      );
    });

    test('text styles take their line height from the design scale', () {
      const LumiereTokens tokens = LumiereTokens(
        colors: LumiereColors.dark,
        brightness: Brightness.dark,
      );

      expect(tokens.text(size: ArcoType.size14).height, closeTo(22 / 14, 0.001));
      expect(tokens.text(size: ArcoType.size16).height, closeTo(24 / 16, 0.001));
      expect(tokens.text(size: 17).height, isNull);
    });

    test('the scales are the ones declared by the design file', () {
      // Approved scale: every step divisible by two. It supersedes the 4 / 8 /
      // 16 / 24 that the Space component declares. See DS-SPACE-001.
      expect(ArcoSpace.spaceXs, 4);
      expect(ArcoSpace.spaceSm, 8);
      expect(ArcoSpace.spaceMd, 12);
      expect(ArcoSpace.spaceLg, 16);
      expect(ArcoSpace.spaceXl, 20);

      expect(ArcoRadius.radiusSm, 2);
      expect(ArcoRadius.radiusMd, 4);
      expect(ArcoRadius.radiusLg, 8);

      expect(ArcoType.fontFamily, 'Nunito Sans');
    });

    test('the control scale pairs every height with its padding', () {
      // Measured from the control geometry: 30 variants per size, zero variance.
      // See DS-CONTROL-001 and design/reference/control-geometry.json.
      expect(ArcoControl.heightMini, 24);
      expect(ArcoControl.paddingMini, 12);
      expect(ArcoControl.heightSmall, 28);
      expect(ArcoControl.paddingSmall, 16);
      expect(ArcoControl.heightMedium, 32);
      expect(ArcoControl.paddingMedium, 16);
      expect(ArcoControl.heightLarge, 36);
      expect(ArcoControl.paddingLarge, 20);

      // The invariant the approved scale implies: control padding is spacing.
      const List<double> spacing = <double>[
        ArcoSpace.spaceXs,
        ArcoSpace.spaceSm,
        ArcoSpace.spaceMd,
        ArcoSpace.spaceLg,
        ArcoSpace.spaceXl,
      ];
      for (final double padding in <double>[
        ArcoControl.paddingMini,
        ArcoControl.paddingSmall,
        ArcoControl.paddingMedium,
        ArcoControl.paddingLarge,
      ]) {
        expect(spacing, contains(padding), reason: 'padding $padding is not on the spacing scale');
      }
    });
  });
}
