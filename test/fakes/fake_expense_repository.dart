import 'package:shadow_finances/data/repositories/expense/expense_repository.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// [ExpenseRepository] em memória para testes. Devolve [expenses] na ordem
/// em que foram passadas.
class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository({this.expenses = const []});

  List<Expense> expenses;

  /// Quando `true`, todas as operações falham.
  bool shouldFail = false;

  @override
  Future<Result<List<Expense>>> getExpenses() async {
    if (shouldFail) return Result.failure(Exception('falha simulada'));
    return Result.ok(expenses);
  }
}
