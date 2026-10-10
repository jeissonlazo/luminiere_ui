import 'dart:ui' show CheckedState, SemanticsRole, Tristate;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

/// Key of the instance the hover tests point the mouse at.
const Key kHoverKey = Key('lumiere_radio_hover');

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

LumiereRadioPainter _painterOf(WidgetTester tester, {int index = 0}) {
  final Finder finder = find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint && widget.painter is LumiereRadioPainter,
  );
  final CustomPaint paint =
      tester.widgetList<CustomPaint>(finder).elementAt(index);
  return paint.painter! as LumiereRadioPainter;
}

Focus _focusOf(WidgetTester tester, Finder radio) => tester.widget<Focus>(
      find
          .descendant(of: radio, matching: find.byType(Focus))
          .first,
    );

bool _hasFocus(WidgetTester tester, Finder radio) =>
    _focusOf(tester, radio).focusNode!.hasFocus;

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

/// A group of three radios whose selection is owned by the test.
Widget _group({
  required String selection,
  required ValueChanged<String?> onChanged,
  bool Function(String value)? disabledWhen,
  Widget Function(String value)? iconWhen,
}) =>
    LumiereRadioGroup<String>(
      groupValue: selection,
      onChanged: onChanged,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final String value in <String>['a', 'b', 'c'])
            LumiereRadio<String>(
              value: value,
              label: value.toUpperCase(),
              disabled: disabledWhen?.call(value) ?? false,
              icon: iconWhen?.call(value),
            ),
        ],
      ),
    );

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

  group('LumiereRadio behaviour', () {
    testWidgets('a standalone radio reports its selection',
        (WidgetTester tester) async {
      bool? reported;
      await _pump(
        tester,
        LumiereRadio<String>(
          value: 'a',
          label: 'A',
          onChanged: (bool v) => reported = v,
        ),
      );

      await tester.tap(find.byType(LumiereRadio<String>));

      expect(reported, isTrue);
    });

    testWidgets('a selected standalone radio is not cleared by a tap',
        (WidgetTester tester) async {
      int calls = 0;
      await _pump(
        tester,
        LumiereRadio<String>(
          value: 'a',
          checked: true,
          label: 'A',
          onChanged: (_) => calls++,
        ),
      );

      await tester.tap(find.byType(LumiereRadio<String>));

      expect(calls, 0);
    });

    testWidgets('tapping the label selects the radio',
        (WidgetTester tester) async {
      int calls = 0;
      await _pump(
        tester,
        LumiereRadio<String>(
          value: 'a',
          label: 'A',
          onChanged: (_) => calls++,
        ),
      );

      await tester.tap(find.text('A'));

      expect(calls, 1);
    });

    testWidgets('disabled blocks interaction', (WidgetTester tester) async {
      int calls = 0;
      await _pump(
        tester,
        LumiereRadio<String>(
          value: 'a',
          label: 'A',
          disabled: true,
          onChanged: (_) => calls++,
        ),
      );

      await tester.tap(find.byType(LumiereRadio<String>), warnIfMissed: false);

      expect(calls, 0);
    });

    testWidgets('keeps the measured 24 x 24 interactive box',
        (WidgetTester tester) async {
      await _pump(tester, LumiereRadio<String>(value: 'a'));

      expect(tester.getSize(find.byType(LumiereRadio<String>)),
          const Size(24, 24));
    });

    testWidgets('every axis renders without throwing',
        (WidgetTester tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (final bool checked in <bool>[false, true])
                for (final bool disabled in <bool>[false, true])
                  for (final bool icon in <bool>[false, true])
                    LumiereRadio<String>(
                      value: 'v',
                      checked: checked,
                      disabled: disabled,
                      icon: icon ? const Icon(Icons.star) : null,
                      label: '$checked-$disabled-$icon',
                      onChanged: (_) {},
                    ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('LumiereRadio semantics', () {
    testWidgets('exposes the label as the accessible name',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(tester, LumiereRadio<String>(value: 'a', label: 'Option A'));

      expect(find.bySemanticsLabel('Option A'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(LumiereRadio<String>)).label,
        'Option A',
      );

      handle.dispose();
    });

    testWidgets('exposes the checked state of a standalone radio',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumiereRadio<String>(value: 'a', label: 'off'),
            LumiereRadio<String>(value: 'b', checked: true, label: 'on'),
          ],
        ),
      );

      final SemanticsData off = tester
          .getSemantics(find.byType(LumiereRadio<String>).at(0))
          .getSemanticsData();
      final SemanticsData on = tester
          .getSemantics(find.byType(LumiereRadio<String>).at(1))
          .getSemanticsData();

      expect(off.flagsCollection.isChecked, CheckedState.isFalse);
      expect(on.flagsCollection.isChecked, CheckedState.isTrue);
      expect(on.flagsCollection.isInMutuallyExclusiveGroup, isTrue);

      handle.dispose();
    });

    testWidgets('a group is one node with the radio group role',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        _group(selection: 'b', onChanged: (_) {}),
      );

      final SemanticsData data = tester
          .getSemantics(find.byType(LumiereRadioGroup<String>))
          .getSemanticsData();

      expect(data.role, SemanticsRole.radioGroup);

      final SemanticsData second = tester
          .getSemantics(find.byType(LumiereRadio<String>).at(1))
          .getSemanticsData();

      expect(second.flagsCollection.isChecked, CheckedState.isTrue);
      expect(second.flagsCollection.isInMutuallyExclusiveGroup, isTrue);

      handle.dispose();
    });

    testWidgets('a disabled radio reports the disabled state',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        LumiereRadio<String>(value: 'a', label: 'A', disabled: true),
      );

      final SemanticsData data = tester
          .getSemantics(find.byType(LumiereRadio<String>))
          .getSemanticsData();

      expect(data.flagsCollection.isEnabled, Tristate.isFalse);
      expect(data.hasAction(SemanticsAction.tap), isFalse);

      handle.dispose();
    });

    testWidgets('the group carries the focus state of its selected radio',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        _group(selection: 'a', onChanged: (_) {}),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final SemanticsData data = tester
          .getSemantics(find.byType(LumiereRadio<String>).at(0))
          .getSemanticsData();

      expect(data.flagsCollection.isFocused, Tristate.isTrue);

      handle.dispose();
    });
  });

  group('LumiereRadio group behaviour', () {
    testWidgets('the group is a single tab stop', (WidgetTester tester) async {
      late StateSetter setState;
      String selection = 'a';
      await _pump(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setter) {
            setState = setter;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _group(
                  selection: selection,
                  onChanged: (String? value) =>
                      setState(() => selection = value ?? selection),
                ),
                LumiereButton(label: 'Next', onPressed: () {}),
              ],
            );
          },
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // The first tab stop is the selected radio of the group.
      expect(_hasFocus(tester, find.byType(LumiereRadio<String>).at(0)), isTrue);
      expect(_hasFocus(tester, find.byType(LumiereRadio<String>).at(1)), isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // The second one leaves the group instead of visiting every radio.
      expect(_hasFocus(tester, find.byType(LumiereRadio<String>).at(2)), isFalse);
      expect(
        _hasFocus(
          tester,
          find.byType(LumiereRadio<String>).at(0),
        ),
        isFalse,
      );
    });

    testWidgets('the arrow keys move and select inside the group',
        (WidgetTester tester) async {
      late StateSetter setState;
      String selection = 'a';
      await _pump(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setter) {
            setState = setter;
            return _group(
              selection: selection,
              onChanged: (String? value) =>
                  setState(() => selection = value ?? selection),
            );
          },
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(selection, 'b');
      expect(_hasFocus(tester, find.byType(LumiereRadio<String>).at(1)), isTrue);
      expect(
        tester
            .getSemantics(find.byType(LumiereRadio<String>).at(1))
            .getSemanticsData()
            .flagsCollection
            .isChecked,
        CheckedState.isTrue,
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(selection, 'a');

      // The arrows wrap around the ends of the group.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(selection, 'c');
    });

    testWidgets('the Space key selects the focused radio',
        (WidgetTester tester) async {
      late StateSetter setState;
      String selection = 'a';
      await _pump(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setter) {
            setState = setter;
            return _group(
              selection: selection,
              onChanged: (String? value) =>
                  setState(() => selection = value ?? selection),
            );
          },
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(selection, 'b');

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(selection, 'b');
    });

    testWidgets('a disabled radio is skipped by the arrow keys',
        (WidgetTester tester) async {
      late StateSetter setState;
      String selection = 'a';
      await _pump(
        tester,
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setter) {
            setState = setter;
            return _group(
              selection: selection,
              onChanged: (String? value) =>
                  setState(() => selection = value ?? selection),
              disabledWhen: (String value) => value == 'b',
            );
          },
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      expect(selection, 'c');
    });
  });

  group('LumiereRadio keyboard', () {
    testWidgets('a standalone radio activates with the Space key',
        (WidgetTester tester) async {
      int calls = 0;
      await _pump(
        tester,
        LumiereRadio<String>(
          value: 'a',
          label: 'A',
          onChanged: (_) => calls++,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(calls, 1);
    });

    testWidgets('shows a focus ring on the focused radio',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LumiereRadio<String>(value: 'a', label: 'A', onChanged: (_) {}),
      );

      expect(_painterOf(tester).focusRing, isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(_painterOf(tester).focusRing, LumiereColors.dark.accent.normal);
    });
  });

  group('LumiereRadio colours', () {
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
              LumiereRadio<String>(value: 'a', onChanged: (_) {}),
              LumiereRadio<String>(
                value: 'b',
                checked: true,
                onChanged: (_) {},
              ),
              LumiereRadio<String>(
                value: 'c',
                checked: true,
                disabled: true,
                onChanged: (_) {},
              ),
              LumiereRadio<String>(
                value: 'd',
                disabled: true,
                onChanged: (_) {},
              ),
              LumiereRadio<String>(
                value: 'e',
                checked: true,
                icon: const Icon(Icons.star),
                onChanged: (_) {},
              ),
            ],
          ),
          brightness: brightness,
        );

        final LumiereRadioPainter unselected = _painterOf(tester, index: 0);
        final LumiereRadioPainter selected = _painterOf(tester, index: 1);
        final LumiereRadioPainter disabledSelected =
            _painterOf(tester, index: 2);
        final LumiereRadioPainter disabledUnselected =
            _painterOf(tester, index: 3);
        final LumiereRadioPainter icon = _painterOf(tester, index: 4);

        expect(unselected.fill, isNull,
            reason: '$brightness unselected fill');
        expect(unselected.boundary, colors.borderHeavy,
            reason: '$brightness unselected boundary');
        expect(unselected.dot, isNull,
            reason: '$brightness unselected dot');

        expect(selected.fill, colors.accent.normal,
            reason: '$brightness selected fill');
        expect(selected.boundary, isNull,
            reason: '$brightness selected boundary');
        expect(selected.dot, colors.textOnAccent,
            reason: '$brightness selected dot');

        expect(disabledSelected.fill, colors.accent.disabled,
            reason: '$brightness disabled selected fill');
        expect(disabledUnselected.boundary, colors.borderDefault,
            reason: '$brightness disabled unselected boundary');

        expect(icon.showDot, isFalse,
            reason: '$brightness icon variant draws the icon, not the dot');
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
          LumiereRadio<String>(value: 'a', label: 'A', onChanged: (_) {}),
          brightness: brightness,
        );
        expect(_labelStyleOf(tester).color, colors.textPrimary,
            reason: '$brightness label');

        await _pump(
          tester,
          LumiereRadio<String>(
            value: 'a',
            label: 'A',
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
            LumiereRadio<String>(
              key: kHoverKey,
              value: 'a',
              checked: true,
              onChanged: (_) {},
            ),
            LumiereRadio<String>(value: 'b', onChanged: (_) {}),
          ],
        ),
      );

      await _hover(tester, find.byKey(kHoverKey));

      expect(_painterOf(tester, index: 0).fill, LumiereColors.dark.accent.hover);
      expect(_painterOf(tester, index: 1).boundary, LumiereColors.dark.borderHeavy);
    });

    testWidgets('an unselected radio shows the measured hover background',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LumiereRadio<String>(
          key: kHoverKey,
          value: 'b',
          onChanged: (_) {},
        ),
      );

      await _hover(tester, find.byKey(kHoverKey));

      expect(_painterOf(tester).hoverBackground, LumiereColors.dark.fillSubtle);
      expect(_painterOf(tester).boundary, LumiereColors.dark.accent.normal);
    });

    testWidgets('the icon of the icon variant uses textOnAccent when selected',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LumiereRadio<String>(
          value: 'a',
          checked: true,
          icon: const Icon(Icons.star),
          onChanged: (_) {},
        ),
      );

      final IconThemeData theme = IconTheme.of(
        tester.element(find.byIcon(Icons.star)),
      );

      expect(theme.color, LumiereColors.dark.textOnAccent);
    });
  });
}
