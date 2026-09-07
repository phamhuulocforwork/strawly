import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../theme/bento_tokens.dart';

enum BentoTileVariant { neutral, primary, secondary, success, warning, danger }

class BentoTile extends StatelessWidget {
  const BentoTile({
    super.key,
    required this.child,
    this.label,
    this.variant = BentoTileVariant.neutral,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final String? label;
  final BentoTileVariant variant;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  Color _accentColor() {
    switch (variant) {
      case BentoTileVariant.primary:
        return BentoTokens.primary;
      case BentoTileVariant.secondary:
        return BentoTokens.secondary;
      case BentoTileVariant.success:
        return BentoTokens.success;
      case BentoTileVariant.warning:
        return BentoTokens.warning;
      case BentoTileVariant.danger:
        return BentoTokens.danger;
      case BentoTileVariant.neutral:
        return BentoTokens.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final content = isLoading
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(BentoTokens.space24),
              child: CircularProgressIndicator(),
            ),
          )
        : isError
        ? Padding(
            padding: const EdgeInsets.all(BentoTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.error, color: BentoTokens.danger),
                    const SizedBox(width: BentoTokens.space8),
                    Text(
                      AppLocalizations.of(context).somethingWentWrong,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: BentoTokens.danger,
                      ),
                    ),
                  ],
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: BentoTokens.space8),
                  Text(
                    errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BentoTokens.mutedText(context),
                    ),
                  ),
                ],
              ],
            ),
          )
        : Padding(
            padding: padding ?? const EdgeInsets.all(BentoTokens.tilePadding),
            child: child,
          );

    final tile = Semantics(
      label: label,
      container: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: variant == BentoTileVariant.primary
              ? accent.withValues(alpha: 0.35)
              : BentoTokens.tileBackground(context),
          borderRadius: BentoTokens.tileRadius,
          border: Border.all(color: BentoTokens.tileBorder(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );

    if (onTap == null) return tile;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BentoTokens.tileRadius,
        focusColor: accent.withValues(alpha: 0.2),
        hoverColor: accent.withValues(alpha: 0.12),
        splashColor: accent.withValues(alpha: 0.18),
        child: tile,
      ),
    );
  }
}
