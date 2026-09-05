import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:strawly/core/utils/date_time_utils.dart';

void main() {
  final sampleDate = DateTime(2026, 8, 26);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('vi');
  });

  test('formatDate uses English month abbreviation', () {
    final formatted = DateTimeUtils.formatDate(sampleDate, 'en');
    expect(formatted, contains('Aug'));
    expect(formatted, contains('26'));
    expect(formatted, contains('2026'));
  });

  test('formatDate uses Vietnamese month format', () {
    final formatted = DateTimeUtils.formatDate(sampleDate, 'vi');
    expect(formatted.toLowerCase(), isNot(contains('aug')));
    expect(formatted, contains('26'));
    expect(formatted, contains('2026'));
  });

  test('formatMonthYear localizes calendar header', () {
    expect(
      DateTimeUtils.formatMonthYear(sampleDate, 'en'),
      contains('August'),
    );
    expect(
      DateTimeUtils.formatMonthYear(sampleDate, 'vi').toLowerCase(),
      isNot(contains('august')),
    );
  });

  test('weekdayLabels returns seven Monday-first labels', () {
    final labels = DateTimeUtils.weekdayLabels('en');
    expect(labels, hasLength(7));
    expect(labels.first.toLowerCase(), startsWith('m'));
  });
}
