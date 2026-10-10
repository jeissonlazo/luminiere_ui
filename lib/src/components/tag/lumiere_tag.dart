import 'package:flutter/material.dart';

import '../../tokens/lumiere_tokens.dart';
import '../../tokens/tokens.g.dart';

/// Size steps of the tag.
///
/// The heights are measured, not chosen: the design geometry gives 32, 28, 24 and
/// 20 px, with zero variance over 91 variants of each size. They live in
/// [ArcoTag], because component code holds no visual literal.
enum LumiereTagSize { large, medium, small, mini }

/// A tag, chip or label.
///
/// Mirrors the axes of the `Tag` component in the design file (rule `DS-COMP-017`):
/// size, colour, filled, bordered, an optional leading icon and an optional close
/// action.
///
/// The colour names are the design's own and their three colours were measured
/// from the design geometry; see [LumiereTagColorName].
///
/// One axis pairing is an inference from the measurement and is worth confirming:
/// the design gives each colour two backgrounds, and the counts split evenly
/// between the variants with `filled` set and the variants with `bordered` set.
/// This widget reads them as "filled uses the soft background, bordered uses the
/// stronger one, and neither leaves text and icon only".
///
/// The label is normal-size text, so it must reach 4.5:1 against its background.
/// In the light theme the design's step 6 ink does not reach that on every
/// family: the accessibility contract records it as exception `AE-11`, and this
/// widget uses the colours the design declares until the design decides the fix.
class LumiereTag extends StatelessWidget {
  const LumiereTag({
    super.key,
    required this.label,
    this.color = LumiereTagColorName.neutral,
    this.size = LumiereTagSize.small,
    this.filled = true,
    this.bordered = false,
    this.icon,
    this.onClose,
    this.closeSemanticLabel,
  }) : assert(
          onClose == null || closeSemanticLabel != null,
          'A closable tag needs closeSemanticLabel: the package ships no '
          'user-visible string, so the accessible name comes from the caller.',
        );

  /// Text of the tag. It is also its accessible name.
  final String label;

  /// Colour family, as the design names it.
  final LumiereTagColorName color;

  final LumiereTagSize size;

  /// Uses the soft background of the colour family.
  final bool filled;

  /// Uses the stronger background and a border. Read together with [filled].
  final bool bordered;

  /// Decorative icon before the label; hidden from screen readers.
  final Widget? icon;

  /// When set, the tag shows a close action. [closeSemanticLabel] becomes
  /// mandatory, because the design system ships no user-visible string.
  final VoidCallback? onClose;

  /// Accessible name of the close action, in the language of the application.
  final String? closeSemanticLabel;

  double get _height => switch (size) {
        LumiereTagSize.large => ArcoTag.heightLarge,
        LumiereTagSize.medium => ArcoTag.heightMedium,
        LumiereTagSize.small => ArcoTag.heightSmall,
        LumiereTagSize.mini => ArcoTag.heightMini,
      };

  /// Text size per step. The type scale is the design's; which step pairs with
  /// which tag size is pending confirmation, so the pairing stays inside the
  /// declared scale.
  double get _fontSize => switch (size) {
        LumiereTagSize.large || LumiereTagSize.medium => ArcoType.size14,
        LumiereTagSize.small || LumiereTagSize.mini => ArcoType.size12,
      };

  bool get _hasBackground => filled || bordered;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereTagColor roles = tokens.colors.tag(color);
    final Color background = filled ? roles.subtle : roles.strong;
    final double radius = ArcoRadius.radiusSm;

    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: ArcoSpace.spaceSm),
      decoration: BoxDecoration(
        color: _hasBackground ? background : null,
        borderRadius: BorderRadius.circular(radius),
        border: bordered
            ? Border.all(color: tokens.colors.borderDefault)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            ExcludeSemantics(child: icon),
            const SizedBox(width: ArcoSpace.spaceXs),
          ],
          Text(
            label,
            style: tokens.text(size: _fontSize).copyWith(color: roles.ink),
          ),
          if (onClose != null) ...<Widget>[
            const SizedBox(width: ArcoSpace.spaceXs),
            _CloseAction(
              onPressed: onClose!,
              semanticLabel: closeSemanticLabel!,
              color: roles.ink,
              size: _height,
            ),
          ],
        ],
      ),
    );
  }
}

/// Close action of a tag.
///
/// It carries its own accessible name and its own tap target, which is the full
/// height of the tag: an icon-only control identifies itself, and the target is
/// never the size of the glyph.
class _CloseAction extends StatelessWidget {
  const _CloseAction({
    required this.onPressed,
    required this.semanticLabel,
    required this.color,
    required this.size,
  });

  final VoidCallback onPressed;
  final String semanticLabel;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        // Keeps the focus indicator visible, which the accessibility contract
        // requires for every focusable control.
        focusColor: LumiereTokens.of(context).colors.fillStrong,
        child: Icon(Icons.close, size: size * 0.58, color: color),
      ),
    );
  }
}
