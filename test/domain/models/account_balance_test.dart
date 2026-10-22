import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_balance.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

void main() {
  const account = Account(id: 'main', name: 'Principal', isMain: true);
  const balance = AccountBalance(
    account: account,
    totals: FinancialSummary(incomeCents: 1000, expensesCents: 200),
  );

  Expense expense(String accountId, int cents) => Expense(
    id: 'e',
    description: '',
    amountCents: cents,
    date: DateTime(2026, 10, 1),
    accountId: accountId,
    category: ExpenseCategory.other,
  );

  test('saldo é receitas menos despesas da conta', () {
    expect(balance.balanceCents, 800);
  });

  test('add e remove atualizam só os totais da conta', () {
    final updated = balance.add(expense('main', 300));

    expect(updated.account, account);
    expect(updated.balanceCents, 500);
    expect(updated.remove(expense('main', 300)), balance);
  });

  test('transação de outra conta é recusada', () {
    expect(() => balance.add(expense('outra', 1)), throwsArgumentError);
    expect(() => balance.remove(expense('outra', 1)), throwsArgumentError);
  });
}
