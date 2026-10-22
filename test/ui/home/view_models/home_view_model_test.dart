import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/period_filter/period_filter_repository_memory.dart';
import 'package:shadow_finances/domain/use_cases/get_period_overview_use_case.dart';
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
}
