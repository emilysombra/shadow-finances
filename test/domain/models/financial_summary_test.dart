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

  const totals = FinancialSummary(
    incomeCents: 10000,
    expensesCents: 2550,
    expensesByCategory: {ExpenseCategory.other: 2550},
  );

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
      const FinancialSummary(
        incomeCents: 10500,
        expensesCents: 2550,
        expensesByCategory: {ExpenseCategory.other: 2550},
      ),
    );
    expect(
      totals.add(expense(50)),
      const FinancialSummary(
        incomeCents: 10000,
        expensesCents: 2600,
        expensesByCategory: {ExpenseCategory.other: 2600},
      ),
    );
  });

  test('remove desfaz add; editar é remove da antiga e add da nova', () {
    expect(totals.add(expense(50)).remove(expense(50)), totals);
    expect(
      totals.add(expense(50)).remove(expense(50)).add(expense(80)),
      const FinancialSummary(
        incomeCents: 10000,
        expensesCents: 2630,
        expensesByCategory: {ExpenseCategory.other: 2630},
      ),
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
      const FinancialSummary(
        incomeCents: 1050,
        expensesCents: 300,
        expensesByCategory: {ExpenseCategory.other: 300},
      ),
    );
    expect(
      FinancialSummary.sum([totals, fromTransactions]),
      const FinancialSummary(
        incomeCents: 11050,
        expensesCents: 2850,
        expensesByCategory: {ExpenseCategory.other: 2850},
      ),
    );
    expect(FinancialSummary.sum(const []), FinancialSummary.zero);
  });

  Expense expenseIn(ExpenseCategory category, int cents) => Expense(
    id: '${category.name}$cents',
    description: '',
    amountCents: cents,
    date: DateTime(2026, 10, 1),
    accountId: 'conta',
    category: category,
  );

  test('despesas por categoria acompanham add e remove', () {
    final food = expenseIn(ExpenseCategory.food, 300);
    final rent = expenseIn(ExpenseCategory.housing, 1000);
    final summary = FinancialSummary.zero.add(food).add(rent).add(income(50));

    expect(summary.expensesByCategory, {
      ExpenseCategory.food: 300,
      ExpenseCategory.housing: 1000,
    });
    expect(summary.remove(food).expensesByCategory, {
      ExpenseCategory.housing: 1000,
    }, reason: 'categoria que zera sai do mapa');
    expect(
      summary.remove(food).remove(rent).remove(income(50)),
      FinancialSummary.zero,
    );
  });

  test(
    'ranking: maior gasto primeiro; empate segue a ordem das categorias',
    () {
      final summary = FinancialSummary.of([
        expenseIn(ExpenseCategory.leisure, 200),
        expenseIn(ExpenseCategory.housing, 1000),
        expenseIn(ExpenseCategory.food, 200),
      ]);

      expect(summary.expensesByCategoryRanked, [
        (category: ExpenseCategory.housing, cents: 1000),
        (category: ExpenseCategory.food, cents: 200),
        (category: ExpenseCategory.leisure, cents: 200),
      ]);
    },
  );

  test('igualdade compara também as categorias', () {
    expect(
      FinancialSummary.of([expenseIn(ExpenseCategory.food, 100)]) ==
          FinancialSummary.of([expenseIn(ExpenseCategory.health, 100)]),
      isFalse,
    );
  });
}
