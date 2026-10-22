import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_summary.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/period_overview.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/use_cases/get_period_overview_use_case.dart';
import 'package:shadow_finances/utils/result.dart';

import '../../fakes/fake_account_repository.dart';
import '../../fakes/fake_expense_repository.dart';
import '../../fakes/fake_income_repository.dart';
import '../../fakes/sample_transactions.dart';

void main() {
  final october = PeriodFilter.currentMonth.rangeOn(DateTime(2026, 10, 22));
  final salary = testIncome('i1', 5);
  final market = testExpense('e1', 20);
  final lastMonth = testExpense('e2', -10); // 20 de setembro

  late FakeAccountRepository accountRepository;
  late FakeIncomeRepository incomeRepository;
  late FakeExpenseRepository expenseRepository;
  late GetPeriodOverviewUseCase getPeriodOverview;

  setUp(() {
    accountRepository = FakeAccountRepository();
    incomeRepository = FakeIncomeRepository(incomes: [salary]);
    expenseRepository = FakeExpenseRepository(expenses: [lastMonth, market]);
    getPeriodOverview = GetPeriodOverviewUseCase(
      accountRepository: accountRepository,
      incomeRepository: incomeRepository,
      expenseRepository: expenseRepository,
    );
  });

  test('resumo soma os resumos das contas, não as transações', () async {
    // Valores propositalmente diferentes da soma das transações.
    accountRepository.summaries = const [
      AccountSummary(
        account: FakeAccountRepository.account,
        summary: PeriodSummary(
          previousBalanceCents: -200,
          totals: FinancialSummary(incomeCents: 700, expensesCents: 100),
        ),
      ),
      AccountSummary(
        account: Account(id: 'poupanca', name: 'Poupança'),
        summary: PeriodSummary(
          previousBalanceCents: 1000,
          totals: FinancialSummary(incomeCents: 300, expensesCents: 50),
        ),
      ),
    ];

    final result = await getPeriodOverview(october);

    expect(
      (result as Ok<PeriodOverview>).value.summary,
      const PeriodSummary(
        previousBalanceCents: 800,
        totals: FinancialSummary(incomeCents: 1000, expensesCents: 150),
      ),
    );
    expect(accountRepository.requestedRanges, [october]);
  });

  test(
    'junta receitas e despesas do período, mais recentes primeiro',
    () async {
      final result = await getPeriodOverview(october);

      expect((result as Ok<PeriodOverview>).value.transactions, [
        market,
        salary,
      ]);
    },
  );

  for (final source in ['contas', 'receitas', 'despesas']) {
    test('falha nas $source vira Failure', () async {
      switch (source) {
        case 'contas':
          accountRepository.shouldFail = true;
        case 'receitas':
          incomeRepository.shouldFail = true;
        case 'despesas':
          expenseRepository.shouldFail = true;
      }

      expect(await getPeriodOverview(october), isA<Failure<PeriodOverview>>());
    });
  }
}
