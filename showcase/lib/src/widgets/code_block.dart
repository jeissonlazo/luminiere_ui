import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';

/// The Dart source of an example.
///
/// It is selectable, and it can be copied in one click, because the point of the
/// gallery is that a reader takes the snippet and uses it.
class CodeBlock extends StatefulWidget {
  const CodeBlock({super.key, required this.code});

  final String code;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) {
      return;
    }
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surfaceBase,
        borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ArcoSpace.spaceMd,
              ArcoSpace.spaceXs,
              ArcoSpace.spaceXs,
              ArcoSpace.spaceXs,
            ),
            child: Row(
              children: <Widget>[
                Text('dart', style: tokens.tertiary(ArcoType.size12)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _copy,
                  icon: Icon(
                    _copied ? LucideIcons.check : LucideIcons.copy,
                    size: 13,
                  ),
                  label: Text(_copied ? 'Copied' : 'Copy'),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        _copied ? colors.success.onSubtle : colors.textTertiary,
                    textStyle: tokens.primary(ArcoType.size12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ArcoSpace.spaceSm,
                      vertical: ArcoSpace.spaceXs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: colors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(ArcoSpace.spaceMd),
            child: SelectableText(
              widget.code,
              style: tokens.mono(ArcoType.size12, color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
