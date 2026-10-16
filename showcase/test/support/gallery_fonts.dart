import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads real typefaces, so a baseline shows readable text and readable icons.
///
/// `flutter test` rasterises an unknown family with a test face that draws one
/// box per glyph. A baseline like that cannot be reviewed, which defeats the
/// point of keeping one.
///
/// Two families are needed:
///
/// * The family the design declares. `lumiere_ui` sets `Nunito Sans` and
///   deliberately redistributes no typeface, and this environment has no
///   network to fetch one. The Roboto instances that ship inside the Flutter
///   SDK are therefore registered under the declared family name. That makes
///   the layout and the type scale reviewable; it does **not** turn the
///   baseline into a check of Nunito Sans itself.
/// * `Lucide`, the icon family. The gallery receives its icons from the
///   application, and the dependency's own asset is in the test bundle.
/// * `monospace`, which the gallery uses for code and for rule identifiers.
///   The platform resolves it in a browser; the test environment does not, so
///   a real monospace face is registered under that name when one can be
///   found. Without it every code block in the baseline is a row of boxes.
Future<void> loadGalleryFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final ByteData roboto = await _loadDesignFamily();
  await _loadIconFamily();
  await _loadMonospaceFamily(roboto);
}

Future<ByteData> _loadDesignFamily() async {
  final String? root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    debugPrint('loadGalleryFonts: FLUTTER_ROOT is unset; text will be boxes.');
    return ByteData(0);
  }

  final Directory directory = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!directory.existsSync()) {
    debugPrint('loadGalleryFonts: no material_fonts at ${directory.path}.');
    return ByteData(0);
  }

  // Four weights, so a semibold specimen does not fall back to regular.
  const List<String> faces = <String>[
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
  ];

  final FontLoader loader = FontLoader('Nunito Sans');
  ByteData? regular;
  bool loaded = false;
  for (final String face in faces) {
    final File file = File('${directory.path}/$face');
    if (!file.existsSync()) {
      continue;
    }
    final ByteData bytes = ByteData.sublistView(file.readAsBytesSync());
    loader.addFont(Future<ByteData>.value(bytes));
    regular ??= bytes;
    loaded = true;
  }
  if (loaded) {
    await loader.load();
  }
  return regular ?? ByteData(0);
}

/// Candidate monospace faces, by platform. The first one that exists wins.
const List<String> _monospaceCandidates = <String>[
  r'C:\Windows\Fonts\consola.ttf',
  r'C:\Windows\Fonts\cour.ttf',
  '/System/Library/Fonts/Menlo.ttc',
  '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf',
  '/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf',
];

Future<void> _loadMonospaceFamily(ByteData fallback) async {
  ByteData? face;

  for (final String path in _monospaceCandidates) {
    final File file = File(path);
    if (!file.existsSync()) {
      continue;
    }
    face = ByteData.sublistView(file.readAsBytesSync());
    break;
  }

  if (face == null) {
    debugPrint(
      'loadGalleryFonts: no monospace face found; code blocks will fall back '
      'and lose their alignment.',
    );
    if (fallback.lengthInBytes > 0) {
      face = fallback;
    }
  }

  if (face == null) {
    return;
  }

  final FontLoader loader = FontLoader('monospace')
    ..addFont(Future<ByteData>.value(face));
  await loader.load();
}

Future<void> _loadIconFamily() async {
  const String asset = 'packages/lucide_icons_flutter/assets/lucide.ttf';
  try {
    final ByteData data = await rootBundle.load(asset);
    final FontLoader loader = FontLoader('Lucide')
      ..addFont(Future<ByteData>.value(data));
    await loader.load();
  } on Exception catch (error) {
    debugPrint('loadGalleryFonts: could not load $asset ($error).');
  }
}
