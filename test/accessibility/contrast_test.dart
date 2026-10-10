// Level 1 accessibility test of the token layer: WCAG 2.1 contrast ratios.
//
// Specification: `design/accessibility-contract.md`, sections 1, 3 and 8. That
// document lives with the application; this package holds the tokens it
// constrains.
//
// The test is pure arithmetic over the generated tokens:
//
//  * it resolves transparency first, because `text.*` and `fill.*` are white
//    with an alpha in the dark theme, and it reads that alpha from the token
//    itself, never from a constant;
//  * it computes the WCAG 2.1 contrast ratio of every combination section 3
//    documents, in both themes;
//  * it asserts both the threshold the combination has to reach and the value
//    the contract records for it, so a palette change that moves a colour is
//    caught even when the ratio stays above the threshold.
//
// The exception register of section 8 is encoded, never bypassed. AE-08 and
// AE-11 are open: the test asserts that the combinations they cover still fail
// with their recorded value, so closing them in the palette turns this file red
// and tells us to delete the entry. AE-09 and AE-10 are permanent by design and
// are recorded without a threshold.
//
// The raw token layer is imported white-box because `lib/lumiere_ui.dart`
// publishes the semantic roles, not the colours. That the roles point at these
// primitives is checked by `test/lumiere_button_test.dart`.
//
// No widget test belongs in this file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui/src/tokens/tokens.g.dart';

/// Normal text: section 1 requires 4.5:1.
const double _normalText = 4.5;

/// Large text and graphical information: section 1 requires 3:1.
const double _largeText = 3;

/// Tolerance of the recorded-value check.
///
/// Section 3 recorded its ratios from the design opacities (90, 70, 50 and 30
/// percent), while the generated tokens carry them as an 8-bit alpha (229, 178,
/// 128 and 77). The same combination therefore lands within 0.07 of the
/// recorded value, while a palette change moves a ratio much further.
const double _tolerance = 0.1;

/// Dark tokens, under the names section 3 uses for them.
const Map<String, Color> _darkTokens = <String, Color>{
  'bg.1': ArcoSemanticDark.bg1,
  'bg.2': ArcoSemanticDark.bg2,
  'bg.3': ArcoSemanticDark.bg3,
  'bg.4': ArcoSemanticDark.bg4,
  'bg.5': ArcoSemanticDark.bg5,
  'text.1': ArcoSemanticDark.text1,
  'text.2': ArcoSemanticDark.text2,
  'text.3': ArcoSemanticDark.text3,
  'text.4': ArcoSemanticDark.text4,
  'border.1': ArcoSemanticDark.border1,
  'border.2': ArcoSemanticDark.border2,
  'border.3': ArcoSemanticDark.border3,
  'border.4': ArcoSemanticDark.border4,
  'fill.1': ArcoSemanticDark.fill1,
  'fill.2': ArcoSemanticDark.fill2,
  'fill.3': ArcoSemanticDark.fill3,
  'fill.4': ArcoSemanticDark.fill4,
  'primary.4': ArcoSemanticDark.primary4,
  'danger.6': ArcoSemanticDark.danger6,
  'warning.6': ArcoSemanticDark.warning6,
  'success.6': ArcoSemanticDark.success6,
  // Label colours of section 3.2: white, and the dark ink #1D2129, which is
  // `text.1` in the light theme and is used as a label in both themes.
  'white': ArcoSemanticDark.bgWhite,
  'ink': ArcoSemanticLight.text1,
};

/// Light tokens, under the names section 3 uses for them.
const Map<String, Color> _lightTokens = <String, Color>{
  'bg.1': ArcoSemanticLight.bg1,
  'bg.2': ArcoSemanticLight.bg2,
  'bg.3': ArcoSemanticLight.bg3,
  'bg.4': ArcoSemanticLight.bg4,
  'bg.5': ArcoSemanticLight.bg5,
  'text.1': ArcoSemanticLight.text1,
  'text.2': ArcoSemanticLight.text2,
  'text.3': ArcoSemanticLight.text3,
  'text.4': ArcoSemanticLight.text4,
  'border.1': ArcoSemanticLight.border1,
  'border.2': ArcoSemanticLight.border2,
  'border.3': ArcoSemanticLight.border3,
  'border.4': ArcoSemanticLight.border4,
  'fill.1': ArcoSemanticLight.fill1,
  'fill.2': ArcoSemanticLight.fill2,
  'fill.3': ArcoSemanticLight.fill3,
  'fill.4': ArcoSemanticLight.fill4,
  'primary.6': ArcoSemanticLight.primary6,
  'danger.6': ArcoSemanticLight.danger6,
  'danger.7': ArcoSemanticLight.danger7,
  'success.1': ArcoSemanticLight.success1,
  'success.6': ArcoSemanticLight.success6,
  'warning.1': ArcoSemanticLight.warning1,
  'warning.6': ArcoSemanticLight.warning6,
  'danger.1': ArcoSemanticLight.danger1,
  'white': ArcoSemanticLight.bgWhite,
  'ink': ArcoSemanticLight.text1,
};

