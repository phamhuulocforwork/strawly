import 'package:flutter/material.dart';
import '../theme/bento_tokens.dart';

/// Describes one cell in a bento grid layout.
class BentoGridItem {
  const BentoGridItem({
    required this.child,
    this.columnSpan = 1,
    this.minHeight = 120,
  }) : assert(columnSpan == 1 || columnSpan == 2);

  final Widget child;
  final int columnSpan;
  final double minHeight;
}

/// Two-column bento grid with optional single-column fallback on narrow widths.
class BentoGrid extends StatelessWidget {
  const BentoGrid({
    super.key,
    required this.items,
    this.gap = BentoTokens.gridGap,
    this.padding = const EdgeInsets.all(BentoTokens.space16),
  });

  final List<BentoGridItem> items;
  final double gap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = constraints.maxWidth >= 360 ? 2 : 1;
        final rows = _buildRows(items, columnCount);

        return Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) SizedBox(height: gap),
                _BentoRow(items: rows[i], gap: gap, columnCount: columnCount),
              ],
            ],
          ),
        );
      },
    );
  }

  List<List<BentoGridItem>> _buildRows(
    List<BentoGridItem> items,
    int columnCount,
  ) {
    if (columnCount == 1) {
      return items.map((item) => [item]).toList();
    }

    final rows = <List<BentoGridItem>>[];
    var currentRow = <BentoGridItem>[];
    var usedColumns = 0;

    for (final item in items) {
      final span = item.columnSpan.clamp(1, 2);

      if (span == 2) {
        if (currentRow.isNotEmpty) {
          rows.add(currentRow);
          currentRow = [];
          usedColumns = 0;
        }
        rows.add([item]);
        continue;
      }

      if (usedColumns + span > 2) {
        rows.add(currentRow);
        currentRow = [item];
        usedColumns = 1;
      } else {
        currentRow.add(item);
        usedColumns += span;
        if (usedColumns == 2) {
          rows.add(currentRow);
          currentRow = [];
          usedColumns = 0;
        }
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }
}

class _BentoRow extends StatelessWidget {
  const _BentoRow({
    required this.items,
    required this.gap,
    required this.columnCount,
  });

  final List<BentoGridItem> items;
  final double gap;
  final int columnCount;

  @override
  Widget build(BuildContext context) {
    if (items.length == 1 && items.first.columnSpan == 2) {
      return _SizedTile(item: items.first, flex: 2);
    }

    if (columnCount == 1) {
      return _SizedTile(item: items.first, flex: 1);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(child: _SizedTile(item: items[i], flex: 1)),
          ],
          if (items.length == 1) ...[
            SizedBox(width: gap),
            const Expanded(child: SizedBox.shrink()),
          ],
        ],
      ),
    );
  }
}

class _SizedTile extends StatelessWidget {
  const _SizedTile({required this.item, required this.flex});

  final BentoGridItem item;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: item.minHeight),
      child: item.child,
    );
  }
}
