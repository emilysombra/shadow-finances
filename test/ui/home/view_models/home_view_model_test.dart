import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_balance.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/ui/home/view_models/home_view_model.dart';

import '../../../fakes/fake_account_repository.dart';
import '../../../fakes/fake_expense_repository.dart';
import '../../../fakes/fake_income_repository.dart';

void main() {
  final accountId = FakeAccountRepository.account.id;
  final initialBalance = Income.initialBalance(
    id: 'i1',
    amountCents: 2000,
    date: DateTime(2026, 10, 1),
    accountId: accountId,
  );
  final salary = Income(
    id: 'i2',
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
    date: DateTime(2026, 10, 3),
    accountId: accountId,
    category: ExpenseCategory.food,
  );
  final bus = Expense(
    id: 'e2',
    description: 'Ônibus',
    amountCents: 500,
    date: DateTime(2026, 10, 2),
    accountId: accountId,
    category: ExpenseCategory.transport,
  );

  late FakeAccountRepository accountRepository;
  late FakeIncomeRepository incomeRepository;
  late FakeExpenseRepository expenseRepository;
  late HomeViewModel viewModel;

  setUp(() {
    accountRepository = FakeAccountRepository();
    incomeRepository = FakeIncomeRepository(incomes: [salary, initialBalance]);
    expenseRepository = FakeExpenseRepository(expenses: [market, bus]);
    viewModel = HomeViewModel(
      accountRepository: accountRepository,
      incomeRepository: incomeRepository,
      expenseRepository: expenseRepository,
    );
  });

  test('antes de carregar, não tem resumo, transações nem erro', () {
    expect(viewModel.summary, isNull);
    expect(viewModel.transactions, isEmpty);
    expect(viewModel.hasError, isFalse);
  });

  test(
    'resumo soma os totais guardados das contas, não as transações',
    () async {
      // Totais propositalmente diferentes da soma das transações acima: se o
      // ViewModel somasse as transações, daria 10000/3500.
      accountRepository.balances = const [
        AccountBalance(
          account: FakeAccountRepository.account,
          totals: FinancialSummary(incomeCents: 700, expensesCents: 100),
        ),
        AccountBalance(
          account: Account(id: 'poupanca', name: 'Poupança'),
          totals: FinancialSummary(incomeCents: 300, expensesCents: 50),
        ),
      ];
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      await viewModel.load();

      expect(
        viewModel.summary,
        const FinancialSummary(incomeCents: 1000, expensesCents: 150),
      );
      expect(viewModel.hasError, isFalse);
      expect(notifications, 1);
    },
  );

  test(
    'transações juntam receitas e despesas, das mais recentes às mais antigas',
    () async {
      await viewModel.load();

      expect(viewModel.transactions, [salary, market, bus, initialBalance]);
    },
  );

  for (final source in ['contas', 'receitas', 'despesas']) {
    test('falha nas $source marca erro e não monta resumo', () async {
      switch (source) {
        case 'contas':
          accountRepository.shouldFail = true;
        case 'receitas':
          incomeRepository.shouldFail = true;
        case 'despesas':
          expenseRepository.shouldFail = true;
      }

      await viewModel.load();

      expect(viewModel.summary, isNull);
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
