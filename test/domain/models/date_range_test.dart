import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/date_range.dart';

void main() {
  test('ignora a hora e inclui o primeiro e o último dia', () {
    final range = DateRange(
      start: DateTime(2026, 10, 1, 15, 30),
      end: DateTime(2026, 10, 31, 8),
    );

    expect(range.start, DateTime(2026, 10, 1));
    expect(range.end, DateTime(2026, 10, 31));
    expect(range.contains(DateTime(2026, 10, 1)), isTrue);
    expect(range.contains(DateTime(2026, 10, 31, 23, 59)), isTrue);
    expect(range.contains(DateTime(2026, 9, 30, 23, 59)), isFalse);
    expect(range.contains(DateTime(2026, 11, 1)), isFalse);
  });

  test('fim antes do início é recusado', () {
    expect(
      () => DateRange(start: DateTime(2026, 10, 2), end: DateTime(2026, 10, 1)),
      throwsArgumentError,
    );
  });
}
