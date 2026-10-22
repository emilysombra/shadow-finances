import 'package:shadow_finances/data/repositories/income/income_repository.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// [IncomeRepository] em memória para testes. Devolve [incomes] na ordem em
/// que foram passadas.
class FakeIncomeRepository implements IncomeRepository {
  FakeIncomeRepository({this.incomes = const []});

  List<Income> incomes;

  /// Quando `true`, todas as operações falham.
  bool shouldFail = false;

  @override
  Future<Result<List<Income>>> getIncomes() async {
    if (shouldFail) return Result.failure(Exception('falha simulada'));
    return Result.ok(incomes);
  }
}
