import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/period_filter/period_filter_repository_memory.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/use_cases/get_period_overview_use_case.dart';
import 'package:shadow_finances/ui/transactions/view_models/transactions_view_model.dart';

import '../../../fakes/fake_account_repository.dart';
import '../../../fakes/fake_expense_repository.dart';
import '../../../fakes/fake_income_repository.dart';
import '../../../fakes/fixed_clock.dart';
import '../../../fakes/sample_transactions.dart';

void main() {
  test(
    'abre no filtro já escolhido no app e traz todas as transações',
    () async {
      final today = DateTime(2026, 10, 22);
      final accountRepository = FakeAccountRepository();
      final filterRepository = PeriodFilterRepositoryMemory()
        ..select(PeriodFilter.currentYear);
      final viewModel = TransactionsViewModel(
        clock: FixedClock(today),
        periodFilterRepository: filterRepository,
        getPeriodOverview: GetPeriodOverviewUseCase(
          accountRepository: accountRepository,
          incomeRepository: FakeIncomeRepository(),
          expenseRepository: FakeExpenseRepository(
            expenses: [
              for (var day = 1; day <= 8; day++) testExpense('e$day', day),
            ],
          ),
        ),
      );

      await viewModel.load();

      expect(viewModel.filter, PeriodFilter.currentYear);
      expect(accountRepository.requestedRanges, [
        PeriodFilter.currentYear.rangeOn(today),
      ]);
      expect(viewModel.transactions, hasLength(8));
    },
  );
}