/// The requirement a group of combinations shares.
@immutable
class _Rule {
  const _Rule(this.section, {this.required, this.register});

  /// Section of the accessibility contract that documents the combination.
  final String section;

  /// Minimum ratio the combination has to reach; null when the contract only
  /// records the value.
  final double? required;

  /// Identifier in the section 8 register, when the combination is covered by
  /// an exception; null for the combinations that are simply required.
  final String? register;
}

const _Rule _pageText = _Rule('3.1', required: _normalText);
const _Rule _containerText = _Rule('3.1', required: _normalText);
const _Rule _solidLabel = _Rule('3.2', required: _normalText);
const _Rule _overlayText = _Rule('3.2', required: _normalText);
const _Rule _graphicIndicator = _Rule('3.4', required: _largeText);
const _Rule _separator = _Rule('3.4', register: 'AE-10');
const _Rule _text3Open = _Rule('3.1', required: _normalText, register: 'AE-08');
const _Rule _text4Recorded = _Rule('3.1', register: 'AE-09');
const _Rule _statusOpen = _Rule(
  '3.3',
  required: _normalText,
  register: 'AE-11',
);

/// One combination the contract documents.
@immutable
class _Pair {
  const _Pair({
    required this.theme,
    required this.foregroundName,
    required this.foreground,
    required this.backgroundName,
    required this.background,
    required this.section,
    required this.recorded,
    this.required,
    this.register,
  });

  /// `dark` or `light`.
  final String theme;

  /// Token name of the foreground, as section 3 writes it, for example `text.3`.
  final String foregroundName;
  final Color foreground;

  /// Token name of the background, as section 3 writes it, for example `bg.1`.
  final String backgroundName;
  final Color background;

  /// Section that documents the combination.
  final String section;

  /// Ratio the contract records for the combination, to two decimals.
  final double recorded;

  /// Minimum ratio the combination has to reach; null when the contract only
  /// records the value.
  final double? required;

  /// Section 8 entry that covers the combination, when there is one.
  final String? register;

  /// Stable identifier, used by the register and by every failure message.
  String get id => '$theme $foregroundName on $backgroundName';
}

/// A combination of the dark theme, named as section 3 names it.
_Pair _dark(
  String foreground,
  String background,
  double recorded,
  _Rule rule,
) => _documented(_darkTokens, 'dark', foreground, background, recorded, rule);

/// A combination of the light theme, named as section 3 names it.
_Pair _light(
  String foreground,
  String background,
  double recorded,
  _Rule rule,
) => _documented(_lightTokens, 'light', foreground, background, recorded, rule);

_Pair _documented(
  Map<String, Color> tokens,
  String theme,
  String foreground,
  String background,
  double recorded,
  _Rule rule,
) => _Pair(
  theme: theme,
  foregroundName: foreground,
  foreground: _token(tokens, foreground),
  backgroundName: background,
  background: _token(tokens, background),
  section: rule.section,
  recorded: recorded,
  required: rule.required,
  register: rule.register,
);

