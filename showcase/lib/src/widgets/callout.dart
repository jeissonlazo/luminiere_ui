import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';

/// How loud a note is.
enum CalloutTone { info, success, warning, danger }

/// Resolves the ramp a tone reads from.
LumiereStatusColors rampFor(LumiereColors colors, CalloutTone tone) =>
    switch (tone) {
      CalloutTone.info => colors.accent,
      CalloutTone.success => colors.success,
      CalloutTone.warning => colors.warning,
      CalloutTone.danger => colors.danger,
    };

/// A short state label: "implemented", "pending", "no design backing".
///
/// The gallery states what the package does and what it does not, so the same
/// three or four states appear on many pages.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = CalloutTone.info,
  });

  final String label;
  final CalloutTone tone;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereStatusColors ramp = rampFor(tokens.colors, tone);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ArcoSpace.spaceSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: ramp.subtle,
        borderRadius: BorderRadius.circular(ArcoRadius.radiusSm),
      ),
      child: Text(
        label,
        style: tokens.primary(
          ArcoType.size12,
          weight: FontWeight.w500,
          color: ramp.onSubtle,
        ),
      ),
    );
  }
}

/// A note inside a page: a caveat, an accessibility requirement or a pending
/// decision taken from the package's own documentation.
///
/// The gallery documents what the design system does, including the parts that
/// are provisional. Those are the notes a reader has to see, so they are called
/// out instead of being buried in prose.
class Callout extends StatelessWidget {
  const Callout({
    super.key,
    required this.title,
    required this.body,
    this.tone = CalloutTone.info,
  });

  final String title;
  final String body;
  final CalloutTone tone;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    final LumiereStatusColors ramp = rampFor(colors, tone);

    final IconData icon = switch (tone) {
      CalloutTone.info => LucideIcons.info,
      CalloutTone.success => LucideIcons.check,
      CalloutTone.warning => LucideIcons.alertTriangle,
      CalloutTone.danger => LucideIcons.alertTriangle,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ArcoSpace.spaceMd),
      decoration: BoxDecoration(
        color: ramp.subtle,
        borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
        border: Border(left: BorderSide(color: ramp.onSubtle, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: ramp.onSubtle),
          ),
          const SizedBox(width: ArcoSpace.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: tokens.primary(
                    ArcoType.size13,
                    weight: FontWeight.w600,
                    color: ramp.onSubtle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: tokens.secondary(ArcoType.size13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
