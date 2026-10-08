# lumiere_ui

Sistema de diseno y biblioteca de componentes de **Lumiere**.

Es un paquete **independiente de la aplicacion**: no importa el editor, el
viewport, el dominio ni `flutter_gpu`. Su unica entrada visual son los tokens y
su unica salida son widgets. Se consume desde el workspace de la raiz:

```yaml
dependencies:
  lumiere_ui: ^0.1.0
```

```dart
import 'package:lumiere_ui/lumiere_ui.dart';
```

## Uso

```dart
MaterialApp(
  theme: LumiereThemeData.dark(),
  home: Scaffold(
    body: LumiereButton(
      label: 'Guardar',
      leadingIcon: const Icon(Icons.save),
      onPressed: _save,
    ),
  ),
)
```

Para inyectar otro juego de tokens (tema propio, densidad futura):

```dart
LumiereThemeData.dark(tokens: misTokens)
```

## Estado de los tokens: PROVISIONAL

`lib/src/tokens/tokens.g.dart` **no contiene valores de Arco**. Figma sigue
bloqueado por el limite del plan Starter (ver `docs/specs/001`, seccion 9), asi
que ese archivo lleva un juego neutro provisional que solo existe para que la
galeria y los goldens rendericen.

- No son decisiones de diseno y no deben citarse como tokens `DS-*`.
- El juego neutral no incluye color de marca: el acento es un gris a proposito.
- La sustitucion es una sola orden, sin tocar codigo de componentes:

  ```
  node tools/generate-tokens.mjs docs/constraints/design-tokens.json
  ```

## Reglas del paquete

1. **Cero literales visuales en los componentes.** Todo color, tamano, radio y
   tipografia sale de `LumiereTokens` via `LumiereTheme.of(context).tokens`. El
   unico archivo con valores es `tokens.g.dart`.
2. **La direccion de dependencia es hacia dentro.** Este paquete no importa
   nada de la aplicacion, y nunca importara `flutter_gpu`.
3. **Punto de entrada unico.** La aplicacion importa solo
   `package:lumiere_ui/lumiere_ui.dart`; `src/` no es API publica.
4. **Los estados de diseno se mapean a estados reales.** Hover, foco, pulsado y
   deshabilitado son estados del widget, no props. Solo lo que no existe como
   estado real (por ejemplo `Loading`) se expone como prop.

## Como anadir un componente

1. Confirmar que existe en el contrato de Figma y con que variantes y estados.
   Si el contrato no esta disponible, la API queda marcada **PROVISIONAL**.
2. Crear `lib/src/components/<nombre>/<nombre>.dart` con la anatomia del
   componente y **solo** tokens.
3. Cubrir los estados: normal, hover, focus, pressed, disabled y loading si
   aplica.
4. Asegurar teclado y semantica: foco visible, operable con teclado, etiqueta
   accesible, y que ningun estado dependa solo del color.
5. Exportarlo en `lib/lumiere_ui.dart`.
6. Prueba unitaria de comportamiento + **golden por variante y estado**. El
   golden es la verificacion del contrato de diseno, no un extra.
7. Darlo de alta en la galeria de la aplicacion (`features/theme_preview`).

Si el componente es especifico del producto (fila de capa, previsualizacion de
brocha, lista de canales), **no va aqui**: va en la feature correspondiente de la
aplicacion y se compone con primitivas de este paquete.

## Pruebas

```powershell
flutter test                        # unitarias + golden
flutter test --update-goldens       # regenerar la linea base (revisar el diff)
```

## Independencia y publicacion

Hoy es independiente en el sentido que importa: pubspec propio, API publica
propia, pruebas propias, version propia y cero dependencias de la aplicacion.
Se resuelve dentro del workspace de la raiz, con un unico lockfile.

Publicarlo en pub.dev es otro paso y **no es necesario todavia**. Cuando lo sea,
haria falta: `LICENSE`, `repository`/`homepage`, quitar `publish_to: none`,
disciplina de versionado semantico y `CHANGELOG` en cada cambio de API.
