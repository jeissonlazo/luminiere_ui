import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';

/// Vertical rhythm of a documentation page.
const double _sectionGap = ArcoSpace.spaceXl * 2;

/// Container of a documentation page: header, then the sections.
///
/// Every page of the gallery is built from this, so the title, the lead
/// paragraph and the width of the readable column are decided in one place.
class DocPage extends StatelessWidget {
  const DocPage({
    super.key,
    required this.title,
    required this.lead,
    this.ruleId,
    this.header,
    required this.children,
  });

  final String title;

  /// Two or three sentences on what the page documents and where it comes from.
  final String lead;

  /// Rule of the design constraints this page documents, when there is one.
  final String? ruleId;

  /// Extra content under the lead, before the first section.
  final Widget? header;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final bool wide = MediaQuery.sizeOf(context).width >= 920;
    final double horizontal = wide ? ArcoSpace.spaceXl * 2 : ArcoSpace.spaceLg;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontal,
        ArcoSpace.spaceXl,
        horizontal,
        ArcoSpace.spaceXl * 4,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (ruleId != null) ...<Widget>[
                RuleChip(ruleId: ruleId!),
                const SizedBox(height: ArcoSpace.spaceSm),
              ],
              Text(
                title,
                style: tokens.primary(
                  ArcoType.size36,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: ArcoSpace.spaceSm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  lead,
                  style: tokens.secondary(ArcoType.size16),
                ),
              ),
              if (header != null) ...<Widget>[
                const SizedBox(height: ArcoSpace.spaceLg),
                header!,
              ],
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// A titled block inside a page.
class DocSection extends StatelessWidget {
  const DocSection({
    super.key,
    required this.title,
    this.description,
    this.ruleId,
    required this.children,
  });

  final String title;
  final String? description;
  final String? ruleId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: _sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  title,
                  style: tokens.primary(
                    ArcoType.size20,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              if (ruleId != null) ...<Widget>[
                const SizedBox(width: ArcoSpace.spaceSm),
                RuleChip(ruleId: ruleId!, compact: true),
              ],
            ],
          ),
          if (description != null) ...<Widget>[
            const SizedBox(height: ArcoSpace.spaceXs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                description!,
                style: tokens.secondary(ArcoType.size13),
              ),
            ),
          ],
          const SizedBox(height: ArcoSpace.spaceLg),
          ...children,
        ],
      ),
    );
  }
}

/// The identifier of a design or product rule, as a small monospace label.
///
/// The gallery cites rules rather than restating them: the normative text lives
/// in `docs/constraints/design-constraints.md` of the application repository.
class RuleChip extends StatelessWidget {
  const RuleChip({super.key, required this.ruleId, this.compact = false});

  final String ruleId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? ArcoSpace.spaceXs : ArcoSpace.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.fillSubtle,
        borderRadius: BorderRadius.circular(ArcoRadius.radiusSm),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Text(
        ruleId,
        style: tokens.mono(
          compact ? ArcoType.size10 : ArcoType.size12,
          color: colors.textTertiary,
        ),
      ),
    );
  }
}
