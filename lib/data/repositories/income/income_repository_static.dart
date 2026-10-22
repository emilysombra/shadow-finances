import 'package:shadow_finances/data/repositories/income/income_repository.dart';
import 'package:shadow_finances/data/services/sample_data_service.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// [IncomeRepository] provisório sobre os dados fictícios do
/// [SampleDataService].
class IncomeRepositoryStatic implements IncomeRepository {
  IncomeRepositoryStatic({required this._sampleData});

  final SampleDataService _sampleData;

  @override
  Future<Result<List<Income>>> getIncomes(DateRange range) async {
    final incomes = [
      for (final income in _sampleData.incomes)
        if (range.contains(income.date)) income,
    ]..sort((a, b) => b.date.compareTo(a.date));
    return Result.ok(incomes);
  }
}
