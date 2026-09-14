import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strawly/presentation/theme/bento_tokens.dart';
import 'package:strawly/presentation/widgets/range_day_style.dart';

void main() {
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
