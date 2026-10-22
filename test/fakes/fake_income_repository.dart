import 'package:shadow_finances/data/repositories/income/income_repository.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// [IncomeRepository] em memória para testes. Devolve as [incomes] dentro do
/// período pedido, na ordem em que foram passadas.
class FakeIncomeRepository implements IncomeRepository {
  FakeIncomeRepository({this.incomes = const []});

  List<Income> incomes;

  /// Quando `true`, todas as operações falham.
  bool shouldFail = false;

  @override
  Future<Result<List<Income>>> getIncomes(DateRange range) async {
    if (shouldFail) return Result.failure(Exception('falha simulada'));
    return Result.ok([
      for (final income in incomes)
        if (range.contains(income.date)) income,
    ]);
  }
}
