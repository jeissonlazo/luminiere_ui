// Ejemplo mínimo de uso de `lumiere_ui`.
//
// No es la galería completa del producto: solo muestra cómo se monta el tema y
// cómo se consume un componente del sistema de diseño.
//
// Para ejecutarlo hacen falta las carpetas de plataforma:
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
    final LumiereTokens tokens = LumiereTheme.of(context).tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('lumiere_ui')),
      body: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Wrap(
          spacing: tokens.spacing.sm,
          runSpacing: tokens.spacing.sm,
          children: <Widget>[
            for (final LumiereButtonVariant variant
                in LumiereButtonVariant.values)
              LumiereButton(
                label: variant.name,
                variant: variant,
                onPressed: () {},
              ),
            const LumiereButton(label: 'Deshabilitado'),
            LumiereButton(
              label: 'Con icono',
              leadingIcon: const Icon(Icons.save),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