/// Every combination section 3 documents, with the value it records.
///
/// The recorded values are the ones section 3 publishes. Where the contract
/// publishes a range instead of a single value (the containers and the neutral
/// overlays), the value below is the one the generated tokens measure, so a
/// change to any of those tokens is still caught.
final List<_Pair> _pairs = <_Pair>[
  // Section 3.1: the text hierarchy on the page background. text.4 is never
  // informational, which AE-09 records at the end of this file.
  _dark('text.1', 'bg.1', 14.58, _pageText),
  _dark('text.2', 'bg.1', 9.16, _pageText),
  _dark('text.3', 'bg.1', 5.26, _pageText),
  _dark('text.4', 'bg.1', 2.71, _text4Recorded),
  _light('text.1', 'bg.1', 16.13, _pageText),
  _light('text.2', 'bg.1', 7.10, _pageText),
  _light('text.3', 'bg.1', 3.24, _text3Open),
  _light('text.4', 'bg.1', 1.59, _text4Recorded),

  // Section 3.1: the container backgrounds. The contract records text.1 and
  // text.2 on them. text.3 is not approved there in the dark theme (it drops to
  // 4.30 on bg.5), and the light containers are the white of bg.1, measured
  // again so that a change to a container token cannot pass unnoticed.
  _dark('text.1', 'bg.2', 12.88, _containerText),
  _dark('text.1', 'bg.3', 11.84, _containerText),
  _dark('text.1', 'bg.4', 10.80, _containerText),
  _dark('text.1', 'bg.5', 9.93, _containerText),
  _dark('text.2', 'bg.2', 8.32, _containerText),
  _dark('text.2', 'bg.3', 7.77, _containerText),
  _dark('text.2', 'bg.4', 7.20, _containerText),
  _dark('text.2', 'bg.5', 6.71, _containerText),
  _light('text.1', 'bg.2', 16.13, _containerText),
  _light('text.1', 'bg.3', 16.13, _containerText),
  _light('text.1', 'bg.4', 16.13, _containerText),
  _light('text.1', 'bg.5', 16.13, _containerText),
  _light('text.2', 'bg.2', 7.10, _containerText),
  _light('text.2', 'bg.3', 7.10, _containerText),
  _light('text.2', 'bg.4', 7.10, _containerText),
  _light('text.2', 'bg.5', 7.10, _containerText),

  // Section 3.2: a solid fill and the one label colour it may carry. The pairs
  // the component closes (white on primary.6 in the dark theme, white on
  // danger.6 and on the status steps in the light theme, and so on) are not
  // documented as usable, so they are not part of this table.
  _dark('white', 'primary.4', 6.90, _solidLabel),
  _dark('ink', 'danger.6', 5.50, _solidLabel),
  _dark('ink', 'warning.6', 7.41, _solidLabel),
  _dark('ink', 'success.6', 6.90, _solidLabel),
  _light('white', 'primary.6', 5.19, _solidLabel),
  _light('ink', 'warning.6', 6.29, _solidLabel),
  _light('ink', 'success.6', 5.81, _solidLabel),
  _light('white', 'danger.7', 5.43, _solidLabel),

  // Section 3.2: hover and pressed states are validated separately. The
  // semantic layer documents fill.1 to fill.4 as the overlays of a neutral
  // surface (white with an alpha in the dark theme, opaque neutrals in the
  // light theme), so the informational text on them is measured with the
  // overlay composited over the page background.
  _dark('text.1', 'fill.1', 13.28, _overlayText),
  _dark('text.1', 'fill.2', 11.94, _overlayText),
  _dark('text.1', 'fill.3', 10.46, _overlayText),
  _dark('text.1', 'fill.4', 9.20, _overlayText),
  _light('text.1', 'fill.1', 15.18, _overlayText),
  _light('text.1', 'fill.2', 14.53, _overlayText),
  _light('text.1', 'fill.3', 12.94, _overlayText),
  _light('text.1', 'fill.4', 10.11, _overlayText),

  // Section 3.4: a boundary that identifies a control reaches 3:1. border.4 is
  // that boundary, measured on every background a control can sit on, because
  // the contract requires the effective combination to be measured.
  _dark('border.4', 'bg.1', 5.75, _graphicIndicator),
  _dark('border.4', 'bg.2', 5.05, _graphicIndicator),
  _dark('border.4', 'bg.3', 4.61, _graphicIndicator),
  _dark('border.4', 'bg.4', 4.18, _graphicIndicator),
  _dark('border.4', 'bg.5', 3.82, _graphicIndicator),
  _light('border.4', 'bg.1', 3.24, _graphicIndicator),

  // Section 3.4: border.1 to border.3 are separators. AE-10 records them and
  // this table never asserts 3:1 for them.
  _dark('border.1', 'bg.1', 1.32, _separator),
  _dark('border.2', 'bg.1', 1.96, _separator),
  _dark('border.3', 'bg.1', 2.80, _separator),
  _light('border.1', 'bg.1', 1.11, _separator),
  _light('border.2', 'bg.1', 1.25, _separator),
  _light('border.3', 'bg.1', 1.59, _separator),

  // Section 3.3: the status inks on their own subtle background. AE-11 records
  // the light failures at step 6.
  _light('success.6', 'success.1', 2.63, _statusOpen),
  _light('warning.6', 'warning.1', 2.41, _statusOpen),
  _light('danger.6', 'danger.1', 3.25, _statusOpen),
];

