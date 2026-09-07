import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_time_utils.dart';
import '../../domain/entities/cycle.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_icons.dart';
import '../theme/bento_tokens.dart';
import '../viewmodels/cycle_viewmodel.dart';
import 'cycle_calendar_logic.dart';

class PredictionCardWidget extends ConsumerStatefulWidget {
  const PredictionCardWidget({
    super.key,
    this.predictedDate,
    this.cycles = const [],
    this.averageCycleLength = AppConstants.defaultCycleLength,
    this.onCurrentCycleTap,
  });

  final DateTime? predictedDate;
  final List<Cycle> cycles;
  final int averageCycleLength;
  final VoidCallback? onCurrentCycleTap;

  @override
  ConsumerState<PredictionCardWidget> createState() =>
      _PredictionCardWidgetState();
}

class _PredictionCardWidgetState extends ConsumerState<PredictionCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _daysAnimation;

  bool _loggedToday = false;
  bool _isLogging = false;
  double _buttonScale = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _setupAnimations();
    _loggedToday = _hasCycleToday(widget.cycles);
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(PredictionCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loggedToday = _hasCycleToday(widget.cycles);
    if (oldWidget.predictedDate != widget.predictedDate ||
        oldWidget.averageCycleLength != widget.averageCycleLength) {
      _setupAnimations();
      _controller.forward(from: 0);
    }
  }

  void _setupAnimations() {
    final daysUntil = _rawDaysUntil();
    final maxCycle = widget.averageCycleLength.clamp(
      AppConstants.minCycleLength,
      AppConstants.maxCycleLength,
    );
    final targetProgress = daysUntil <= 0
        ? 1.0
        : (daysUntil / maxCycle).clamp(0.0, 1.0);
    final displayDays = daysUntil <= 0 ? 0 : daysUntil;

    _progressAnimation = Tween<double>(
      begin: 0,
      end: targetProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _daysAnimation = Tween<double>(
      begin: 0,
      end: displayDays.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  int _rawDaysUntil() {
    if (widget.predictedDate == null) return 0;
    return DateTimeUtils.daysBetween(DateTime.now(), widget.predictedDate!);
  }

  bool _hasCycleToday(List<Cycle> cycles) {
    final today = DateTimeUtils.dateOnly(DateTime.now());
    return cycles.any(
      (cycle) => DateTimeUtils.isSameDay(cycle.startDate, today),
    );
  }

  String _phaseLabel(CyclePhase? phase, AppLocalizations l10n) {
    return switch (phase) {
      CyclePhase.period => l10n.phasePeriod,
      CyclePhase.follicular => l10n.phaseFollicular,
      CyclePhase.fertile => l10n.phaseFertile,
      CyclePhase.luteal => l10n.phaseLuteal,
      null => l10n.phaseFollicular,
    };
  }

  Future<void> _onLogPeriod(AppLocalizations l10n) async {
    if (_isLogging || _loggedToday) return;

    setState(() => _buttonScale = 0.96);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    setState(() => _buttonScale = 1);

    setState(() => _isLogging = true);

    try {
      final now = DateTime.now();
      final cycle = Cycle(
        id: now.millisecondsSinceEpoch.toString(),
        startDate: DateTimeUtils.dateOnly(now),
        periodDuration: AppConstants.periodDuration,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(cycleListProvider.notifier).addCycle(cycle);
      ref.invalidate(predictedNextCycleDateProvider);
      ref.invalidate(cycleStatisticsProvider);

      if (!mounted) return;
      setState(() => _loggedToday = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.periodLoggedSuccess),
          backgroundColor: BentoTokens.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: BentoTokens.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final phase = CycleCalendarLogic.currentPhase(cycles: widget.cycles);

    if (widget.predictedDate == null) {
      return _PredictionCardShell(
        loggedToday: _loggedToday,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.noPredictionYet,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: BentoTokens.space4),
            Text(
              l10n.addMoreCyclesForPrediction,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BentoTokens.mutedText(context),
              ),
            ),
            if (!_loggedToday) ...[
              const SizedBox(height: BentoTokens.space16),
              _LogPeriodButton(
                label: l10n.logPeriodToday,
                loading: _isLogging,
                scale: _buttonScale,
                onPressed: () => _onLogPeriod(l10n),
              ),
            ],
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _PredictionCardShell(
          loggedToday: _loggedToday,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _CountdownRing(
                    progress: _progressAnimation.value,
                    days: _daysAnimation.value.round(),
                    daysLabel: l10n.daysLabel,
                    onTap: widget.onCurrentCycleTap,
                  ),
                  const SizedBox(width: BentoTokens.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.predictedNextPeriod,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: BentoTokens.mutedText(context),
                                fontSize: BentoTokens.font14,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateTimeUtils.formatDate(
                            widget.predictedDate!,
                            locale,
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: BentoTokens.space8),
                        _PhaseBadge(
                          phase: phase,
                          label: _phaseLabel(phase, l10n),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: BentoTokens.space8),
                  _PhaseSticker(
                    phase: phase,
                    semanticLabel: _phaseLabel(phase, l10n),
                  ),
                ],
              ),
              if (!_loggedToday) ...[
                const SizedBox(height: BentoTokens.space12),
                _LogPeriodButton(
                  label: l10n.logPeriodToday,
                  loading: _isLogging,
                  scale: _buttonScale,
                  onPressed: () => _onLogPeriod(l10n),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PredictionCardShell extends StatelessWidget {
  const _PredictionCardShell({required this.child, required this.loggedToday});

  final Widget child;
  final bool loggedToday;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(BentoTokens.space16),
      decoration: BoxDecoration(
        color: BentoTokens.tileBackground(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: loggedToday ? primary : BentoTokens.tileBorder(context),
          width: loggedToday ? 1.5 : 0.5,
        ),
      ),
      child: child,
    );
  }
}

class _CountdownRing extends StatelessWidget {
  const _CountdownRing({
    required this.progress,
    required this.days,
    required this.daysLabel,
    this.onTap,
  });

  final double progress;
  final int days;
  final String daysLabel;
  final VoidCallback? onTap;

  static const _size = 88.0;
  static const _stroke = 7.0;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final ring = SizedBox(
      key: const Key('prediction-countdown-ring'),
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(_size, _size),
            painter: _RingPainter(
              progress: progress,
              trackColor: BentoTokens.tileBorder(context),
              progressColor: primary,
              strokeWidth: _stroke,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$days',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
              Text(
                daysLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: BentoTokens.mutedText(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return ring;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: ring,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

class _PhaseSticker extends StatelessWidget {
  const _PhaseSticker({required this.phase, required this.semanticLabel});

  final CyclePhase? phase;
  final String semanticLabel;

  static const _size = 72.0;

  static String? _assetForPhase(CyclePhase? phase) {
    return switch (phase) {
      CyclePhase.period => 'assets/images/stickers/period.png',
      CyclePhase.fertile => 'assets/images/stickers/fertile.png',
      CyclePhase.follicular => 'assets/images/stickers/follicular.png',
      CyclePhase.luteal => 'assets/images/stickers/luteal.png',
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final asset = _assetForPhase(phase);
    if (asset == null) return const SizedBox.shrink();

    return Semantics(
      label: semanticLabel,
      image: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(BentoTokens.radiusMd),
          child: Image.asset(
            asset,
            key: ValueKey(asset),
            width: _size,
            height: _size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _PhaseBadge extends StatelessWidget {
  const _PhaseBadge({required this.phase, required this.label});

  final CyclePhase? phase;
  final String label;

  static Color _accentForPhase(BuildContext context, CyclePhase? phase) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (phase) {
      CyclePhase.period =>
        isDark ? BentoTokens.primaryDark : BentoTokens.primary,
      CyclePhase.follicular =>
        isDark ? BentoTokens.accentDark : BentoTokens.accent,
      CyclePhase.fertile =>
        isDark
            ? BentoTokens.secondaryDark
            : Color.lerp(BentoTokens.secondary, BentoTokens.text, 0.35)!,
      CyclePhase.luteal => BentoTokens.predicted,
      null => isDark ? BentoTokens.accentDark : BentoTokens.accent,
    };
  }

  static IconData _iconForPhase(CyclePhase? phase) {
    return switch (phase) {
      CyclePhase.period => AppIcons.period,
      CyclePhase.follicular => AppIcons.follicular,
      CyclePhase.fertile => AppIcons.fertile,
      CyclePhase.luteal => AppIcons.luteal,
      null => AppIcons.follicular,
    };
  }

  static Color _foregroundForAccent(Color accent, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return accent;
    return Color.lerp(accent, BentoTokens.text, 0.55) ?? accent;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForPhase(context, phase);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = accent.withValues(alpha: isDark ? 0.28 : 0.22);
    final foreground = _foregroundForAccent(accent, context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconForPhase(phase), size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogPeriodButton extends StatelessWidget {
  const _LogPeriodButton({
    required this.label,
    required this.loading,
    required this.scale,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final double scale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: FilledButton.icon(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: BentoTokens.primaryButton,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(AppIcons.add, size: 16),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
