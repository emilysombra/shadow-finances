import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

/// Tudo o que as telas mostram sobre um período: o resumo (com saldo
/// acumulado) e as transações dele.
class PeriodOverview {
  const PeriodOverview({required this.summary, required this.transactions});

  final PeriodSummary summary;

  /// Receitas e despesas do período, das mais recentes para as mais antigas.
  final List<Transaction> transactions;
}
