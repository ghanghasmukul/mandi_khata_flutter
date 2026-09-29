import 'package:flutter/material.dart';
import 'package:mk_ui/src/theme.dart';
import 'package:mk_ui/src/tokens.dart';

/// One column of an [MkDataTable].
class MkColumn<T> {
  const MkColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.numeric = false,
    this.sortKey,
  });

  final String label;
  final Widget Function(T row) cell;
  final int flex;

  /// Right-aligns header and cells (amounts, quantities).
  final bool numeric;

  /// Makes the column sortable by clicking its header.
  final Comparable<Object?> Function(T row)? sortKey;
}

/// Sortable table with a sticky header and no zebra striping.
///
/// Rows are denser on desktop and at least 48 px tall on touch platforms. Given
/// a bounded height, rows scroll lazily beneath the header; otherwise every row
/// is laid out and the table sizes to its content.
class MkDataTable<T> extends StatefulWidget {
  const MkDataTable({
    required this.columns,
    required this.rows,
    super.key,
    this.onRowTap,
    this.initialSortColumn,
    this.initialSortAscending = true,
    this.minWidth = 0,
    this.empty,
  });

  final List<MkColumn<T>> columns;
  final List<T> rows;
  final ValueChanged<T>? onRowTap;
  final int? initialSortColumn;
  final bool initialSortAscending;

  /// Below this width the table scrolls horizontally instead of squeezing.
  final double minWidth;

  /// Shown in place of rows when [rows] is empty.
  final Widget? empty;

  @override
  State<MkDataTable<T>> createState() => _MkDataTableState<T>();
}

class _MkDataTableState<T> extends State<MkDataTable<T>> {
  late int? _sortColumn = widget.initialSortColumn;
  late bool _ascending = widget.initialSortAscending;

  List<T> get _sortedRows {
    final column = _sortColumn;
    final key = column == null ? null : widget.columns[column].sortKey;
    if (key == null) return widget.rows;
    final sorted = [...widget.rows]
      ..sort((a, b) {
        final result = key(a).compareTo(key(b));
        return _ascending ? result : -result;
      });
    return sorted;
  }

  void _sortBy(int column) {
    setState(() {
      if (_sortColumn == column) {
        _ascending = !_ascending;
      } else {
        _sortColumn = column;
        _ascending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final touch = mkIsTouch(context);
    final rowPadding = EdgeInsets.symmetric(
      horizontal: 14,
      vertical: touch ? 12 : 9,
    );
    final rows = _sortedRows;

    final header = DecoratedBox(
      decoration: BoxDecoration(color: tokens.background2),
      child: Row(
        children: [
          for (var i = 0; i < widget.columns.length; i++)
            Expanded(
              flex: widget.columns[i].flex,
              child: _HeaderCell(
                column: widget.columns[i],
                sortedAscending: _sortColumn == i ? _ascending : null,
                onSort: widget.columns[i].sortKey == null
                    ? null
                    : () => _sortBy(i),
              ),
            ),
        ],
      ),
    );

    Widget buildRow(BuildContext context, int index) {
      final row = rows[index];
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.divider)),
        ),
        child: InkWell(
          onTap: widget.onRowTap == null ? null : () => widget.onRowTap!(row),
          hoverColor: tokens.rowHover,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: touch ? 48 : 0),
            child: Row(
              children: [
                for (final column in widget.columns)
                  Expanded(
                    flex: column.flex,
                    child: Padding(
                      padding: rowPadding,
                      child: Align(
                        alignment: column.numeric
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          child: column.cell(row),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final Widget body;
        if (rows.isEmpty) {
          body = widget.empty ?? const SizedBox(height: 48);
        } else if (constraints.hasBoundedHeight) {
          body = ListView.builder(
            itemCount: rows.length,
            itemBuilder: buildRow,
          );
        } else {
          body = Column(
            children: [
              for (var i = 0; i < rows.length; i++) buildRow(context, i),
            ],
          );
        }

        Widget table = Column(
          mainAxisSize: constraints.hasBoundedHeight
              ? MainAxisSize.max
              : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            if (constraints.hasBoundedHeight) Expanded(child: body) else body,
          ],
        );

        if (constraints.maxWidth < widget.minWidth) {
          table = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: widget.minWidth, child: table),
          );
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(MkRadius.lg),
            border: Border.all(color: tokens.border2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(MkRadius.lg),
            child: Material(type: MaterialType.transparency, child: table),
          ),
        );
      },
    );
  }
}

class _HeaderCell<T> extends StatelessWidget {
  const _HeaderCell({
    required this.column,
    required this.sortedAscending,
    required this.onSort,
  });

  final MkColumn<T> column;

  /// `null` when this column is not the sort column.
  final bool? sortedAscending;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context) {
    final tokens = MkTokens.of(context);
    final style = MkText.caps(tokens.textMuted).copyWith(fontSize: 11);
    final label = Text(
      column.label.toUpperCase(),
      style: style,
      overflow: TextOverflow.ellipsis,
    );
    final arrow = sortedAscending == null
        ? null
        : Icon(
            sortedAscending! ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: tokens.textMuted,
          );
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        mainAxisAlignment: column.numeric
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Flexible(child: label),
          if (arrow != null) ...[const SizedBox(width: 4), arrow],
        ],
      ),
    );
    if (onSort == null) return content;
    return Semantics(
      button: true,
      child: InkWell(onTap: onSort, child: content),
    );
  }
}
