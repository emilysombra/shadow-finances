import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// Fonte da verdade das receitas.
abstract class IncomeRepository {
  /// Todas as receitas, das mais recentes para as mais antigas.
  Future<Result<List<Income>>> getIncomes();
}
