import 'package:flutter/material.dart';
import 'package:lumiere_ui/lumiere_ui.dart';

import '../theme/text_styles.dart';

/// A table of text cells: the design axes of a component, or its API.
///
/// Columns are sized by [flex] and cells are plain strings, because both kinds
/// of table the gallery needs are lists of short values. Colour families have
/// their own widget, since a table of swatches is not a table of text.
class DocTable extends StatelessWidget {
  const DocTable({
    super.key,
    required this.columns,
    required this.flex,
    required this.rows,
    this.monoColumns = const <int>{},
  });

  final List<String> columns;

  /// Flex of each column. Use 1 for a narrow column and 3 or 4 for prose.
  final List<int> flex;

  final List<List<String>> rows;

  /// Column indices rendered in the monospace style, for type and default
  /// values, which are code.
  final Set<int> monoColumns;

  @override
  Widget build(BuildContext context) {
    // Checked here rather than in the constructor: a const constructor cannot
    // evaluate `.length` on a const list.
    assert(columns.length == flex.length, 'One flex per column.');

    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(ArcoRadius.radiusMd),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Row(
            cells: columns,
            flex: flex,
            monoColumns: monoColumns,
            header: true,
          ),
          for (final List<String> row in rows) ...<Widget>[
            Container(height: 1, color: colors.borderSubtle),
            _Row(cells: row, flex: flex, monoColumns: monoColumns),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.cells,
    required this.flex,
    required this.monoColumns,
    this.header = false,
  });

  final List<String> cells;
  final List<int> flex;
  final Set<int> monoColumns;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final LumiereTokens tokens = LumiereTokens.of(context);
    final LumiereColors colors = tokens.colors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ArcoSpace.spaceMd,
        vertical: header ? ArcoSpace.spaceSm : ArcoSpace.spaceMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < cells.length; i++)
            Expanded(
              flex: i < flex.length ? flex[i] : 1,
              child: Padding(
                padding: EdgeInsets.only(
                  right: i == cells.length - 1 ? 0 : ArcoSpace.spaceMd,
                ),
                child: cells[i].isEmpty
                    ? const SizedBox.shrink()
                    : Text(
                        cells[i],
                        style: header
                            ? tokens.tertiary(
                                ArcoType.size12,
                                weight: FontWeight.w600,
                              )
                            : monoColumns.contains(i)
                                ? tokens.mono(
                                    ArcoType.size12,
                                    color: colors.textPrimary,
                                  )
                                : tokens.secondary(ArcoType.size13),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
