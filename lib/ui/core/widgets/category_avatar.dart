import 'package:flutter/material.dart';

import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/income_category.dart';

/// Ícone de uma categoria num círculo, para listas de transações.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: colorScheme.secondaryContainer,
      foregroundColor: colorScheme.onSecondaryContainer,
      // Decorativo: o nome da categoria já aparece em texto ao lado.
      child: ExcludeSemantics(child: Icon(icon)),
    );
  }
}

/// Ícone de cada [ExpenseCategory].
extension ExpenseCategoryIcon on ExpenseCategory {
  IconData get icon => switch (this) {
    ExpenseCategory.food => Icons.restaurant_outlined,
    ExpenseCategory.transport => Icons.directions_bus_outlined,
    ExpenseCategory.housing => Icons.home_outlined,
    ExpenseCategory.health => Icons.medical_services_outlined,
    ExpenseCategory.leisure => Icons.celebration_outlined,
    ExpenseCategory.education => Icons.school_outlined,
    ExpenseCategory.shopping => Icons.shopping_bag_outlined,
    ExpenseCategory.other => Icons.category_outlined,
  };
}

/// Ícone de cada [IncomeCategory].
extension IncomeCategoryIcon on IncomeCategory {
  IconData get icon => switch (this) {
    IncomeCategory.salary => Icons.payments_outlined,
    IncomeCategory.freelance => Icons.work_outline,
    IncomeCategory.investments => Icons.trending_up,
    IncomeCategory.gift => Icons.card_giftcard_outlined,
    IncomeCategory.refund => Icons.currency_exchange,
    IncomeCategory.initialBalance => Icons.account_balance_wallet_outlined,
    IncomeCategory.other => Icons.category_outlined,
  };
}
