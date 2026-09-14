import 'package:flutter/material.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../theme/bento_tokens.dart';

class CycleListTile extends StatelessWidget {
  const CycleListTile({
    super.key,
    required this.cycle,
    required this.locale,
    required this.index,
    required this.total,
    required this.onTap,
    required this.onConfirmDelete,
    required this.onDeleted,
  });

  final Cycle cycle;
  final String locale;
  final int index;
  final int total;
  final VoidCallback onTap;
  final Future<bool> Function() onConfirmDelete;
  final VoidCallback onDeleted;

  BorderRadius get _radius {
    const radius = Radius.circular(BentoTokens.radiusMd);
    final isFirst = index == 0;
    final isLast = index == total - 1;
    return BorderRadius.only(
      topLeft: isFirst ? radius : Radius.zero,
      topRight: isFirst ? radius : Radius.zero,
      bottomLeft: isLast ? radius : Radius.zero,
      bottomRight: isLast ? radius : Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: ValueKey(cycle.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onConfirmDelete(),
      onDismissed: (_) => onDeleted(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(
          horizontal: BentoTokens.tilePadding,
        ),
        color: BentoTokens.danger,
        child: const Icon(AppIcons.delete, color: Colors.white),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: _radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BentoTokens.tilePadding,
              vertical: BentoTokens.space12,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: BentoTokens.primary.withValues(alpha: 0.35),
                  child: Icon(
                    AppIcons.calendar,
                    size: 14,
                    color: BentoTokens.onSurfaceText(context),
                  ),
                ),
                const SizedBox(width: BentoTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateTimeUtils.formatDate(cycle.startDate, locale),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        cycle.isComplete
                            ? l10n.lengthDays(cycle.cycleLength!)
                            : l10n.ongoing,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BentoTokens.mutedText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  AppIcons.chevronRight,
                  size: 20,
                  color: BentoTokens.mutedText(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
