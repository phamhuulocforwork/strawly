import 'package:flutter/material.dart';
import '../../core/utils/date_time_utils.dart';
import '../theme/bento_tokens.dart';

enum RangeDayRole { none, single, start, end, middle }

/// Shared geometry and fill for connected range bars in calendar grids.
class RangeDayStyle {
  RangeDayStyle._();

  static RangeDayRole roleForRange({
    required DateTime date,
    required DateTime? rangeStart,
    required DateTime? rangeEnd,
  }) {
    if (rangeStart == null) return RangeDayRole.none;

    final start = DateTimeUtils.dateOnly(rangeStart);
    final normalized = DateTimeUtils.dateOnly(date);

    if (rangeEnd == null) {
      return DateTimeUtils.isSameDay(normalized, start)
          ? RangeDayRole.single
          : RangeDayRole.none;
    }

    final end = DateTimeUtils.dateOnly(rangeEnd);

    if (normalized.isBefore(start) || normalized.isAfter(end)) {
      return RangeDayRole.none;
    }

    if (DateTimeUtils.isSameDay(normalized, start) &&
        DateTimeUtils.isSameDay(normalized, end)) {
      return RangeDayRole.single;
    }
    if (DateTimeUtils.isSameDay(normalized, start)) {
      return RangeDayRole.start;
    }
    if (DateTimeUtils.isSameDay(normalized, end)) {
      return RangeDayRole.end;
    }

    return RangeDayRole.middle;
  }

  static BorderRadius radiusForCell({
    required RangeDayRole role,
    required int columnIndex,
    bool isToday = false,
  }) {
    if (role == RangeDayRole.none && isToday) {
      return BorderRadius.circular(BentoTokens.radiusMd);
    }
    return borderRadiusForRole(role, columnIndex);
  }

  static BorderRadius borderRadiusForRole(RangeDayRole role, int columnIndex) {
    const r = BentoTokens.radiusMd;
    switch (role) {
      case RangeDayRole.single:
        return BorderRadius.circular(r);
      case RangeDayRole.start:
        if (columnIndex == 6) {
          return BorderRadius.circular(r);
        }
        return const BorderRadius.horizontal(left: Radius.circular(r));
      case RangeDayRole.end:
        if (columnIndex == 0) {
          return BorderRadius.circular(r);
        }
        return const BorderRadius.horizontal(right: Radius.circular(r));
      case RangeDayRole.middle:
        if (columnIndex == 0) {
          return const BorderRadius.horizontal(left: Radius.circular(r));
        }
        if (columnIndex == 6) {
          return const BorderRadius.horizontal(right: Radius.circular(r));
        }
        return BorderRadius.zero;
      case RangeDayRole.none:
        return BorderRadius.zero;
    }
  }

  static Color? backgroundForRole(
    RangeDayRole role, {
    required Color accentColor,
    double middleAlpha = 0.4,
    bool uniformFill = false,
  }) {
    if (uniformFill) {
      switch (role) {
        case RangeDayRole.single:
        case RangeDayRole.start:
        case RangeDayRole.end:
        case RangeDayRole.middle:
          return accentColor.withValues(alpha: middleAlpha);
        case RangeDayRole.none:
          return null;
      }
    }

    switch (role) {
      case RangeDayRole.single:
      case RangeDayRole.start:
      case RangeDayRole.end:
        return accentColor;
      case RangeDayRole.middle:
        return accentColor.withValues(alpha: middleAlpha);
      case RangeDayRole.none:
        return null;
    }
  }

  static Color textColorForRole(
    RangeDayRole role,
    BuildContext context, {
    bool onAccentUsesDarkText = true,
  }) {
    switch (role) {
      case RangeDayRole.single:
      case RangeDayRole.start:
      case RangeDayRole.end:
        return onAccentUsesDarkText
            ? BentoTokens.text
            : BentoTokens.onSurfaceText(context);
      case RangeDayRole.middle:
      case RangeDayRole.none:
        return BentoTokens.onSurfaceText(context);
    }
  }
}
