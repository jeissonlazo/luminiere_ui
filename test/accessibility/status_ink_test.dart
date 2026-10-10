// Level-1 accessibility tests for the two decisions of 2026-10-08.
//
// They are separate from contrast_test.dart because they cover the roles that
// were added to satisfy those decisions, and because they assert derived values
// rather than the exported ones:
//
//   AE-08  the light text.3 token is darkened until it reaches 4.5:1, by a
//          declared override in design/variables/overrides.json
//   AE-11  every status family carries a semantic ink for its own subtle
//          background, independent of the decorative fill
//
// Pure arithmetic over the tokens: no widget is involved.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

/// WCAG 2.1 relative luminance of an opaque colour.
double _luminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// Composites [foreground] over [background] when it carries transparency.
Color _over(Color foreground, Color background) {
  if (foreground.a >= 1) {
    return foreground;
  }
  return Color.from(
    alpha: 1,
    red: foreground.r * foreground.a + background.r * (1 - foreground.a),
    green: foreground.g * foreground.a + background.g * (1 - foreground.a),
    blue: foreground.b * foreground.a + background.b * (1 - foreground.a),
  );
}

double _ratio(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  final double hi = math.max(la, lb);
  final double lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

String _hex(Color c) =>
    '#${((c.r * 255).round() << 16 | (c.g * 255).round() << 8 | (c.b * 255).round()).toRadixString(16).padLeft(6, '0').toUpperCase()}';

const double kNormalText = 4.5;

void main() {
  group('AE-11 status inks', () {
    final Map<String, LumiereColors> themes = <String, LumiereColors>{
      'dark': LumiereColors.dark,
      'light': LumiereColors.light,
    };

    test('every family carries an ink for its own subtle background', () {
      for (final MapEntry<String, LumiereColors> theme in themes.entries) {
        for (final LumiereRamp ramp in LumiereRamp.values) {
          final LumiereStatusColors family = theme.value.rampFor(ramp);
          expect(
            family.onSubtle.a,
            greaterThan(0),
            reason: '${theme.key} ${ramp.name}: the ink is fully transparent, '
                'which means nobody set it',
          );
          // The ink may be the same colour as the decorative fill, but only when
          // that colour already reaches the threshold. If it differs, the step
          // was changed because the fill was not usable as an ink.
          if (family.onSubtle != family.normal) {
            final double fillRatio = _ratio(
              _over(family.normal, family.subtle),
              family.subtle,
            );
            expect(
              fillRatio,
              lessThan(kNormalText),
              reason: '${theme.key} ${ramp.name}: the ink moved away from the '
                  'decorative fill even though that fill measures '
                  '${fillRatio.toStringAsFixed(2)}:1 and would have served',
            );
          }
        }
      }
    });

    test('the ink reaches 4.5:1 on its subtle background', () {
      for (final MapEntry<String, LumiereColors> theme in themes.entries) {
        for (final LumiereRamp ramp in LumiereRamp.values) {
          final LumiereStatusColors family = theme.value.rampFor(ramp);
          final Color background = family.subtle;
          final Color ink = _over(family.onSubtle, background);
          final double ratio = _ratio(ink, background);
          expect(
            ratio,
            greaterThanOrEqualTo(kNormalText),
            reason: '${theme.key} ${ramp.name}: the status ink ${_hex(family.onSubtle)} '
                'measures ${ratio.toStringAsFixed(2)}:1 on its subtle background '
                '${_hex(background)}, and section 3.3 of the accessibility '
                'contract requires $kNormalText:1 for normal text',
          );
        }
      }
    });

    test('the ink is the measured step, not an arbitrary one', () {
      // The values the decision records, so a silent change is caught even when
      // the new colour still passes the threshold.
      const Map<String, String> expected = <String, String>{
        'dark accent': '#3C7EFF',
        'light accent': '#165DFF',
        'dark success': '#50D266',
        'light success': '#008026',
        'dark warning': '#FF9626',
        'light warning': '#A64500',
        'dark danger': '#F76965',
        'light danger': '#CB272D',
      };
      for (final MapEntry<String, LumiereColors> theme in themes.entries) {
        for (final LumiereRamp ramp in LumiereRamp.values) {
          final String key = '${theme.key} ${ramp.name}';
          expect(
            _hex(theme.value.rampFor(ramp).onSubtle),
            expected[key],
            reason: 'the ink of $key moved',
          );
        }
      }
    });
  });

  group('AE-08 darkened text.3', () {
    test('the light tertiary text reaches 4.5:1 on every light surface', () {
      final LumiereColors light = LumiereColors.light;
      final List<Color> surfaces = <Color>[
        light.surfaceBase,
        light.surfaceContainer,
        light.surfaceRaised,
        light.surfaceOverlay,
      ];
      for (final Color surface in surfaces) {
        final Color text = _over(light.textTertiary, surface);
        final double ratio = _ratio(text, surface);
        expect(
          ratio,
          greaterThanOrEqualTo(kNormalText),
          reason: 'AE-08: light text.3 ${_hex(light.textTertiary)} measures '
              '${ratio.toStringAsFixed(2)}:1 on ${_hex(surface)}',
        );
      }
    });

    test('the override is the declared value and not the export', () {
      // The design exports #86909C, which measures 3.24:1. The declared override
      // is the midpoint towards text.2: see design/variables/overrides.json.
      expect(
        _hex(LumiereColors.light.textTertiary),
        '#6A7583',
        reason: 'the light text.3 override changed; update overrides.json, this '
            'test and the AE-08 entry together',
      );
    });

    test('darkening text.3 preserved the hierarchy of the scale', () {
      final LumiereColors light = LumiereColors.light;
      final double primary = _ratio(light.textPrimary, light.surfaceBase);
      final double secondary = _ratio(light.textSecondary, light.surfaceBase);
      final double tertiary = _ratio(light.textTertiary, light.surfaceBase);

      expect(primary, greaterThan(secondary));
      expect(secondary, greaterThan(tertiary));
      expect(
        tertiary,
        greaterThanOrEqualTo(kNormalText),
        reason: 'the hierarchy must survive without dropping text.3 below the '
            'threshold again',
      );
    });
  });
}
