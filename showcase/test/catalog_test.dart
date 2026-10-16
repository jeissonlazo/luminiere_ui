import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiere_ui_showcase/src/catalog.dart';

/// Where the package's own `pubspec.yaml` lives.
///
/// Two layouts are supported, and both are real:
///
/// * `luminiere_ui/showcase/` - this gallery inside the package repository,
///   which is how it is published.
/// * a `showcase/` checkout beside a `luminiere_ui/` checkout, which is how it
///   is developed.
List<File> _packagePubspecCandidates() => <File>[
      File('../pubspec.yaml'),
      File('../../luminiere_ui/pubspec.yaml'),
    ];

void main() {
  group('catalog', () {
    test('page identifiers are unique', () {
      final Set<String> seen = <String>{};
      for (final DocEntry entry in Catalog.entries) {
        expect(
          seen.add(entry.id),
          isTrue,
          reason: 'duplicate page id: ${entry.id}',
        );
      }
    });

    test('every group has at least one page', () {
      for (final DocGroup group in DocGroup.values) {
        expect(
          Catalog.inGroup(group),
          isNotEmpty,
          reason: 'no page in group ${group.name}',
        );
      }
    });

    test('every component page cites a rule and carries a summary', () {
      for (final DocEntry entry in Catalog.componentEntries) {
        expect(entry.ruleId, isNotNull, reason: '${entry.id} cites no rule');
        expect(entry.summary, isNotNull, reason: '${entry.id} has no summary');
      }
    });

    test('every entry resolves by id', () {
      for (final DocEntry entry in Catalog.entries) {
        expect(Catalog.byId(entry.id), same(entry));
      }
    });

    test('the documented version matches the package pubspec', () {
      File? pubspec;
      for (final File candidate in _packagePubspecCandidates()) {
        if (candidate.existsSync()) {
          pubspec = candidate;
          break;
        }
      }

      expect(
        pubspec,
        isNotNull,
        reason: 'The package pubspec.yaml was not found. Run this suite from '
            'inside the package repository (luminiere_ui/showcase), or from a '
            'showcase checkout that sits beside a luminiere_ui checkout.',
      );

      final RegExp pattern = RegExp(r'^version:\s*(\S+)\s*$', multiLine: true);
      final RegExpMatch? match =
          pattern.firstMatch(pubspec!.readAsStringSync());

      expect(match, isNotNull, reason: 'no version line in ${pubspec.path}');
      expect(
        Catalog.packageVersion,
        match!.group(1),
        reason: 'The gallery advertises ${Catalog.packageVersion} but '
            '${pubspec.path} declares ${match.group(1)}. Update '
            'Catalog.packageVersion.',
      );
    });
  });
}
