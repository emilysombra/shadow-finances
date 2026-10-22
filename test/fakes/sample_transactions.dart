import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

import 'fake_account_repository.dart';

/// Transações de teste na conta de [FakeAccountRepository], em 2026.
/// `day` é o dia de outubro; valores negativos caem em setembro.
Income testIncome(String id, int day, {int amountCents = 1000}) => Income(
  id: id,
  description: 'Receita $id',
  amountCents: amountCents,
  date: DateTime(2026, 10, day),
  accountId: FakeAccountRepository.account.id,
  category: IncomeCategory.other,
);

Expense testExpense(String id, int day, {int amountCents = 100}) => Expense(
  id: id,
  description: 'Despesa $id',
  amountCents: amountCents,
  date: DateTime(2026, 10, day),
  accountId: FakeAccountRepository.account.id,
  category: ExpenseCategory.other,
);
