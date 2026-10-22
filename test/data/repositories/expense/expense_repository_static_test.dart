import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository_static.dart';
import 'package:shadow_finances/data/services/sample_data_service.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

void main() {
  final today = DateTime(2026, 10, 22);
  final data = SampleDataService(today: today);
  final repository = ExpenseRepositoryStatic(sampleData: data);

  test('só despesas do período, das mais recentes às mais antigas', () async {
    final range = PeriodFilter.lastSevenDays.rangeOn(today);

    final result = await repository.getExpenses(range);
    final expenses = (result as Ok<List<Expense>>).value;

    expect(expenses, isNotEmpty);
    expect(
      expenses,
      unorderedEquals(data.expenses.where((e) => range.contains(e.date))),
    );
    for (var i = 1; i < expenses.length; i++) {
      expect(expenses[i - 1].date.isBefore(expenses[i].date), isFalse);
    }
  });
}
