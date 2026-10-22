import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/ui/core/view_models/period_view_model.dart';

/// Estado da tela inicial: o período escolhido, com só as transações mais
/// recentes (a lista completa fica na tela de transações).
class HomeViewModel extends PeriodViewModel {
  HomeViewModel({
    required super.clock,
    required super.getPeriodOverview,
    required super.periodFilterRepository,
  });

  /// Quantas transações a tela inicial mostra, no máximo.
  static const recentLimit = 5;

  /// As [recentLimit] transações mais recentes do período.
  List<Transaction> get recentTransactions =>
      transactions.take(recentLimit).toList(growable: false);

  /// Se o período tem mais transações do que as exibidas.
  bool get hasMoreTransactions => transactions.length > recentLimit;
}
