import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

/// Key of the instance the hover tests point the mouse at.
const Key kHoverKey = Key('lumiere_checkbox_hover');

Widget _host(Widget child, {Brightness brightness = Brightness.dark}) =>
    MaterialApp(
      theme: brightness == Brightness.dark
          ? LumiereThemeData.dark()
          : LumiereThemeData.light(),
      home: Scaffold(body: Center(child: child)),
    );

/// Pumps the host and settles the theme animation.
///
/// `MaterialApp` animates a theme change, and [LumiereTokens] travels as a
/// theme extension, so the tokens of the requested theme are only in place once
/// that animation has settled.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.dark,
}) async {
  await tester.pumpWidget(_host(child, brightness: brightness));
  await tester.pumpAndSettle();
}

LumiereCheckboxPainter _painterOf(WidgetTester tester, {int index = 0}) {
  final Finder finder = find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint && widget.painter is LumiereCheckboxPainter,
  );
  final CustomPaint paint =
      tester.widgetList<CustomPaint>(finder).elementAt(index);
  return paint.painter! as LumiereCheckboxPainter;
}

Focus _focusOf(WidgetTester tester) => tester.widget<Focus>(
      find
          .descendant(
            of: find.byType(LumiereCheckbox),
            matching: find.byType(Focus),
          )
          .first,
    );

TextStyle _labelStyleOf(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text)).style!;

