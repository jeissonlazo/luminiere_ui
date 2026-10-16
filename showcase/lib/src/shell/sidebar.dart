import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../catalog.dart';
import '../theme/text_styles.dart';

/// Navigation of the gallery: one row per page, grouped by nature.
///
/// The rule identifier of the design constraints is shown on the selected row
/// only, so the sidebar stays readable while the link between a page and its
/// normative rule stays one glance away.
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.selectedId,
    required this.onSelect,
    this.onClose,
    this.showFooter = true,
  });

  final String selectedId;
  final ValueChanged<String> onSelect;

  /// Closes the drawer. Null when the sidebar is docked and cannot be closed.
  final VoidCallback? onClose;

  /// The footer repeats the version and the repository, which is redundant in
  /// the drawer where space is scarce.
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Container(
      color: tokens.colors.surfaceContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (onClose != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ArcoSpace.spaceMd,
                ArcoSpace.spaceSm,
                ArcoSpace.spaceSm,
                ArcoSpace.spaceSm,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Navigation',
                    style: tokens.tertiary(ArcoType.size12),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(LucideIcons.x, size: 18),
                    color: tokens.colors.textSecondary,
                    tooltip: 'Close navigation',
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: ArcoSpace.spaceMd),
              children: <Widget>[
                for (final DocGroup group in DocGroup.values) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ArcoSpace.spaceMd,
                      ArcoSpace.spaceMd,
                      ArcoSpace.spaceMd,
                      ArcoSpace.spaceXs,
                    ),
                    child: Text(
                      group.label,
                      style: tokens.tertiary(
                        ArcoType.size12,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                  for (final DocEntry entry in Catalog.inGroup(group))
                    _NavItem(
                      entry: entry,
                      selected: entry.id == selectedId,
                      onTap: () => onSelect(entry.id),
                    ),
                ],
              ],
            ),
          ),
          if (showFooter) _SidebarFooter(),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final DocEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ArcoSpace.spaceMd,
            vertical: ArcoSpace.spaceSm,
          ),
          decoration: BoxDecoration(
            color: selected ? colors.fillSubtle : null,
            border: Border(
              left: BorderSide(
                width: 2,
                color: selected ? colors.accent.normal : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  entry.title,
                  overflow: TextOverflow.ellipsis,
                  style: selected
                      ? tokens.primary(
                          ArcoType.size13,
                          weight: FontWeight.w500,
                          color: colors.accent.normal,
                        )
                      : tokens.secondary(ArcoType.size13),
                ),
              ),
              if (selected && entry.ruleId != null)
                Text(entry.ruleId!, style: tokens.tertiary(ArcoType.size10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);

    return Container(
      padding: const EdgeInsets.all(ArcoSpace.spaceMd),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: tokens.colors.borderSubtle),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SelectableText(
            Catalog.repositoryUrl.replaceFirst('https://', ''),
            style: tokens.tertiary(ArcoType.size12),
          ),
          const SizedBox(height: ArcoSpace.spaceXs),
          Text(
            'MIT licensed. Generated from the package, not from the design file.',
            style: tokens.tertiary(ArcoType.size10),
          ),
        ],
      ),
    );
  }
}
