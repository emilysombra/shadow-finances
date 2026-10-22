import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';

/// Nome traduzido de cada [ExpenseCategory].
extension ExpenseCategoryLabel on ExpenseCategory {
  String label(AppLocalizations l10n) => switch (this) {
    ExpenseCategory.food => l10n.expenseCategoryFood,
    ExpenseCategory.transport => l10n.expenseCategoryTransport,
    ExpenseCategory.housing => l10n.expenseCategoryHousing,
    ExpenseCategory.health => l10n.expenseCategoryHealth,
    ExpenseCategory.leisure => l10n.expenseCategoryLeisure,
    ExpenseCategory.education => l10n.expenseCategoryEducation,
    ExpenseCategory.shopping => l10n.expenseCategoryShopping,
    ExpenseCategory.other => l10n.expenseCategoryOther,
  };
}

/// Nome traduzido de cada [IncomeCategory].
extension IncomeCategoryLabel on IncomeCategory {
  String label(AppLocalizations l10n) => switch (this) {
    IncomeCategory.salary => l10n.incomeCategorySalary,
    IncomeCategory.freelance => l10n.incomeCategoryFreelance,
    IncomeCategory.investments => l10n.incomeCategoryInvestments,
    IncomeCategory.gift => l10n.incomeCategoryGift,
    IncomeCategory.refund => l10n.incomeCategoryRefund,
    IncomeCategory.initialBalance => l10n.incomeCategoryInitialBalance,
    IncomeCategory.other => l10n.incomeCategoryOther,
  };
}
