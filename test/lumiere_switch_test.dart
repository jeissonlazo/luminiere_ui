import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

/// Key of the instance the hover tests point the mouse at.
const Key kHoverKey = Key('lumiere_switch_hover');

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

LumiereSwitchPainter _painterOf(WidgetTester tester, {int index = 0}) {
  final Finder finder = find.byWidgetPredicate(
    (Widget widget) =>
        widget is CustomPaint && widget.painter is LumiereSwitchPainter,
  );
  final CustomPaint paint =
      tester.widgetList<CustomPaint>(finder).elementAt(index);
  return paint.painter! as LumiereSwitchPainter;
}

Focus _focusOf(WidgetTester tester) => tester.widget<Focus>(
      find
          .descendant(
            of: find.byType(LumiereSwitch),
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

  group('LumiereSwitch behaviour', () {
    testWidgets('reports the new value when tapped',
        (WidgetTester tester) async {
      bool? reported;
      await _pump(tester, LumiereSwitch(onChanged: (bool v) => reported = v));

      await tester.tap(find.byType(LumiereSwitch));

      expect(reported, isTrue);
    });

    testWidgets('tapping the label toggles the switch',
        (WidgetTester tester) async {
      int calls = 0;
      await _pump(
        tester,
        LumiereSwitch(
          label: 'Wifi',
          trackContent: LumiereSwitchTrackContent.text,
          onChanged: (_) => calls++,
        ),
      );

      await tester.tap(find.text('Wifi'));

      expect(calls, 1);
    });

    testWidgets('disabled blocks interaction', (WidgetTester tester) async {
      int calls = 0;
      await _pump(
        tester,
        LumiereSwitch(disabled: true, onChanged: (_) => calls++),
      );

      await tester.tap(find.byType(LumiereSwitch), warnIfMissed: false);

      expect(calls, 0);
    });

    testWidgets('a null onChanged also disables the switch',
        (WidgetTester tester) async {
      await _pump(tester, const LumiereSwitch());

      expect(_painterOf(tester).trackFill, LumiereColors.dark.fillDefault);
      expect(_focusOf(tester).focusNode!.hasFocus, isFalse);
    });

    testWidgets('every axis renders without throwing',
        (WidgetTester tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              for (final LumiereSwitchType type in LumiereSwitchType.values)
                for (final LumiereSwitchSize size in LumiereSwitchSize.values)
                  for (final bool value in <bool>[false, true])
                    for (final bool disabled in <bool>[false, true])
                      LumiereSwitch(
                        type: type,
                        size: size,
                        value: value,
                        disabled: disabled,
                        // The line type carries neither an icon nor a handle
                        // icon in the design.
                        handleIcon: type == LumiereSwitchType.line
                            ? null
                            : const Icon(Icons.check),
                        trackContent: type == LumiereSwitchType.line
                            ? LumiereSwitchTrackContent.none
                            : LumiereSwitchTrackContent.icon,
                        trackIcon: const Icon(Icons.circle),
                        semanticLabel: '${type.name}-${size.name}-$value',
                        onChanged: (_) {},
                      ),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('LumiereSwitch geometry', () {
    testWidgets('keeps the measured interactive box of every variant',
        (WidgetTester tester) async {
      const Map<(LumiereSwitchType, LumiereSwitchSize), Size> expected =
          <(LumiereSwitchType, LumiereSwitchSize), Size>{
        // Frames of 40 x 24 and 28 x 16 for the round and rectangular types.
        (LumiereSwitchType.circle, LumiereSwitchSize.standard):
            Size(40, 24),
        (LumiereSwitchType.circle, LumiereSwitchSize.small): Size(28, 16),
        (LumiereSwitchType.rectangle, LumiereSwitchSize.standard):
            Size(40, 24),
        (LumiereSwitchType.rectangle, LumiereSwitchSize.small): Size(28, 16),
        // The line type is the bounding box of a 36 x 6 or 28 x 4 bar and the
        // 20 x 20 handle.
        (LumiereSwitchType.line, LumiereSwitchSize.standard): Size(36, 20),
        (LumiereSwitchType.line, LumiereSwitchSize.small): Size(28, 20),
      };

      for (final MapEntry<(LumiereSwitchType, LumiereSwitchSize), Size> entry
          in expected.entries) {
        await _pump(
          tester,
          LumiereSwitch(
            type: entry.key.$1,
            size: entry.key.$2,
            onChanged: (_) {},
          ),
        );

        expect(
          tester.getSize(find.byType(LumiereSwitch)),
          entry.value,
          reason: '${entry.key.$1.name} ${entry.key.$2.name}',
        );
      }
    });

    testWidgets('the track and the handle keep the measured sizes',
        (WidgetTester tester) async {
      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumiereSwitch(onChanged: (_) {}),
            LumiereSwitch(size: LumiereSwitchSize.small, onChanged: (_) {}),
            LumiereSwitch(
              type: LumiereSwitchType.line,
              onChanged: (_) {},
            ),
            LumiereSwitch(
              type: LumiereSwitchType.line,
              size: LumiereSwitchSize.small,
              onChanged: (_) {},
            ),
          ],
        ),
      );

      final LumiereSwitchPainter standard = _painterOf(tester, index: 0);
      final LumiereSwitchPainter small = _painterOf(tester, index: 1);
      final LumiereSwitchPainter line = _painterOf(tester, index: 2);
      final LumiereSwitchPainter lineSmall = _painterOf(tester, index: 3);

      expect(standard.metrics.trackWidth, 40);
      expect(standard.metrics.trackHeight, 24);
      expect(standard.metrics.handleSize, 16);
      // The measured radius of the round track is 20, half of its height.
      expect(standard.metrics.trackRadius, ArcoRadius.radiusFull);

      expect(small.metrics.trackWidth, 28);
      expect(small.metrics.trackHeight, 16);
      expect(small.metrics.handleSize, 10);

      expect(line.metrics.trackWidth, 36);
      expect(line.metrics.trackHeight, 6);
      expect(line.metrics.handleSize, 20);

      expect(lineSmall.metrics.trackWidth, 28);
      expect(lineSmall.metrics.trackHeight, 4);
      expect(lineSmall.metrics.handleSize, 20);
    });

    testWidgets('the handle moves from one end of the track to the other',
        (WidgetTester tester) async {
      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumiereSwitch(onChanged: (_) {}),
            LumiereSwitch(value: true, onChanged: (_) {}),
            LumiereSwitch(size: LumiereSwitchSize.small, onChanged: (_) {}),
            LumiereSwitch(
              size: LumiereSwitchSize.small,
              value: true,
              onChanged: (_) {},
            ),
            LumiereSwitch(type: LumiereSwitchType.line, onChanged: (_) {}),
            LumiereSwitch(
              type: LumiereSwitchType.line,
              value: true,
              onChanged: (_) {},
            ),
          ],
        ),
      );

      // Off and on are the two ends of the measured track; the handle never
      // leaves the box.
      expect(_painterOf(tester, index: 0).handleLeft, 4);
      expect(_painterOf(tester, index: 1).handleLeft, 20);
      expect(_painterOf(tester, index: 2).handleLeft, 3);
      expect(_painterOf(tester, index: 3).handleLeft, 15);
      expect(_painterOf(tester, index: 4).handleLeft, 0);
      expect(_painterOf(tester, index: 5).handleLeft, 16);
    });

    testWidgets('the icon track content and the handle icon are drawn',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LumiereSwitch(
          handleIcon: const Icon(Icons.check),
          trackContent: LumiereSwitchTrackContent.icon,
          trackIcon: const Icon(Icons.circle),
          semanticLabel: 'Icon switch',
          onChanged: (_) {},
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the line type rejects track content and a handle icon',
        (WidgetTester tester) async {
      expect(
        () => LumiereSwitch(
          type: LumiereSwitchType.line,
          trackContent: LumiereSwitchTrackContent.text,
          onChanged: (_) {},
        ),
        throwsAssertionError,
      );
      expect(
        () => LumiereSwitch(
          type: LumiereSwitchType.line,
          handleIcon: const Icon(Icons.check),
          onChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });
  });

  group('LumiereSwitch semantics', () {
    testWidgets('exposes the visible label as the accessible name',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        LumiereSwitch(
          label: 'Wifi',
          trackContent: LumiereSwitchTrackContent.text,
          onChanged: (_) {},
        ),
      );

      expect(find.bySemanticsLabel('Wifi'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('an icon-only switch uses its semantic label',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        LumiereSwitch(semanticLabel: 'Wifi', onChanged: (_) {}),
      );

      expect(find.bySemanticsLabel('Wifi'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('exposes the on and off state', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumiereSwitch(semanticLabel: 'off', onChanged: (_) {}),
            LumiereSwitch(
              value: true,
              semanticLabel: 'on',
              onChanged: (_) {},
            ),
          ],
        ),
      );

      final SemanticsData off = tester
          .getSemantics(find.byType(LumiereSwitch).at(0))
          .getSemanticsData();
      final SemanticsData on = tester
          .getSemantics(find.byType(LumiereSwitch).at(1))
          .getSemanticsData();

      expect(off.flagsCollection.isToggled, Tristate.isFalse);
      expect(on.flagsCollection.isToggled, Tristate.isTrue);
      expect(on.hasAction(SemanticsAction.tap), isTrue);

      handle.dispose();
    });

    testWidgets('exposes the disabled state and the focus state',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        LumiereSwitch(semanticLabel: 'Wifi', disabled: true, onChanged: (_) {}),
      );

      final SemanticsData disabled = tester
          .getSemantics(find.byType(LumiereSwitch))
          .getSemanticsData();

      expect(disabled.flagsCollection.isEnabled, Tristate.isFalse);
      expect(disabled.hasAction(SemanticsAction.tap), isFalse);

      await _pump(
        tester,
        LumiereSwitch(semanticLabel: 'Wifi', onChanged: (_) {}),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final SemanticsData focused = tester
          .getSemantics(find.byType(LumiereSwitch))
          .getSemanticsData();

      expect(focused.flagsCollection.isFocused, Tristate.isTrue);

      handle.dispose();
    });
  });

  group('LumiereSwitch keyboard', () {
    testWidgets('takes focus with the Tab key and shows a focus ring',
        (WidgetTester tester) async {
      await _pump(tester, LumiereSwitch(onChanged: (_) {}));

      expect(_focusOf(tester).focusNode!.hasFocus, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(_focusOf(tester).focusNode!.hasFocus, isTrue);
      // On the round and rectangular types the ring lands on the track, so it
      // is drawn in the page colour.
      expect(_painterOf(tester).focusRing, LumiereColors.dark.surfaceBase);
    });

    testWidgets('the line type draws its ring on the page',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LumiereSwitch(type: LumiereSwitchType.line, onChanged: (_) {}),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(_painterOf(tester).focusRing, LumiereColors.dark.accent.normal);
    });

    testWidgets('toggles with the Space key', (WidgetTester tester) async {
      int calls = 0;
      await _pump(tester, LumiereSwitch(onChanged: (_) => calls++));

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();

      expect(calls, 1);
    });

    testWidgets('a disabled switch cannot be reached with the Tab key',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LumiereSwitch(disabled: true, onChanged: (_) {}),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(_focusOf(tester).focusNode!.hasFocus, isFalse);
    });
  });

  group('LumiereSwitch colours', () {
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
              LumiereSwitch(onChanged: (_) {}),
              LumiereSwitch(value: true, onChanged: (_) {}),
              LumiereSwitch(disabled: true, onChanged: (_) {}),
              LumiereSwitch(value: true, disabled: true, onChanged: (_) {}),
            ],
          ),
          brightness: brightness,
        );

        final LumiereSwitchPainter off = _painterOf(tester, index: 0);
        final LumiereSwitchPainter on = _painterOf(tester, index: 1);
        final LumiereSwitchPainter disabledOff = _painterOf(tester, index: 2);
        final LumiereSwitchPainter disabledOn = _painterOf(tester, index: 3);

        expect(off.trackFill, colors.borderHeavy,
            reason: '$brightness off track');
        expect(on.trackFill, colors.accent.normal,
            reason: '$brightness on track');
        expect(on.handleFill, colors.textOnAccent,
            reason: '$brightness on handle');
        expect(disabledOff.trackFill, colors.fillDefault,
            reason: '$brightness disabled off track');
        expect(disabledOn.trackFill, colors.accent.disabled,
            reason: '$brightness disabled on track');
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
          LumiereSwitch(
            label: 'Wifi',
            trackContent: LumiereSwitchTrackContent.text,
            onChanged: (_) {},
          ),
          brightness: brightness,
        );
        expect(_labelStyleOf(tester).color, colors.textPrimary,
            reason: '$brightness label');

        await _pump(
          tester,
          LumiereSwitch(
            label: 'Wifi',
            trackContent: LumiereSwitchTrackContent.text,
            disabled: true,
            onChanged: (_) {},
          ),
          brightness: brightness,
        );
        expect(_labelStyleOf(tester).color, colors.textDisabled,
            reason: '$brightness disabled label');

        // The design pairs the line type with an empty track only, so its
        // label stays beside the bar.
        await _pump(
          tester,
          LumiereSwitch(
            type: LumiereSwitchType.line,
            label: 'Wifi',
            onChanged: (_) {},
          ),
          brightness: brightness,
        );
        expect(_labelStyleOf(tester).color, colors.textPrimary,
            reason: '$brightness line label');
      }
    });

    testWidgets('hover is a real state on both ends of the track',
        (WidgetTester tester) async {
      await _pump(
        tester,
        LumiereSwitch(key: kHoverKey, value: true, onChanged: (_) {}),
      );

      await _hover(tester, find.byKey(kHoverKey));

      expect(_painterOf(tester).trackFill, LumiereColors.dark.accent.hover);
    });

    testWidgets('the off track darkens to the hover step of the border scale',
        (WidgetTester tester) async {
      await _pump(tester, LumiereSwitch(key: kHoverKey, onChanged: (_) {}));

      await _hover(tester, find.byKey(kHoverKey));

      expect(_painterOf(tester).trackFill, LumiereColors.dark.borderStrong);
    });
  });
}
