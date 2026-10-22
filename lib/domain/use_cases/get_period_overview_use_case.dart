import 'package:shadow_finances/data/repositories/account/account_repository.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository.dart';
import 'package:shadow_finances/data/repositories/income/income_repository.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/period_overview.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// Busca o resumo e as transações de um período, juntando contas, receitas e
/// despesas. Usado pela tela inicial e pela tela de transações.
///
/// O resumo vem dos totais guardados de cada conta: as transações servem só
/// para a lista, nunca são somadas aqui.
class GetPeriodOverviewUseCase {
  GetPeriodOverviewUseCase({
    required this._accountRepository,
    required this._incomeRepository,
    required this._expenseRepository,
  });

  final AccountRepository _accountRepository;
  final IncomeRepository _incomeRepository;
  final ExpenseRepository _expenseRepository;

  /// Falha se qualquer uma das três fontes falhar, para nunca devolver
  /// valores pela metade.
  Future<Result<PeriodOverview>> call(DateRange range) async {
    final (accounts, incomes, expenses) = await (
      _accountRepository.getAccountSummaries(range),
      _incomeRepository.getIncomes(range),
      _expenseRepository.getExpenses(range),
    ).wait;

    return switch ((accounts, incomes, expenses)) {
      (
        Ok(value: final accounts),
        Ok(value: final incomes),
        Ok(value: final expenses),
      ) =>
        Result.ok(
          PeriodOverview(
            summary: PeriodSummary.sum(
              accounts.map((account) => account.summary),
            ),
            transactions: List.unmodifiable(
              <Transaction>[...incomes, ...expenses]
                ..sort((a, b) => b.date.compareTo(a.date)),
            ),
          ),
        ),
      (Failure(:final error), _, _) ||
      (_, Failure(:final error), _) ||
      (_, _, Failure(:final error)) => Result.failure(error),
    };
  }
}
