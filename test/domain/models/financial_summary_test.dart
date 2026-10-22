import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

void main() {
  Income income(int cents) => Income(
    id: 'i$cents',
    description: '',
    amountCents: cents,
    date: DateTime(2026, 10, 1),
    accountId: 'conta',
    category: IncomeCategory.other,
  );

  Expense expense(int cents) => Expense(
    id: 'e$cents',
    description: '',
    amountCents: cents,
    date: DateTime(2026, 10, 1),
    accountId: 'conta',
    category: ExpenseCategory.other,
  );

  const totals = FinancialSummary(incomeCents: 10000, expensesCents: 2550);

  test('saldo é receitas menos despesas', () {
    expect(totals.balanceCents, 7450);
  });

  test('saldo fica negativo quando as despesas superam as receitas', () {
    const summary = FinancialSummary(incomeCents: 1000, expensesCents: 1500);
    expect(summary.balanceCents, -500);
  });

  test('add soma só a transação nova ao total certo', () {
    expect(
      totals.add(income(500)),
      const FinancialSummary(incomeCents: 10500, expensesCents: 2550),
    );
    expect(
      totals.add(expense(50)),
      const FinancialSummary(incomeCents: 10000, expensesCents: 2600),
    );
  });

  test('remove desfaz add; editar é remove da antiga e add da nova', () {
    expect(totals.add(expense(50)).remove(expense(50)), totals);
    expect(
      totals.add(expense(50)).remove(expense(50)).add(expense(80)),
      const FinancialSummary(incomeCents: 10000, expensesCents: 2630),
    );
  });

  test('of calcula do zero; sum junta vários totais', () {
    final fromTransactions = FinancialSummary.of([
      income(1000),
      expense(300),
      income(50),
    ]);
    expect(
      fromTransactions,
      const FinancialSummary(incomeCents: 1050, expensesCents: 300),
    );
    expect(
      FinancialSummary.sum([totals, fromTransactions]),
      const FinancialSummary(incomeCents: 11050, expensesCents: 2850),
    );
    expect(FinancialSummary.sum(const []), FinancialSummary.zero);
  });
}
