import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strawly/presentation/theme/bento_tokens.dart';
import 'package:strawly/presentation/widgets/range_day_style.dart';

void main() {
  test('today without a range uses fully rounded corners', () {
    final radius = RangeDayStyle.radiusForCell(
      role: RangeDayRole.none,
      columnIndex: 5,
      isToday: true,
    );

    expect(radius, BorderRadius.circular(BentoTokens.radiusMd));
  });

  test('predicted fill uses pastel predicted token, not warning', () {
    final start = RangeDayStyle.backgroundForRole(
      RangeDayRole.start,
      accentColor: BentoTokens.predicted,
    );
    final middle = RangeDayStyle.backgroundForRole(
      RangeDayRole.middle,
      accentColor: BentoTokens.predicted,
      middleAlpha: 1,
    );

    expect(start, BentoTokens.predicted);
    expect(middle, BentoTokens.predicted);
    expect(start, isNot(BentoTokens.warning));
  });

  test('uniformFill uses same alpha for start and middle', () {
    const accent = Color(0xFFF4A6B5);

    final start = RangeDayStyle.backgroundForRole(
      RangeDayRole.start,
      accentColor: accent,
      middleAlpha: 0.4,
      uniformFill: true,
    );
    final middle = RangeDayStyle.backgroundForRole(
      RangeDayRole.middle,
      accentColor: accent,
      middleAlpha: 0.4,
      uniformFill: true,
    );

    expect(start, middle);
    expect(start, accent.withValues(alpha: 0.4));
  });
}
