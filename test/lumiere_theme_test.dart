// The typeface is the one token a consumer is expected to replace, so it gets
// its own test file: the default, the override, and the path from the theme all
// the way to the glyph a component actually paints.
//
// `DS-TOK-009` requires a new field to be threaded through the constructor,
// `copyWith`, `lerp`, `==` and `hashCode`; the last group asserts each of them,
// because a field missing from one of those is invisible to theme animation and
// compares equal to a different palette.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

/// A family an application might register instead of the declared one.
const String _otherFamily = 'Acme Sans';

Widget _host(Widget child, {String? fontFamily}) => MaterialApp(
  theme: fontFamily == null
      ? LumiereThemeData.dark()
      : LumiereThemeData.dark(fontFamily: fontFamily),
  home: Scaffold(body: Center(child: child)),
);

/// The family the rendered label of a [LumiereButton] actually resolves to.
String? _renderedFamily(WidgetTester tester) {
  final RichText rich = tester.widget<RichText>(
    find.descendant(
      of: find.byType(LumiereButton),
      matching: find.byType(RichText),
    ),
  );
  return rich.text.style?.fontFamily;
}

void main() {
  group('the declared family', () {
    test('is the one the design file names', () {
      expect(ArcoType.fontFamily, 'Mark Pro');
    });

    test('is what the theme publishes by default', () {
      final LumiereTokens dark = LumiereThemeData.dark()
          .extension<LumiereTokens>()!;
      final LumiereTokens light = LumiereThemeData.light()
          .extension<LumiereTokens>()!;

      expect(dark.fontFamily, ArcoType.fontFamily);
      expect(light.fontFamily, ArcoType.fontFamily);
    });

    test('reaches the text styles the theme builds for Material', () {
      final ThemeData theme = LumiereThemeData.dark();

      expect(theme.textTheme.bodyMedium?.fontFamily, ArcoType.fontFamily);
      expect(theme.textTheme.headlineSmall?.fontFamily, ArcoType.fontFamily);
    });
  });

  group('a family supplied by the application', () {
    test('replaces the default in the tokens', () {
      final LumiereTokens tokens = LumiereThemeData.dark(
        fontFamily: _otherFamily,
      ).extension<LumiereTokens>()!;

      expect(tokens.fontFamily, _otherFamily);
      expect(tokens.fontFamily, isNot(ArcoType.fontFamily));
    });

    test('is used by LumiereTokens.text, not the constant', () {
      const LumiereTokens tokens = LumiereTokens(
        colors: LumiereColors.dark,
        brightness: Brightness.dark,
        fontFamily: _otherFamily,
      );

      expect(tokens.text(size: ArcoType.size14).fontFamily, _otherFamily);
    });

    testWidgets('reaches the glyph a component paints', (
      WidgetTester tester,
    ) async {
      // The component never names a family: it reads the tokens, so a button
      // under a custom theme must render in the custom family.
      await tester.pumpWidget(
        _host(const LumiereButton(label: 'Save'), fontFamily: _otherFamily),
      );

      expect(_renderedFamily(tester), _otherFamily);
    });

    testWidgets('and the default reaches it too', (WidgetTester tester) async {
      await tester.pumpWidget(_host(const LumiereButton(label: 'Save')));

      expect(_renderedFamily(tester), ArcoType.fontFamily);
    });
  });

  group('the field is threaded through every member', () {
    const LumiereTokens base = LumiereTokens(
      colors: LumiereColors.dark,
      brightness: Brightness.dark,
      fontFamily: _otherFamily,
    );

    test('copyWith carries it and can replace it', () {
      expect(base.copyWith().fontFamily, _otherFamily);
      expect(base.copyWith(fontFamily: 'Third').fontFamily, 'Third');
    });

    test('lerp switches it at the midpoint, like the brightness', () {
      const LumiereTokens a = LumiereTokens(
        colors: LumiereColors.dark,
        brightness: Brightness.dark,
        fontFamily: 'A',
      );
      const LumiereTokens b = LumiereTokens(
        colors: LumiereColors.light,
        brightness: Brightness.light,
        fontFamily: 'B',
      );

      expect(a.lerp(b, 0.25).fontFamily, 'A');
      expect(a.lerp(b, 0.75).fontFamily, 'B');
    });

    test('== and hashCode see it', () {
      const LumiereTokens same = LumiereTokens(
        colors: LumiereColors.dark,
        brightness: Brightness.dark,
        fontFamily: _otherFamily,
      );
      const LumiereTokens different = LumiereTokens(
        colors: LumiereColors.dark,
        brightness: Brightness.dark,
        fontFamily: 'Third',
      );

      expect(base, same);
      expect(base.hashCode, same.hashCode);
      expect(base, isNot(different));
      expect(base.hashCode, isNot(different.hashCode));
    });
  });
}
