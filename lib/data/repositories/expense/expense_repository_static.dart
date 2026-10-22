import 'package:shadow_finances/data/repositories/expense/expense_repository.dart';
import 'package:shadow_finances/data/services/sample_data_service.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// [ExpenseRepository] provisório sobre os dados fictícios do
/// [SampleDataService].
class ExpenseRepositoryStatic implements ExpenseRepository {
  ExpenseRepositoryStatic({required this._sampleData});

  final SampleDataService _sampleData;

  @override
  Future<Result<List<Expense>>> getExpenses(DateRange range) async {
    final expenses = [
      for (final expense in _sampleData.expenses)
        if (range.contains(expense.date)) expense,
    ]..sort((a, b) => b.date.compareTo(a.date));
    return Result.ok(expenses);
  }
}
