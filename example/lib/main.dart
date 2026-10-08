// Minimal usage example of `lumiere_ui`.
//
// It is not the product gallery: it only shows how the theme is mounted and how
// a component is consumed.
//
// Platform folders are required to run it:
//   cd example && flutter create .
import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lumiere_ui example',
      debugShowCheckedModeBanner: false,
      theme: LumiereThemeData.dark(),
      home: const _ExamplePage(),
    );
  }
}

class _ExamplePage extends StatelessWidget {
  const _ExamplePage();

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('lumiere_ui')),
      body: Padding(
        padding: const EdgeInsets.all(ArcoSpace.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Type', style: tokens.text(size: ArcoType.size16, weight: FontWeight.w600)),
            Wrap(
              spacing: ArcoSpace.spaceSm,
              runSpacing: ArcoSpace.spaceSm,
              children: <Widget>[
                for (final LumiereButtonType type in LumiereButtonType.values)
                  LumiereButton(label: type.name, type: type, onPressed: () {}),
              ],
            ),
            const SizedBox(height: ArcoSpace.spaceLg),
            Text('State', style: tokens.text(size: ArcoType.size16, weight: FontWeight.w600)),
            const Wrap(
              spacing: ArcoSpace.spaceSm,
              runSpacing: ArcoSpace.spaceSm,
              children: <Widget>[
                LumiereButton(label: 'Disabled'),
                LumiereButton(label: '', leadingIcon: Icon(Icons.add), shape: LumiereButtonShape.circle),
              ],
            ),
            const SizedBox(height: ArcoSpace.spaceSm),
            LumiereButton(
              label: 'With icon',
              leadingIcon: const Icon(Icons.save),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
