// Golden tests depend on the operating system's rasterisation, so CI excludes
// them with `--exclude-tags=golden`; the baseline is produced locally.
@Tags(<String>['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

const Key kGoldenKey = Key('lumiere_switch_golden');

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
            width: 112,
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
            const SizedBox(width: ArcoSpace.spaceLg),
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
                  for (final LumiereSwitchType type
                      in LumiereSwitchType.values)
                    for (final LumiereSwitchSize size
                        in LumiereSwitchSize.values)
                      _row(
                        colors,
                        '${type.name}/${size.name}',
                        <Widget>[
                          LumiereSwitch(
                            type: type,
                            size: size,
                            semanticLabel: '${type.name} off',
                            onChanged: (_) {},
                          ),
                          LumiereSwitch(
                            type: type,
                            size: size,
                            value: true,
                            semanticLabel: '${type.name} on',
                            onChanged: (_) {},
                          ),
                        ],
                      ),
                  _row(colors, 'disabled', <Widget>[
                    LumiereSwitch(
                      disabled: true,
                      semanticLabel: 'disabled off',
                      onChanged: (_) {},
                    ),
                    LumiereSwitch(
                      value: true,
                      disabled: true,
                      semanticLabel: 'disabled on',
                      onChanged: (_) {},
                    ),
                  ]),
                  _row(colors, 'handleIcon', <Widget>[
                    LumiereSwitch(
                      handleIcon: const Icon(Icons.check),
                      semanticLabel: 'handle icon off',
                      onChanged: (_) {},
                    ),
                    LumiereSwitch(
                      value: true,
                      handleIcon: const Icon(Icons.check),
                      semanticLabel: 'handle icon on',
                      onChanged: (_) {},
                    ),
                  ]),
                  _row(colors, 'trackContent=icon', <Widget>[
                    LumiereSwitch(
                      trackContent: LumiereSwitchTrackContent.icon,
                      trackIcon: const Icon(Icons.check),
                      semanticLabel: 'track icon off',
                      onChanged: (_) {},
                    ),
                    LumiereSwitch(
                      value: true,
                      trackContent: LumiereSwitchTrackContent.icon,
                      trackIcon: const Icon(Icons.check),
                      semanticLabel: 'track icon on',
                      onChanged: (_) {},
                    ),
                  ]),
                  _row(colors, 'trackContent=text', <Widget>[
                    LumiereSwitch(
                      label: 'off',
                      trackContent: LumiereSwitchTrackContent.text,
                      onChanged: (_) {},
                    ),
                    LumiereSwitch(
                      value: true,
                      label: 'on',
                      trackContent: LumiereSwitchTrackContent.text,
                      onChanged: (_) {},
                    ),
                  ]),
                  _row(colors, 'focus', <Widget>[
                    LumiereSwitch(
                      value: true,
                      focusNode: _focusNodes[brightness],
                      semanticLabel: 'focused',
                      onChanged: (_) {},
                    ),
                    LumiereSwitch(
                      type: LumiereSwitchType.line,
                      focusNode: _lineFocusNodes[brightness],
                      semanticLabel: 'focused line',
                      onChanged: (_) {},
                    ),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );

/// Focus nodes of the line instances, which draw the ring on the page.
final Map<Brightness, FocusNode> _lineFocusNodes = <Brightness, FocusNode>{
  Brightness.dark: FocusNode(debugLabel: 'golden-line-dark'),
  Brightness.light: FocusNode(debugLabel: 'golden-line-light'),
};

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
    // The matrix is taller than the default test window.
    tester.view.physicalSize = const Size(1000, 1600);
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

    for (final FocusNode node in <FocusNode>[
      ..._focusNodes.values,
      ..._lineFocusNodes.values,
    ]) {
      node.requestFocus();
      await tester.pumpAndSettle();
    }

    await expectLater(
      find.byKey(kGoldenKey),
      matchesGoldenFile('goldens/lumiere_switch.png'),
    );
  });
}