/// One entry of the section 8 exception register.
@immutable
class _RegisteredException {
  const _RegisteredException({
    required this.id,
    required this.lowest,
    required this.highest,
    required this.reason,
    required this.open,
    required this.combinations,
  });

  /// Identifier in section 8, for example `AE-08`.
  final String id;

  /// Lowest and highest value the register records for the entry.
  final double lowest;
  final double highest;

  /// One line saying what the entry is and why it exists.
  final String reason;

  /// True while the design has not closed the exception: the combinations it
  /// covers must still fail, and fixing them has to fail this test.
  final bool open;

  /// Identifiers of the combinations the entry covers.
  final List<String> combinations;
}

/// Section 8, as the level 1 test has to encode it.
const List<_RegisteredException> _exceptions = <_RegisteredException>[
  _RegisteredException(
    id: 'AE-08',
    lowest: 3.24,
    highest: 3.24,
    reason:
        'Open, needs design: in the light theme text.3 reaches only 3.24 on '
        'the page background, so it is allowed at 24px and above until the '
        'tone is darkened.',
    open: true,
    combinations: <String>['light text.3 on bg.1'],
  ),
  _RegisteredException(
    id: 'AE-11',
    lowest: 2.41,
    highest: 3.25,
    reason:
        'Open, needs design: in the light theme the status inks at step 6 '
        'measure 2.41 to 3.25 on their own subtle background, so an '
        'informational tag uses step 7.',
    open: true,
    combinations: <String>[
      'light success.6 on success.1',
      'light warning.6 on warning.1',
      'light danger.6 on danger.1',
    ],
  ),
  _RegisteredException(
    id: 'AE-09',
    lowest: 1.59,
    highest: 2.71,
    reason:
        'Permanent by design: text.4 is decorative and disabled only, never '
        'informational, so no threshold is asserted for it.',
    open: false,
    combinations: <String>['dark text.4 on bg.1', 'light text.4 on bg.1'],
  ),
  _RegisteredException(
    id: 'AE-10',
    lowest: 1.11,
    highest: 2.80,
    reason:
        'Permanent by design: border.1 to border.3 are separators; a '
        'boundary that identifies a control uses border.4.',
    open: false,
    combinations: <String>[
      'dark border.1 on bg.1',
      'dark border.2 on bg.1',
      'dark border.3 on bg.1',
      'light border.1 on bg.1',
      'light border.2 on bg.1',
      'light border.3 on bg.1',
    ],
  ),
];

