import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/period_filter/period_filter_repository_memory.dart';
import 'package:shadow_finances/domain/models/account_summary.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/use_cases/get_period_overview_use_case.dart';
import 'package:shadow_finances/utils/result.dart';
import 'package:shadow_finances/ui/home/view_models/home_view_model.dart';

import '../../../fakes/fake_account_repository.dart';
import '../../../fakes/fake_expense_repository.dart';
import '../../../fakes/fake_income_repository.dart';
import '../../../fakes/fixed_clock.dart';
import '../../../fakes/sample_transactions.dart';

void main() {
  HomeViewModel viewModelWith(int transactionCount) => HomeViewModel(
    clock: FixedClock(DateTime(2026, 10, 22)),
    periodFilterRepository: PeriodFilterRepositoryMemory(),
    getPeriodOverview: GetPeriodOverviewUseCase(
      accountRepository: FakeAccountRepository(),
      incomeRepository: FakeIncomeRepository(),
      expenseRepository: FakeExpenseRepository(
        expenses: [
          for (var day = 1; day <= transactionCount; day++)
            testExpense('e$day', day),
        ],
      ),
    ),
  );

  test('mostra só as 5 transações mais recentes do período', () async {
    final viewModel = viewModelWith(8);

    await viewModel.load();

    expect(viewModel.transactions, hasLength(8));
    expect(viewModel.recentTransactions.map((t) => t.id), [
      'e8',
      'e7',
      'e6',
      'e5',
      'e4',
    ]);
    expect(viewModel.hasMoreTransactions, isTrue);
  });

  test('com 5 ou menos, mostra todas e não há mais', () async {
    final viewModel = viewModelWith(5);

    await viewModel.load();

    expect(viewModel.recentTransactions, hasLength(5));
    expect(viewModel.hasMoreTransactions, isFalse);
  });

  test('gasto por categoria vem do resumo e acompanha o filtro', () async {
    // Repositório de contas que devolve gastos diferentes por período.
    final accounts = _AccountsByRange({
      PeriodFilter.currentMonth: const {ExpenseCategory.food: 300},
      PeriodFilter.currentYear: const {
        ExpenseCategory.food: 900,
        ExpenseCategory.housing: 5000,
      },
    }, today: DateTime(2026, 10, 22));
    final viewModel = HomeViewModel(
      clock: FixedClock(DateTime(2026, 10, 22)),
      periodFilterRepository: PeriodFilterRepositoryMemory(),
      getPeriodOverview: GetPeriodOverviewUseCase(
        accountRepository: accounts,
        incomeRepository: FakeIncomeRepository(),
        expenseRepository: FakeExpenseRepository(),
      ),
    );
    expect(viewModel.expensesByCategory, isEmpty, reason: 'antes de carregar');

    await viewModel.load();
    expect(viewModel.expensesByCategory, [
      (category: ExpenseCategory.food, cents: 300),
    ]);

    viewModel.selectFilter(PeriodFilter.currentYear);
    await pumpEventQueue();
    expect(viewModel.expensesByCategory, [
      (category: ExpenseCategory.housing, cents: 5000),
      (category: ExpenseCategory.food, cents: 900),
    ]);
  });
}

/// Devolve, para o intervalo de cada filtro, um resumo com os gastos dados.
class _AccountsByRange extends FakeAccountRepository {
  _AccountsByRange(this.byFilter, {required this.today});

  final Map<PeriodFilter, Map<ExpenseCategory, int>> byFilter;
  final DateTime today;

  @override
  Future<Result<List<AccountSummary>>> getAccountSummaries(
    DateRange range,
  ) async {
    final filter = byFilter.keys.firstWhere((f) => f.rangeOn(today) == range);
    final categories = byFilter[filter]!;
    return Result.ok([
      AccountSummary(
        account: FakeAccountRepository.account,
        summary: PeriodSummary(
          previousBalanceCents: 0,
          totals: FinancialSummary(
            incomeCents: 0,
            expensesCents: categories.values.fold(0, (a, b) => a + b),
            expensesByCategory: categories,
          ),
        ),
      ),
    ]);
  }
}
