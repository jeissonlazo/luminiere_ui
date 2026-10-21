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
/// Three families are needed:
///
/// * `Mark Pro`, the family the design system declares. The gallery declares it
///   in `pubspec.yaml` and the faces live in `fonts/MarkPro/`; they are loaded
///   here explicitly anyway, because a baseline that depends on the asset bundle
///   being populated is a baseline that fails for a reason unrelated to the
///   layout it verifies. This loader reads the same files the manifest names, so
///   the test and the application see the same faces - including the weight the
///   family does not have.
/// * `Lucide`, the icon family. The gallery receives its icons from the
///   application, and the dependency's own asset is in the test bundle.
/// * `monospace`, which the gallery uses for code and for rule identifiers.
///   The platform resolves it in a browser; the test environment does not, so a
///   real monospace face is registered under that name when one can be found.
///   Without it every code block in the baseline is a row of boxes.
///
/// A missing face is not fatal: the loader reports it and the baseline degrades
/// to boxes, which a reviewer sees rather than trusting silently.
Future<void> loadGalleryFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final ByteData? markPro = await _loadMarkProFamily();
  await _loadIconFamily();
  await _loadMonospaceFamily(markPro);
}

/// Directory of the faces, relative to the package root that `flutter test`
/// uses as its working directory.
const String _markProDirectory = 'fonts/MarkPro';

/// The family name the manifest declares. It must match `ArcoType.fontFamily`.
const String _markProFamily = 'Mark Pro';

/// The faces the gallery uses, in the same set `pubspec.yaml` declares.
///
/// A curated list rather than a directory scan, because [FontLoader] cannot
/// assign a weight: it registers the bytes and the engine reads the weight from
/// each face's own `OS/2` table, where Book is 450 and the face named Regular is
/// 400. The manifest can only name hundred steps, and it binds 400 to Book - so
/// leaving `MarkPro.otf` out of this list is what makes a `FontWeight.w400`
/// resolve to the same face here as in the application.
///
/// The two paths still differ by one slot at the extremes (the manifest presses
/// ten cuts into nine hundred steps), which the type scale never reaches: it uses
/// 400, 500, 600 and 700, and the first three of those resolve identically here
/// and in the gallery.
const List<String> _markProFaces = <String>[
  'MarkPro-Hairline.otf',
  'MarkPro-HairlineItalic.otf',
  'MarkPro-ExtraLight.otf',
  'MarkPro-ExtraLightItalic.otf',
  'MarkPro-Light.otf',
  'MarkPro-LightItalic.otf',
  'MarkPro-Book.otf',
  'MarkPro-BookItalic.otf',
  'MarkPro-Medium.otf',
  'MarkPro-MediumItalic.otf',
  'MarkPro-Bold.otf',
  'MarkPro-BoldItalic.otf',
  'MarkPro-Heavy.otf',
  'MarkPro-HeavyItalic.otf',
  'MarkPro-Black.otf',
  'MarkPro-BlackItalic.otf',
];

/// Registers the declared faces of the family, and returns the text face for use
/// as a last-resort fallback by the monospace loader.
Future<ByteData?> _loadMarkProFamily() async {
  final Directory directory = Directory(_markProDirectory);
  if (!directory.existsSync()) {
    debugPrint(
      'loadGalleryFonts: no $_markProDirectory; text will be boxes. The family '
      'is licensed and is not redistributed - see showcase/README.md.',
    );
    return null;
  }

  final FontLoader loader = FontLoader(_markProFamily);
  ByteData? fallback;
  int loaded = 0;
  for (final String name in _markProFaces) {
    final File face = File('$_markProDirectory/$name');
    if (!face.existsSync()) {
      debugPrint('loadGalleryFonts: missing face $name.');
      continue;
    }
    final ByteData bytes = ByteData.sublistView(face.readAsBytesSync());
    loader.addFont(Future<ByteData>.value(bytes));
    loaded++;
    // The reading weight is what a missing weight should fall back to.
    if (name == 'MarkPro-Book.otf') {
      fallback = bytes;
    }
  }

  if (loaded == 0) {
    debugPrint('loadGalleryFonts: $_markProDirectory holds none of the faces.');
    return null;
  }
  await loader.load();

  if (fallback == null) {
    debugPrint(
      'loadGalleryFonts: MarkPro-Book.otf is missing, so the monospace fallback '
      'has no face to borrow.',
    );
  }
  return fallback;
}

/// Candidate monospace faces, by platform. The first one that exists wins.
const List<String> _monospaceCandidates = <String>[
  r'C:\Windows\Fonts\consola.ttf',
  r'C:\Windows\Fonts\cour.ttf',
  '/System/Library/Fonts/Menlo.ttc',
  '/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf',
  '/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf',
];

Future<void> _loadMonospaceFamily(ByteData? fallback) async {
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
    face = fallback;
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
