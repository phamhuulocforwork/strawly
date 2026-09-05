import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:strawly/core/utils/date_time_utils.dart';
import 'package:strawly/presentation/widgets/period_range_picker.dart';

void main() {
  group('PeriodRangeLogic', () {
    final fixedNow = DateTime(2026, 9, 5);

    test('inclusiveDuration counts same-day as 1', () {
      final range = ShadDateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 1),
      );

      expect(PeriodRangeLogic.inclusiveDuration(range), 1);
    });

    test('inclusiveDuration counts 5-day range correctly', () {
      final range = ShadDateTimeRange(
        start: DateTime(2026, 3, 1),
        end: DateTime(2026, 3, 5),
      );

      expect(PeriodRangeLogic.inclusiveDuration(range), 5);
    });

    test('fromCycle rebuilds range from stored cycle values', () {
      final range = PeriodRangeLogic.fromCycle(
        DateTime(2026, 3, 1),
        5,
      );

      expect(range.start, DateTime(2026, 3, 1));
      expect(range.end, DateTime(2026, 3, 5));
      expect(PeriodRangeLogic.inclusiveDuration(range), 5);
    });

    test('defaultRange uses 5 inclusive days', () {
      final range = PeriodRangeLogic.defaultRange();

      expect(range.start, isNotNull);
      expect(range.end, isNotNull);
      expect(PeriodRangeLogic.inclusiveDuration(range), 5);
    });

    test('validateError rejects incomplete range', () {
      expect(
        PeriodRangeLogic.validateError(
          ShadDateTimeRange(start: DateTime(2026, 3, 1), end: null),
        ),
        isNotNull,
      );
    });

    test('validateError rejects range longer than 10 days', () {
      expect(
        PeriodRangeLogic.validateError(
          ShadDateTimeRange(
            start: DateTime(2026, 3, 1),
            end: DateTime(2026, 3, 15),
          ),
        ),
        isNotNull,
      );
    });

    test('firstSelectableDate is five years before current month start', () {
      final first = PeriodRangeLogic.firstSelectableDate(fixedNow);
      expect(first, DateTime(2021, 9, 1));
    });

    test('lastSelectableDate is today plus 30 days', () {
      final last = PeriodRangeLogic.lastSelectableDate(fixedNow);
      expect(
        last,
        DateTimeUtils.addDays(DateTimeUtils.dateOnly(fixedNow), 30),
      );
    });

    test('isDaySelectable allows date at five-year boundary', () {
      final day = DateTime(2021, 9, 1);
      expect(PeriodRangeLogic.isDaySelectable(day, fixedNow), isTrue);
    });

    test('isDaySelectable rejects date before five-year boundary', () {
      final day = DateTime(2021, 8, 31);
      expect(PeriodRangeLogic.isDaySelectable(day, fixedNow), isFalse);
    });

    test('isDaySelectable allows today plus 30 days', () {
      final day = DateTimeUtils.addDays(fixedNow, 30);
      expect(PeriodRangeLogic.isDaySelectable(day, fixedNow), isTrue);
    });

    test('isDaySelectable rejects today plus 31 days', () {
      final day = DateTimeUtils.addDays(fixedNow, 31);
      expect(PeriodRangeLogic.isDaySelectable(day, fixedNow), isFalse);
    });

    test('applyDayTap clamps range to max duration', () {
      final result = PeriodRangeLogic.applyDayTap(
        null,
        DateTime(2026, 3, 1),
      );
      expect(result?.start, DateTime(2026, 3, 1));
      expect(result?.end, isNull);

      final full = PeriodRangeLogic.applyDayTap(
        result,
        DateTime(2026, 3, 20),
      );
      expect(PeriodRangeLogic.inclusiveDuration(full), 10);
      expect(full?.end, DateTime(2026, 3, 10));
    });
  });
}
