import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/account/account_repository_static.dart';
import 'package:shadow_finances/data/repositories/income/income_repository_static.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

void main() {
  test(
    'devolve todas as receitas fixas, das mais recentes às mais antigas',
    () async {
      final result = await IncomeRepositoryStatic().getIncomes();
      final incomes = (result as Ok<List<Income>>).value;

      expect(incomes, unorderedEquals(IncomeRepositoryStatic.incomes));
      for (var i = 1; i < incomes.length; i++) {
        expect(incomes[i - 1].date.isBefore(incomes[i].date), isFalse);
      }
    },
  );

  test('ids são únicos', () {
    final ids = IncomeRepositoryStatic.incomes.map((i) => i.id);
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('todas as receitas são da conta de AccountRepositoryStatic', () {
    expect(IncomeRepositoryStatic.incomes.map((i) => i.accountId).toSet(), {
      AccountRepositoryStatic.mainAccount.id,
    });
  });

  test('inclui o saldo inicial da conta', () {
    expect(
      IncomeRepositoryStatic.incomes.where(
        (i) => i.category == IncomeCategory.initialBalance,
      ),
      hasLength(1),
    );
  });
}
