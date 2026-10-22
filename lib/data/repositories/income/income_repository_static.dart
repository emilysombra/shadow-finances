import 'package:shadow_finances/data/repositories/income/income_repository.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/result.dart';

/// [IncomeRepository] provisório, com receitas fictícias fixas, enquanto o
/// app ainda não salva receitas. Será substituído por uma implementação com
/// armazenamento local; só `config/dependencies.dart` precisa mudar.
class IncomeRepositoryStatic implements IncomeRepository {
  // Mesma conta de AccountRepositoryStatic (conferido nos testes).
  static const _accountId = 'main';

  // Dados fictícios. Descrições são dados do usuário, por isso não são
  // traduzidas.
  static final incomes = [
    Income.initialBalance(
      id: 'i1',
      amountCents: 120000,
      date: DateTime(2026, 10, 1),
      accountId: _accountId,
    ),
    Income(
      id: 'i2',
      description: 'Salário',
      amountCents: 650000,
      date: DateTime(2026, 10, 3),
      category: IncomeCategory.salary,
      accountId: _accountId,
    ),
    Income(
      id: 'i3',
      description: 'Projeto de site',
      amountCents: 180000,
      date: DateTime(2026, 10, 14),
      category: IncomeCategory.freelance,
      accountId: _accountId,
    ),
    Income(
      id: 'i4',
      description: 'Reembolso de passagem',
      amountCents: 4590,
      date: DateTime(2026, 10, 17),
      category: IncomeCategory.refund,
      accountId: _accountId,
    ),
  ];

  @override
  Future<Result<List<Income>>> getIncomes() async {
    final sorted = [...incomes]..sort((a, b) => b.date.compareTo(a.date));
    return Result.ok(sorted);
  }
}
