import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';

void main() {
  DateRange range(DateTime start, DateTime end) =>
      DateRange(start: start, end: end);

  test('mês atual vai do dia 1 ao último dia do mês', () {
    expect(
      PeriodFilter.currentMonth.rangeOn(DateTime(2026, 10, 22, 14)),
      range(DateTime(2026, 10, 1), DateTime(2026, 10, 31)),
    );
    expect(
      PeriodFilter.currentMonth.rangeOn(DateTime(2028, 2, 10)),
      range(DateTime(2028, 2, 1), DateTime(2028, 2, 29)),
      reason: 'fevereiro de ano bissexto',
    );
  });

  test('ano atual vai de 1º de janeiro a 31 de dezembro', () {
    expect(
      PeriodFilter.currentYear.rangeOn(DateTime(2026, 10, 22)),
      range(DateTime(2026, 1, 1), DateTime(2026, 12, 31)),
    );
  });

  test('últimos 7 dias são hoje e os seis anteriores, mesmo virando o ano', () {
    expect(
      PeriodFilter.lastSevenDays.rangeOn(DateTime(2026, 10, 22, 9)),
      range(DateTime(2026, 10, 16), DateTime(2026, 10, 22)),
    );
    expect(
      PeriodFilter.lastSevenDays.rangeOn(DateTime(2027, 1, 3)),
      range(DateTime(2026, 12, 28), DateTime(2027, 1, 3)),
    );
  });
}
