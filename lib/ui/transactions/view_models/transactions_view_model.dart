import 'package:shadow_finances/ui/core/view_models/period_view_model.dart';

/// Estado da tela de transações: o período escolhido (o mesmo do app
/// inteiro) com todas as transações dele.
class TransactionsViewModel extends PeriodViewModel {
  TransactionsViewModel({
    required super.clock,
    required super.getPeriodOverview,
    required super.periodFilterRepository,
  });
}
