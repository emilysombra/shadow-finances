import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/account/account_repository_static.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository_static.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

void main() {
  test(
    'devolve todas as despesas fixas, das mais recentes às mais antigas',
    () async {
      final result = await ExpenseRepositoryStatic().getExpenses();
      final expenses = (result as Ok<List<Expense>>).value;

      expect(expenses, unorderedEquals(ExpenseRepositoryStatic.expenses));
      for (var i = 1; i < expenses.length; i++) {
        expect(expenses[i - 1].date.isBefore(expenses[i].date), isFalse);
      }
    },
  );

  test('ids são únicos', () {
    final ids = ExpenseRepositoryStatic.expenses.map((e) => e.id);
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('todas as despesas são da conta de AccountRepositoryStatic', () {
    expect(ExpenseRepositoryStatic.expenses.map((e) => e.accountId).toSet(), {
      AccountRepositoryStatic.mainAccount.id,
    });
  });
}
