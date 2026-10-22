import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// Fonte da verdade das despesas.
abstract class ExpenseRepository {
  /// Todas as despesas, das mais recentes para as mais antigas.
  Future<Result<List<Expense>>> getExpenses();
}
