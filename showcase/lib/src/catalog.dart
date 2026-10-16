import 'package:flutter/widgets.dart';

import 'pages/button_page.dart';
import 'pages/checkbox_page.dart';
import 'pages/colour_page.dart';
import 'pages/divider_page.dart';
import 'pages/loading_page.dart';
import 'pages/overview_page.dart';
import 'pages/radio_page.dart';
import 'pages/radius_page.dart';
import 'pages/spacing_page.dart';
import 'pages/switch_page.dart';
import 'pages/tag_page.dart';
import 'pages/typography_page.dart';

/// Grouping of the sidebar.
enum DocGroup {
  overview('Overview'),
  foundations('Foundations'),
  components('Components');

  const DocGroup(this.label);

  final String label;
}

/// One page of the gallery.
@immutable
class DocEntry {
  const DocEntry({
    required this.id,
    required this.title,
    required this.group,
    required this.builder,
    this.ruleId,
    this.summary,
  });

  /// Stable identifier, also used as the widget key of the page.
  final String id;

  final String title;
  final DocGroup group;
  final WidgetBuilder builder;

  /// The rule of `docs/constraints/design-constraints.md` the page documents.
  ///
  /// It is shown next to the title so a reader can go from the gallery to the
  /// normative text, which is where the authority lives.
  final String? ruleId;

  /// One line describing the component, used by the cards on the overview.
  final String? summary;
}

/// Every page of the gallery, in sidebar order.
///
/// Adding a component to the package means adding one entry here and one page
/// under `pages/`: the sidebar, the overview cards and the coverage test all
/// read this list, so there is a single place to keep in step.
abstract final class Catalog {
  /// Version of the `lumiere_ui` package this gallery documents.
  ///
  /// `test/catalog_test.dart` reads `../pubspec.yaml` and fails when the two
  /// drift apart, so this cannot silently go stale.
  static const String packageVersion = '0.6.0';

  static const String repositoryUrl =
      'https://github.com/jeissonlazo/luminiere_ui';

  static const String galleryUrl =
      'https://jeissonlazo.github.io/luminiere_ui/';

  static final List<DocEntry> entries = <DocEntry>[
    DocEntry(
      id: 'overview',
      title: 'Overview',
      group: DocGroup.overview,
      builder: (BuildContext context) => const OverviewPage(),
    ),

    // Foundations: the token layers every component reads from.
    DocEntry(
      id: 'colour',
      title: 'Colour',
      group: DocGroup.foundations,
      ruleId: 'DS-COLOR',
      summary: 'The semantic roles, and the status ramps behind them.',
      builder: (BuildContext context) => const ColourPage(),
    ),
    DocEntry(
      id: 'typography',
      title: 'Typography',
      group: DocGroup.foundations,
      ruleId: 'DS-TYPE-001',
      summary: 'Ten sizes, each with the line height the design pairs with it.',
      builder: (BuildContext context) => const TypographyPage(),
    ),
    DocEntry(
      id: 'spacing',
      title: 'Spacing',
      group: DocGroup.foundations,
      ruleId: 'DS-SPACE-001',
      summary: 'The five approved steps, and why one step was replaced.',
      builder: (BuildContext context) => const SpacingPage(),
    ),
    DocEntry(
      id: 'radius',
      title: 'Radius and controls',
      group: DocGroup.foundations,
      ruleId: 'DS-RADIUS-001',
      summary: 'Corner radii, and the measured height and padding per size.',
      builder: (BuildContext context) => const RadiusPage(),
    ),

    // Components, in the order of the design file's rule list.
    DocEntry(
      id: 'button',
      title: 'Button',
      group: DocGroup.components,
      ruleId: 'DS-COMP-001',
      summary: 'Four axes, plus icons, loading and full width.',
      builder: (BuildContext context) => const ButtonPage(),
    ),
    DocEntry(
      id: 'checkbox',
      title: 'Checkbox',
      group: DocGroup.components,
      ruleId: 'DS-COMP-004',
      summary: 'A 14 px box inside a 24 px target, with an indeterminate state.',
      builder: (BuildContext context) => const CheckboxPage(),
    ),
    DocEntry(
      id: 'radio',
      title: 'Radio',
      group: DocGroup.components,
      ruleId: 'DS-COMP-005',
      summary: 'A single radio, and the group that owns the value.',
      builder: (BuildContext context) => const RadioPage(),
    ),
    DocEntry(
      id: 'switch',
      title: 'Switch',
      group: DocGroup.components,
      ruleId: 'DS-COMP-006',
      summary: 'Three track types, two sizes, and a label kept off the fill.',
      builder: (BuildContext context) => const SwitchPage(),
    ),
    DocEntry(
      id: 'loading',
      title: 'Loading',
      group: DocGroup.components,
      ruleId: 'DS-COMP-012',
      summary: 'The single indeterminate indicator. The design declares no axis.',
      builder: (BuildContext context) => const LoadingPage(),
    ),
    DocEntry(
      id: 'tag',
      title: 'Tag',
      group: DocGroup.components,
      ruleId: 'DS-COMP-017',
      summary: 'Eleven colour families across four sizes, with a close action.',
      builder: (BuildContext context) => const TagPage(),
    ),
    DocEntry(
      id: 'divider',
      title: 'Divider',
      group: DocGroup.components,
      ruleId: 'DS-COMP-018',
      summary: 'A hairline separator, with an optional label and alignment.',
      builder: (BuildContext context) => const DividerPage(),
    ),
  ];

  /// The entries of one group, in order.
  static List<DocEntry> inGroup(DocGroup group) => entries
      .where((DocEntry entry) => entry.group == group)
      .toList(growable: false);

  /// The entry with [id]. Throws when it does not exist, which is a wiring bug.
  static DocEntry byId(String id) =>
      entries.firstWhere((DocEntry entry) => entry.id == id);

  /// The components documented, which is what the overview and its test count.
  static List<DocEntry> get componentEntries => inGroup(DocGroup.components);
}
