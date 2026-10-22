import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

void main() {
  test('saldo inicial é uma receita da categoria própria, sem descrição', () {
    final income = Income.initialBalance(
      id: 'i1',
      amountCents: 1000,
      date: DateTime(2026, 10, 1),
      accountId: 'conta',
    );

    expect(income.category, IncomeCategory.initialBalance);
    expect(income.description, isEmpty);
    expect(income.accountId, 'conta');
    expect(income.amountCents, 1000);
  });

  test('receita e despesa com os mesmos dados não são iguais', () {
    final date = DateTime(2026, 10, 1);
    final expense = Expense(
      id: '1',
      description: 'x',
      amountCents: 100,
      date: date,
      accountId: 'conta',
      category: ExpenseCategory.other,
    );
    final income = Income(
      id: '1',
      description: 'x',
      amountCents: 100,
      date: date,
      category: IncomeCategory.other,
      accountId: 'conta',
    );

    expect(expense == income, isFalse);
    expect(income == expense, isFalse);
  });

  test('mesma transação em outra conta não é igual', () {
    Expense expense(String accountId) => Expense(
      id: '1',
      description: 'x',
      amountCents: 100,
      date: DateTime(2026, 10, 1),
      accountId: accountId,
      category: ExpenseCategory.other,
    );

    expect(expense('a') == expense('b'), isFalse);
    expect(expense('a'), expense('a'));
  });
}
