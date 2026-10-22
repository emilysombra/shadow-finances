import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_summary.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/ui/home/view_models/home_view_model.dart';

import '../../../fakes/fake_account_repository.dart';
import '../../../fakes/fake_expense_repository.dart';
import '../../../fakes/fake_income_repository.dart';
import '../../../fakes/fixed_clock.dart';

void main() {
  final today = DateTime(2026, 10, 22);
  final accountId = FakeAccountRepository.account.id;

  final salary = Income(
    id: 'i1',
    description: 'Salário',
    amountCents: 8000,
    date: DateTime(2026, 10, 5),
    accountId: accountId,
    category: IncomeCategory.salary,
  );
  final market = Expense(
    id: 'e1',
    description: 'Mercado',
    amountCents: 3000,
    date: DateTime(2026, 10, 20),
    accountId: accountId,
    category: ExpenseCategory.food,
  );
  final lastMonth = Expense(
    id: 'e2',
    description: 'Ônibus',
    amountCents: 500,
    date: DateTime(2026, 9, 2),
    accountId: accountId,
    category: ExpenseCategory.transport,
  );

  late FakeAccountRepository accountRepository;
  late FakeIncomeRepository incomeRepository;
  late FakeExpenseRepository expenseRepository;
  late HomeViewModel viewModel;

  setUp(() {
    accountRepository = FakeAccountRepository();
    incomeRepository = FakeIncomeRepository(incomes: [salary]);
    expenseRepository = FakeExpenseRepository(expenses: [market, lastMonth]);
    viewModel = HomeViewModel(
      clock: FixedClock(today),
      accountRepository: accountRepository,
      incomeRepository: incomeRepository,
      expenseRepository: expenseRepository,
    );
  });

  test('começa no mês atual, sem resumo, transações nem erro', () {
    expect(viewModel.filter, PeriodFilter.currentMonth);
    expect(viewModel.range, PeriodFilter.currentMonth.rangeOn(today));
    expect(viewModel.summary, isNull);
    expect(viewModel.transactions, isEmpty);
    expect(viewModel.hasError, isFalse);
  });

  test('resumo soma os resumos das contas, não as transações', () async {
    // Valores propositalmente diferentes da soma das transações acima.
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
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.load();

    expect(
      viewModel.summary,
      const PeriodSummary(
        previousBalanceCents: 800,
        totals: FinancialSummary(incomeCents: 1000, expensesCents: 150),
      ),
    );
    expect(viewModel.hasError, isFalse);
    expect(notifications, 1);
  });

  test('lista só as transações do período, mais recentes primeiro', () async {
    await viewModel.load();

    expect(viewModel.transactions, [market, salary]);
  });

  test('trocar o filtro pede o novo período e recarrega', () async {
    await viewModel.load();

    await viewModel.selectFilter(PeriodFilter.currentYear);

    expect(viewModel.filter, PeriodFilter.currentYear);
    expect(
      accountRepository.requestedRanges.last,
      PeriodFilter.currentYear.rangeOn(today),
    );
    expect(viewModel.transactions, [market, salary, lastMonth]);

    await viewModel.selectFilter(PeriodFilter.lastSevenDays);
    expect(viewModel.transactions, [market]);
  });

  test('resposta atrasada de um filtro antigo é descartada', () async {
    accountRepository.holdResponses = true;
    final monthLoad = viewModel.load();
    final yearLoad = viewModel.selectFilter(PeriodFilter.currentYear);
    await pumpEventQueue();
    expect(accountRepository.pending, hasLength(2));

    // O ano responde primeiro; o mês, que o usuário já trocou, por último.
    accountRepository.pending[1].complete();
    await yearLoad;
    accountRepository.pending[0].complete();
    await monthLoad;

    expect(viewModel.filter, PeriodFilter.currentYear);
    expect(viewModel.transactions, [market, salary, lastMonth]);
  });

  for (final source in ['contas', 'receitas', 'despesas']) {
    test('falha nas $source marca erro e limpa os dados', () async {
      await viewModel.load();
      switch (source) {
        case 'contas':
          accountRepository.shouldFail = true;
        case 'receitas':
          incomeRepository.shouldFail = true;
        case 'despesas':
          expenseRepository.shouldFail = true;
      }

      await viewModel.selectFilter(PeriodFilter.currentYear);

      expect(viewModel.summary, isNull);
      expect(viewModel.transactions, isEmpty);
      expect(viewModel.hasError, isTrue);
    });
  }

  test('recarregar com sucesso limpa o erro', () async {
    expenseRepository.shouldFail = true;
    await viewModel.load();

    expenseRepository.shouldFail = false;
    await viewModel.load();

    expect(viewModel.summary, isNotNull);
    expect(viewModel.hasError, isFalse);
  });
}