Future<void> _hover(WidgetTester tester, Finder target) async {
  final TestGesture gesture =
      await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await tester.pump();

  await gesture.moveTo(tester.getCenter(target));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    // The test platform is mobile, where Flutter suppresses hover and focus
    // highlights until a key is pressed. The controls are tested the way a
    // desktop session runs them.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  });

  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  group('LumiereCheckbox behaviour', () {
    testWidgets('reports the new value when tapped',
        (WidgetTester tester) async {
      bool? reported;
      await _pump(
        tester,
        LumiereCheckbox(label: 'Accept', onChanged: (bool v) => reported = v),
      );

      await tester.tap(find.byType(LumiereCheckbox));

      expect(reported, isTrue);
    });

    testWidgets('tapping the label activates the box',
        (WidgetTester tester) async {
      int calls = 0;
      await _pump(
        tester,
        LumiereCheckbox(label: 'Accept', onChanged: (_) => calls++),
      );

      await tester.tap(find.text('Accept'));

      expect(calls, 1);
    });

    testWidgets('a tap on the indeterminate state selects the box',
        (WidgetTester tester) async {
      bool? reported;
      await _pump(
        tester,
        LumiereCheckbox(
          checked: true,
          indeterminate: true,
          label: 'Accept',
          onChanged: (bool v) => reported = v,
        ),
      );

      await tester.tap(find.byType(LumiereCheckbox));

      expect(reported, isTrue);
    });

    testWidgets('disabled blocks interaction', (WidgetTester tester) async {
      int calls = 0;
      await _pump(
        tester,
        LumiereCheckbox(
          disabled: true,
          label: 'Accept',
          onChanged: (_) => calls++,
        ),
      );

      await tester.tap(find.byType(LumiereCheckbox), warnIfMissed: false);

      expect(calls, 0);
    });

    testWidgets('a null onChanged also disables the box',
        (WidgetTester tester) async {
      await _pump(tester, const LumiereCheckbox(label: 'Accept'));

      final LumiereCheckboxPainter painter = _painterOf(tester);
      expect(painter.boundary, LumiereColors.dark.borderDefault);
      expect(painter.focusRing, isNull);
    });

    testWidgets('keeps the measured 24 x 24 interactive box',
        (WidgetTester tester) async {
      await _pump(tester, LumiereCheckbox(onChanged: (_) {}));

      expect(tester.getSize(find.byType(LumiereCheckbox)), const Size(24, 24));
    });

    testWidgets('every axis renders without throwing',
        (WidgetTester tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (final bool checked in <bool>[false, true])
                for (final bool indeterminate in <bool>[false, true])
                  for (final bool disabled in <bool>[false, true])
                    LumiereCheckbox(
                      checked: checked,
                      indeterminate: indeterminate,
                      disabled: disabled,
                      label: '$checked-$indeterminate-$disabled',
                      onChanged: (_) {},
                    ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('LumiereCheckbox semantics', () {
    testWidgets('exposes the label as the accessible name',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        LumiereCheckbox(label: 'Accept', onChanged: (_) {}),
      );

      expect(find.bySemanticsLabel('Accept'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(LumiereCheckbox)).label,
        'Accept',
      );

      handle.dispose();
    });

    testWidgets('exposes the checked and unchecked state',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumiereCheckbox(label: 'off', onChanged: (_) {}),
            LumiereCheckbox(checked: true, label: 'on', onChanged: (_) {}),
          ],
        ),
      );

      final SemanticsNode unchecked =
          tester.getSemantics(find.byType(LumiereCheckbox).at(0));
      final SemanticsNode checked =
          tester.getSemantics(find.byType(LumiereCheckbox).at(1));

      expect(unchecked.getSemanticsData().flagsCollection.isChecked, CheckedState.isFalse);
      expect(checked.getSemanticsData().flagsCollection.isChecked, CheckedState.isTrue);

      handle.dispose();
    });

    testWidgets('exposes the mixed state for the indeterminate box',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        LumiereCheckbox(
          indeterminate: true,
          label: 'Accept',
          onChanged: (_) {},
        ),
      );

      final SemanticsNode node =
          tester.getSemantics(find.byType(LumiereCheckbox));

      expect(node.getSemanticsData().flagsCollection.isChecked, CheckedState.mixed);

      handle.dispose();
    });

    testWidgets('carries the tap action and the enabled state',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        LumiereCheckbox(label: 'Accept', onChanged: (_) {}),
      );

      final SemanticsNode node =
          tester.getSemantics(find.byType(LumiereCheckbox));

      expect(node.getSemanticsData().flagsCollection.isEnabled, Tristate.isTrue);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);

      handle.dispose();
    });

    testWidgets('exposes the disabled state and offers no tap action',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        LumiereCheckbox(
          disabled: true,
          label: 'Accept',
          onChanged: (_) {},
        ),
      );

      final SemanticsNode node =
          tester.getSemantics(find.byType(LumiereCheckbox));

      expect(node.getSemanticsData().flagsCollection.isEnabled, Tristate.isFalse);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);

      handle.dispose();
    });

    testWidgets('exposes the focus state to assistive technology',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        LumiereCheckbox(label: 'Accept', onChanged: (_) {}),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      // Two frames: one to rebuild the focus widget, one to publish the new
      // semantics.
      await tester.pumpAndSettle();

      final SemanticsData data =
          tester.getSemantics(find.byType(LumiereCheckbox)).getSemanticsData();

      expect(data.flagsCollection.isFocused, Tristate.isTrue);

      handle.dispose();
    });
  });

  group('LumiereCheckbox keyboard', () {
    testWidgets('takes focus with the Tab key and shows a focus ring',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LumiereCheckbox(label: 'Accept', onChanged: (_) {}),
      );

      expect(_focusOf(tester).focusNode!.hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(_focusOf(tester).focusNode!.hasFocus, isTrue);
      expect(_painterOf(tester).focusRing, LumiereColors.dark.accent.normal);
    });

    testWidgets('activates with the Space key', (WidgetTester tester) async {
      int calls = 0;
      await _pump(
        tester,
        LumiereCheckbox(label: 'Accept', onChanged: (_) => calls++),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(calls, 1);
    });

    testWidgets('a disabled box cannot be reached with the Tab key',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LumiereCheckbox(
          disabled: true,
          label: 'Accept',
          onChanged: (_) {},
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(_focusOf(tester).focusNode!.hasFocus, isFalse);
    });
  });

  group('LumiereCheckbox colours', () {
    testWidgets('resolves every colour from the tokens, in both themes',
        (WidgetTester tester) async {
      for (final Brightness brightness in Brightness.values) {
        final LumiereColors colors = brightness == Brightness.dark
            ? LumiereColors.dark
            : LumiereColors.light;

        await _pump(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LumiereCheckbox(onChanged: (_) {}),
              LumiereCheckbox(checked: true, onChanged: (_) {}),
              LumiereCheckbox(indeterminate: true, onChanged: (_) {}),
              LumiereCheckbox(checked: true, disabled: true, onChanged: (_) {}),
              LumiereCheckbox(disabled: true, onChanged: (_) {}),
            ],
          ),
          brightness: brightness,
        );

        final LumiereCheckboxPainter unchecked = _painterOf(tester, index: 0);
        final LumiereCheckboxPainter checked = _painterOf(tester, index: 1);
        final LumiereCheckboxPainter mixed = _painterOf(tester, index: 2);
        final LumiereCheckboxPainter disabledChecked =
            _painterOf(tester, index: 3);
        final LumiereCheckboxPainter disabledUnchecked =
            _painterOf(tester, index: 4);

        expect(unchecked.fill, isNull, reason: '$brightness unchecked fill');
        expect(unchecked.boundary, colors.borderHeavy,
            reason: '$brightness unchecked boundary');
        expect(unchecked.graphic, isNull,
            reason: '$brightness unchecked graphic');

        expect(checked.fill, colors.accent.normal,
            reason: '$brightness checked fill');
        expect(checked.boundary, isNull,
            reason: '$brightness checked boundary');
        expect(checked.graphic, colors.textOnAccent,
            reason: '$brightness checked graphic');

        expect(mixed.indeterminate, isTrue);
        expect(mixed.graphic, colors.textOnAccent,
            reason: '$brightness mixed graphic');

        expect(disabledChecked.fill, colors.accent.disabled,
            reason: '$brightness disabled checked fill');
        expect(disabledChecked.graphic, colors.textOnAccent,
            reason: '$brightness disabled checked graphic');

        expect(disabledUnchecked.fill, colors.fillSubtle,
            reason: '$brightness disabled unchecked fill');
        expect(disabledUnchecked.boundary, colors.borderDefault,
            reason: '$brightness disabled unchecked boundary');
      }
    });

    testWidgets('the label uses textPrimary and textDisabled',
        (WidgetTester tester) async {
      for (final Brightness brightness in Brightness.values) {
        final LumiereColors colors = brightness == Brightness.dark
            ? LumiereColors.dark
            : LumiereColors.light;

        await _pump(
          tester,
          LumiereCheckbox(label: 'Accept', onChanged: (_) {}),
          brightness: brightness,
        );
        expect(_labelStyleOf(tester).color, colors.textPrimary,
            reason: '$brightness label');

        await _pump(
          tester,
          LumiereCheckbox(
            label: 'Accept',
            disabled: true,
            onChanged: (_) {},
          ),
          brightness: brightness,
        );
        expect(_labelStyleOf(tester).color, colors.textDisabled,
            reason: '$brightness disabled label');
      }
    });

    testWidgets('hover is a real state and moves the accent ramp',
        (WidgetTester tester) async {
      await _pump(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumiereCheckbox(key: kHoverKey, checked: true, onChanged: (_) {}),
            LumiereCheckbox(onChanged: (_) {}),
          ],
        ),
      );

      await _hover(tester, find.byKey(kHoverKey));

      expect(_painterOf(tester, index: 0).fill, LumiereColors.dark.accent.hover);
      expect(_painterOf(tester, index: 0).boundary, isNull);
      expect(_painterOf(tester, index: 1).boundary, LumiereColors.dark.borderHeavy);
      expect(_painterOf(tester, index: 1).hoverBackground, isNull);
    });

    testWidgets('an unchecked box shows the measured hover background',
        (WidgetTester tester) async {
      await _pump(tester, LumiereCheckbox(key: kHoverKey, onChanged: (_) {}));

      await _hover(tester, find.byKey(kHoverKey));

      final LumiereCheckboxPainter painter = _painterOf(tester);

      expect(painter.hoverBackground, LumiereColors.dark.fillSubtle);
      expect(painter.boundary, LumiereColors.dark.accent.normal);
    });
  });
}
