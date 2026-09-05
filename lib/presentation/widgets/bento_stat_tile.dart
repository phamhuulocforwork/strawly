import 'package:flutter/material.dart';
import '../theme/bento_tokens.dart';
import 'bento_tile.dart';

class BentoStatTile extends StatelessWidget {
  const BentoStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.variant = BentoTileVariant.neutral,
  });

  final IconData icon;
  final String label;
  final String value;
  final BentoTileVariant variant;

  @override
  Widget build(BuildContext context) {
    return BentoTile(
      label: label,
      variant: variant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: BentoTokens.onSurfaceText(context)),
          const SizedBox(height: BentoTokens.space12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BentoTokens.mutedText(context),
            ),
          ),
          const SizedBox(height: BentoTokens.space4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: BentoTokens.onSurfaceText(context),
            ),
          ),
        ],
      ),
    );
  }
}
