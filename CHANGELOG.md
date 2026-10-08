# Changelog

Formato basado en Keep a Changelog; versionado semantico.

## 0.1.0

### Anadido

- Estructura del paquete independiente: punto de entrada unico
  (`package:lumiere_ui/lumiere_ui.dart`) y `src/` como implementacion.
- `LumiereTokens` con escalas cerradas de espaciado y radios, colores
  semanticos, roles tipograficos y alturas de control.
- `LumiereTheme` como `ThemeExtension` y `LumiereThemeData.dark()` /
  `LumiereThemeData.light()`.
- `LumiereButton` como componente de referencia, con tamanos, variantes, icono
  previo, estado de carga, foco visible y nombre accesible.
- Pruebas de comportamiento y golden de variantes, estados y tamanos.

### Notas

- Los valores de `tokens.g.dart` son **provisionales** y no provienen de Arco:
  Figma no es accesible todavia. Se sustituyen con
  `node tools/generate-tokens.mjs`.
- La API de `LumiereButton` (nombres y numero de variantes) queda marcada como
  provisional hasta confirmar el contrato real del componente en Figma.