void main() {
  group('contrast of the documented token combinations', () {
    test('the table is well formed', () {
      final Set<String> ids = <String>{};
      for (final _Pair pair in _pairs) {
        expect(
          ids.add(pair.id),
          isTrue,
          reason:
              '${pair.id} appears twice in the table; the register looks '
              'combinations up by id, so the ids must be unique.',
        );
        expect(
          pair.section,
          isNotEmpty,
          reason: '${pair.id} does not name the section that documents it.',
        );
        expect(
          pair.required != null || pair.register != null,
          isTrue,
          reason:
              '${pair.id} has neither a threshold nor a register entry: a '
              'combination that is only recorded must name the exception that '
              'keeps it out of the thresholds.',
        );
      }
      expect(
        _pairs.map((_Pair pair) => pair.theme).toSet(),
        <String>{'dark', 'light'},
        reason: 'the contract applies to both themes, so both must be covered.',
      );
    });

    test('every combination the contract requires reaches its threshold', () {
      for (final _Pair pair in _pairs) {
        final double? required = pair.required;
        if (required == null || pair.register != null) {
          continue;
        }
        final double measured = _contrast(pair);
        expect(
          measured,
          greaterThanOrEqualTo(required),
          reason:
              '${pair.id} fails: ${_measured(measured)} measured, '
              '${required.toStringAsFixed(1)}:1 required by section '
              '${pair.section} for ${pair.foregroundName} in the ${pair.theme} '
              'theme. Fix the token, or register the exception in section 8 '
              'and declare it in this test.',
        );
      }
    });

    test('every combination keeps the ratio the contract records', () {
      for (final _Pair pair in _pairs) {
        final double measured = _contrast(pair);
        expect(
          measured,
          closeTo(pair.recorded, _tolerance),
          reason:
              '${pair.id} no longer matches the contract: '
              '${_measured(measured)} measured, ${_measured(pair.recorded)} '
              'recorded by section ${pair.section} for ${pair.foregroundName} '
              'on ${pair.backgroundName} in the ${pair.theme} theme. If the '
              'palette moved on purpose, update the contract and this table '
              'together.',
        );
      }
    });

    test('no combination outside the register is failing', () {
      final List<String> unexpected = <String>[];
      for (final _Pair pair in _pairs) {
        final double? required = pair.required;
        if (required == null || pair.register != null) {
          continue;
        }
        final double measured = _contrast(pair);
        if (measured < required) {
          unexpected.add(
            '  ${pair.id}: ${_measured(measured)} measured, '
            '${required.toStringAsFixed(1)}:1 required by section '
            '${pair.section}',
          );
        }
      }
      expect(
        unexpected,
        isEmpty,
        reason:
            'Documented combinations are failing without a declared entry '
            'in section 8, so a new failure is hiding here:\n'
            '${unexpected.join('\n')}',
      );
    });

    test('the dark containers stay inside the range section 3.1 records', () {
      // Section 3.1: on the four container backgrounds in the dark theme,
      // text.1 stays between 9.96 and 14.58 and text.2 between 6.74 and 9.16.
      const List<(String, double, double)> ranges = <(String, double, double)>[
        ('text.1', 9.96, 14.58),
        ('text.2', 6.74, 9.16),
      ];
      for (final (String token, double lowest, double highest) in ranges) {
        final List<double> measured = <double>[
          for (final _Pair pair in _pairs)
            if (pair.theme == 'dark' &&
                pair.foregroundName == token &&
                pair.backgroundName.startsWith('bg.'))
              _contrast(pair),
        ];
        expect(
          measured,
          hasLength(5),
          reason: 'dark $token must be measured on bg.1 to bg.5.',
        );
        final double floor = measured.reduce(
          (double a, double b) => math.min(a, b),
        );
        final double ceiling = measured.reduce(
          (double a, double b) => math.max(a, b),
        );
        expect(
          floor,
          greaterThanOrEqualTo(lowest - _tolerance),
          reason:
              'dark $token falls under the range section 3.1 records: '
              '${_measured(floor)} measured, ${_measured(lowest)} is the '
              'recorded floor.',
        );
        expect(
          ceiling,
          lessThanOrEqualTo(highest + _tolerance),
          reason:
              'dark $token rises above the range section 3.1 records: '
              '${_measured(ceiling)} measured, ${_measured(highest)} is the '
              'recorded ceiling.',
        );
      }
    });
  });

  group('section 8 exception register', () {
    test('the register and the table cover the same combinations', () {
      final Set<String> covered = <String>{};
      for (final _RegisteredException exception in _exceptions) {
        expect(
          exception.combinations,
          isNotEmpty,
          reason: '${exception.id} covers no combination.',
        );
        for (final String id in exception.combinations) {
          final _Pair pair = _pairById(id);
          expect(
            pair.register,
            exception.id,
            reason:
                '$id is listed under ${exception.id} in the register, but '
                'its row names ${pair.register}.',
          );
          covered.add(id);
        }
      }
      for (final _Pair pair in _pairs) {
        if (pair.register == null) {
          continue;
        }
        expect(
          covered,
          contains(pair.id),
          reason:
              '${pair.id} names ${pair.register}, but the register does not '
              'list it.',
        );
      }
    });

    test('each register entry records the values of its combinations', () {
      for (final _RegisteredException exception in _exceptions) {
        expect(
          exception.reason,
          isNotEmpty,
          reason: '${exception.id} needs a reason in the register.',
        );
        expect(
          exception.reason,
          exception.open ? startsWith('Open') : startsWith('Permanent'),
          reason:
              '${exception.id} must say whether it is open or permanent by '
              'design, as section 8 does.',
        );
        for (final String id in exception.combinations) {
          final double recorded = _pairById(id).recorded;
          expect(
            recorded,
            inInclusiveRange(
              exception.lowest - _tolerance,
              exception.highest + _tolerance,
            ),
            reason:
                '${exception.id} records '
                '${_measured(exception.lowest)} to '
                '${_measured(exception.highest)}, but $id records '
                '${_measured(recorded)} in the table.',
          );
        }
      }
    });

    test('the open exceptions are still failing with their recorded value', () {
      for (final _RegisteredException exception in _exceptions.where(
        (_RegisteredException entry) => entry.open,
      )) {
        for (final String id in exception.combinations) {
          final _Pair pair = _pairById(id);
          final double? required = pair.required;
          final double measured = _contrast(pair);
          expect(
            required,
            isNotNull,
            reason:
                '${exception.id} is open, so $id must still declare the '
                'threshold it fails.',
          );
          expect(
            measured,
            lessThan(required!),
            reason:
                '${exception.id} is open in section 8, so ${pair.id} must '
                'still fail ${required.toStringAsFixed(1)}:1, but the tokens '
                'now measure ${_measured(measured)} for '
                '${pair.foregroundName} on ${pair.backgroundName} in the '
                '${pair.theme} theme. The design closed the exception: remove '
                'it from section 8 and from this test.',
          );
          expect(
            measured,
            closeTo(pair.recorded, _tolerance),
            reason:
                '${exception.id} records ${_measured(pair.recorded)} for '
                '${pair.id}, but the tokens now measure ${_measured(measured)}.',
          );
        }
      }
    });

    test('the permanent exceptions are recorded, never asserted', () {
      for (final _RegisteredException exception in _exceptions.where(
        (_RegisteredException entry) => !entry.open,
      )) {
        for (final String id in exception.combinations) {
          final _Pair pair = _pairById(id);
          expect(
            pair.required,
            isNull,
            reason:
                '${exception.id} is permanent by design, so ${pair.id} '
                'has to stay recorded only: remove the threshold or close the '
                'entry in section 8.',
          );
        }
      }
    });
  });
}

