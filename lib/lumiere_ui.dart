/// Lumiere design system and component library.
///
/// This package does not know the application: it never imports the editor, the
/// viewport, the domain or `flutter_gpu`. Its only visual input is the token
/// layer, and its only output is widgets.
///
/// Single entry point: applications should import
/// `package:lumiere_ui/lumiere_ui.dart` and nothing else. Everything under
/// `src/` is implementation detail.
library;

export 'src/components/button/lumiere_button.dart';
export 'src/theme/lumiere_theme.dart';
export 'src/tokens/lumiere_tokens.dart';

// Mode-independent scales are safe to expose: they are the same in light and
// dark. The raw colour layers are not exported on purpose, so colours can only
// be reached through the semantic roles in [LumiereColors].
export 'src/tokens/tokens.g.dart'
    show ArcoControl, ArcoRadius, ArcoSpace, ArcoType;
