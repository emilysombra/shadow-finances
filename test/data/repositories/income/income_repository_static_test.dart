import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/income/income_repository_static.dart';
import 'package:shadow_finances/data/services/sample_data_service.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

void main() {
  final today = DateTime(2026, 10, 22);
  final data = SampleDataService(today: today);
  final repository = IncomeRepositoryStatic(sampleData: data);

  test('só receitas do período, das mais recentes às mais antigas', () async {
    final range = PeriodFilter.currentYear.rangeOn(today);

    final result = await repository.getIncomes(range);
    final incomes = (result as Ok<List<Income>>).value;

    expect(
      incomes,
      unorderedEquals(data.incomes.where((i) => range.contains(i.date))),
    );
    for (var i = 1; i < incomes.length; i++) {
      expect(incomes[i - 1].date.isBefore(incomes[i].date), isFalse);
    }
  });
}