/// Flattens [token] over [background].
///
/// `text.*` and `fill.*` carry an alpha in the dark theme, so the colour that
/// reaches the eye is the composite. The alpha is read from the token itself.
Color _composite(Color token, Color background) {
  final double alpha = token.a;
  if (alpha >= 1) {
    return token;
  }
  return Color.from(
    alpha: 1,
    red: token.r * alpha + background.r * (1 - alpha),
    green: token.g * alpha + background.g * (1 - alpha),
    blue: token.b * alpha + background.b * (1 - alpha),
  );
}

/// One channel of the WCAG 2.1 relative luminance formula.
double _channel(double value) => value <= 0.03928
    ? value / 12.92
    : math.pow((value + 0.055) / 1.055, 2.4).toDouble();

/// Relative luminance of an opaque colour.
double _luminance(Color color) =>
    0.2126 * _channel(color.r) +
    0.7152 * _channel(color.g) +
    0.0722 * _channel(color.b);

/// WCAG 2.1 contrast ratio of two opaque colours.
double _ratio(Color first, Color second) {
  final double a = _luminance(first);
  final double b = _luminance(second);
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

/// Page background of a theme: the surface every measurement starts from.
Color _page(String theme) =>
    _token(theme == 'dark' ? _darkTokens : _lightTokens, 'bg.1');

/// Ratio of a documented combination, transparency resolved first.
double _contrast(_Pair pair) {
  final Color surface = _composite(pair.background, _page(pair.theme));
  return _ratio(_composite(pair.foreground, surface), surface);
}

/// Looks a token up by the name section 3 uses, failing loudly on a typo.
Color _token(Map<String, Color> tokens, String name) {
  final Color? color = tokens[name];
  if (color == null) {
    fail(
      'The token "$name" is not in the table of this test. Add it, or fix the '
      'name so it matches the contract.',
    );
  }
  return color;
}

/// Finds a documented combination by id, failing with a readable message.
_Pair _pairById(String id) {
  for (final _Pair pair in _pairs) {
    if (pair.id == id) {
      return pair;
    }
  }
  fail(
    'No documented combination has the id "$id". Fix the id in the exception '
    'register of this test, or add the combination to the table.',
  );
}

/// A ratio as it is written in a failure message.
String _measured(double ratio) => '${ratio.toStringAsFixed(2)}:1';
