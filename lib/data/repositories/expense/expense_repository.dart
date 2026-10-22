import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// Fonte da verdade das despesas.
abstract class ExpenseRepository {
  /// Despesas dentro de [range], das mais recentes para as mais antigas.
  Future<Result<List<Expense>>> getExpenses(DateRange range);
}
