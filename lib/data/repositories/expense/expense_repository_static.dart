import 'package:shadow_finances/data/repositories/expense/expense_repository.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/utils/result.dart';

/// [ExpenseRepository] provisório, com despesas fictícias fixas, enquanto o
/// app ainda não salva despesas. Será substituído por uma implementação com
/// armazenamento local; só `config/dependencies.dart` precisa mudar.
class ExpenseRepositoryStatic implements ExpenseRepository {
  // Mesma conta de AccountRepositoryStatic (conferido nos testes).
  static const _accountId = 'main';

  // Dados fictícios. Descrições são dados do usuário, por isso não são
  // traduzidas.
  static final expenses = [
    Expense(
      id: '1',
      description: 'Aluguel',
      amountCents: 180000,
      date: DateTime(2026, 10, 5),
      accountId: _accountId,
      category: ExpenseCategory.housing,
    ),
    Expense(
      id: '2',
      description: 'Curso de inglês',
      amountCents: 35000,
      date: DateTime(2026, 10, 8),
      accountId: _accountId,
      category: ExpenseCategory.education,
    ),
    Expense(
      id: '3',
      description: 'Conta de luz',
      amountCents: 21450,
      date: DateTime(2026, 10, 10),
      accountId: _accountId,
      category: ExpenseCategory.housing,
    ),
    Expense(
      id: '4',
      description: 'Cinema',
      amountCents: 6400,
      date: DateTime(2026, 10, 12),
      accountId: _accountId,
      category: ExpenseCategory.leisure,
    ),
    Expense(
      id: '5',
      description: 'Farmácia',
      amountCents: 8990,
      date: DateTime(2026, 10, 15),
      accountId: _accountId,
      category: ExpenseCategory.health,
    ),
    Expense(
      id: '6',
      description: 'Corrida de aplicativo',
      amountCents: 3280,
      date: DateTime(2026, 10, 18),
      accountId: _accountId,
      category: ExpenseCategory.transport,
    ),
    Expense(
      id: '7',
      description: 'Supermercado',
      amountCents: 45890,
      date: DateTime(2026, 10, 20),
      accountId: _accountId,
      category: ExpenseCategory.food,
    ),
    Expense(
      id: '8',
      description: 'Restaurante',
      amountCents: 12750,
      date: DateTime(2026, 10, 21),
      accountId: _accountId,
      category: ExpenseCategory.food,
    ),
  ];

  @override
  Future<Result<List<Expense>>> getExpenses() async {
    final sorted = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
    return Result.ok(sorted);
  }
}
