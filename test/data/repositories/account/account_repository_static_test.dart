import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/account/account_repository_static.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository_static.dart';
import 'package:shadow_finances/data/repositories/income/income_repository_static.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_balance.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

void main() {
  final repository = AccountRepositoryStatic();

  test('devolve a única conta com seus totais', () async {
    final result = await repository.getAccountBalances();
    expect(
      result,
      isA<Ok<List<AccountBalance>>>().having((r) => r.value, 'value', [
        AccountRepositoryStatic.mainAccountBalance,
      ]),
    );
  });

  test('a conta principal é a padrão', () async {
    final result = await repository.getMainAccount();
    expect(
      result,
      isA<Ok<Account>>()
          .having((r) => r.value, 'value', AccountRepositoryStatic.mainAccount)
          .having((r) => r.value.isMain, 'isMain', isTrue),
    );
  });

  test('totais guardados batem com as transações fictícias', () {
    final transactions = <Transaction>[
      ...IncomeRepositoryStatic.incomes,
      ...ExpenseRepositoryStatic.expenses,
    ];
    final balance = AccountRepositoryStatic.mainAccountBalance;

    expect(
      FinancialSummary.of(
        transactions.where((t) => t.accountId == balance.account.id),
      ),
      balance.totals,
    );
  });
}
