// Golden tests depend on the operating system's rasterisation, so CI excludes
// them with `--exclude-tags=golden`; the baseline is produced locally.
@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

const Key kGoldenKey = Key('lumiere_radio_golden');

/// Focus node of the focused instance of each panel.
///
/// One node per panel: a [FocusNode] cannot be attached to two widgets.
final Map<Brightness, FocusNode> _focusNodes = <Brightness, FocusNode>{
  Brightness.dark: FocusNode(debugLabel: 'golden-dark'),
  Brightness.light: FocusNode(debugLabel: 'golden-light'),
};

Widget _row(LumiereColors colors, String name, List<Widget> children) =>
    Padding(
      padding: const EdgeInsets.only(bottom: ArcoSpace.spaceXs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              name,
              style: TextStyle(
                fontFamily: ArcoType.fontFamily,
                fontSize: ArcoType.size12,
                color: colors.textSecondary,
              ),
            ),
          ),
          for (final Widget child in children) ...<Widget>[
            child,
            const SizedBox(width: ArcoSpace.spaceMd),
          ],
        ],
      ),
    );

/// One theme's matrix: every axis of the component, labelled.
Widget _panel(Brightness brightness) => Theme(
      data: brightness == Brightness.dark
          ? LumiereThemeData.dark()
          : LumiereThemeData.light(),
      child: Builder(
        builder: (BuildContext context) {
          final LumiereColors colors = LumiereTokens.of(context).colors;
          return ColoredBox(
            color: colors.surfaceBase,
            child: Padding(
              padding: const EdgeInsets.all(ArcoSpace.spaceMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _row(colors, brightness.name, <Widget>[
                    LumiereRadio<String>(
                      value: 'off',
                      label: 'checked=false',
                      onChanged: (_) {},
                    ),
                    LumiereRadio<String>(
                      value: 'on',
                      checked: true,
                      label: 'checked=true',
                      onChanged: (_) {},
                    ),
                  ]),
                  _row(colors, 'disabled', <Widget>[
                    LumiereRadio<String>(
                      value: 'off',
                      label: 'off',
                      disabled: true,
                      onChanged: (_) {},
                    ),
                    LumiereRadio<String>(
                      value: 'on',
                      checked: true,
                      label: 'checked',
                      disabled: true,
                      onChanged: (_) {},
                    ),
                  ]),
                  _row(colors, 'icon', <Widget>[
                    LumiereRadio<String>(
                      value: 'off',
                      label: 'off',
                      icon: const Icon(Icons.star),
                      onChanged: (_) {},
                    ),
                    LumiereRadio<String>(
                      value: 'on',
                      checked: true,
                      label: 'checked',
                      icon: const Icon(Icons.star),
                      onChanged: (_) {},
                    ),
                  ]),
                  _row(colors, 'focus', <Widget>[
                    LumiereRadio<String>(
                      value: 'on',
                      checked: true,
                      focusNode: _focusNodes[brightness],
                      label: 'focused',
                      onChanged: (_) {},
                    ),
                  ]),
                  _row(colors, 'label=false', <Widget>[
                    LumiereRadio<String>(value: 'off', onChanged: (_) {}),
                    LumiereRadio<String>(
                      value: 'on',
                      checked: true,
                      onChanged: (_) {},
                    ),
                  ]),
                  _row(colors, 'group', <Widget>[
                    LumiereRadioGroup<String>(
                      groupValue: 'b',
                      onChanged: (_) {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final String value in <String>['a', 'b', 'c'])
                            LumiereRadio<String>(
                              value: value,
                              label: value.toUpperCase(),
                            ),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );

Widget _matrix() => MaterialApp(
      theme: LumiereThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: RepaintBoundary(
            key: kGoldenKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _panel(Brightness.dark),
                _panel(Brightness.light),
              ],
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('golden: every axis, both themes', (WidgetTester tester) async {
    // A stable viewport keeps the baseline independent of the test window.
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // The focus ring is a focus highlight, which a touch-first platform
    // suppresses.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic;
    });

    await tester.pumpWidget(_matrix());
    await tester.pumpAndSettle();

    for (final FocusNode node in _focusNodes.values) {
      node.requestFocus();
      await tester.pumpAndSettle();
    }

    await expectLater(
      find.byKey(kGoldenKey),
      matchesGoldenFile('goldens/lumiere_radio.png'),
    );
  });
}
