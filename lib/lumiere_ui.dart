/// Sistema de diseno y biblioteca de componentes de Lumiere.
///
/// Este paquete **no conoce la aplicacion**: no importa el editor, el viewport,
/// el dominio ni `flutter_gpu`. Su unica entrada visual son los tokens, y su
/// unica salida son widgets.
///
/// Punto de entrada unico: la aplicacion solo debe importar
/// `package:lumiere_ui/lumiere_ui.dart`. Todo lo demas vive bajo `src/` y no es
/// API publica.
library;

export 'src/components/button/lumiere_button.dart';
export 'src/theme/lumiere_theme.dart';
export 'src/tokens/lumiere_tokens.dart';
// `src/tokens/tokens.g.dart` NO se exporta a proposito: contiene valores
// provisionales y solo debe consumirlos `LumiereTokens`.
