import 'package:flutter/material.dart';

import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/formatting/br_format.dart';
import 'package:shadow_finances/ui/core/l10n/category_label.dart';
import 'package:shadow_finances/ui/core/themes/app_spacing.dart';
import 'package:shadow_finances/ui/core/themes/finance_colors.dart';
import 'package:shadow_finances/ui/core/widgets/category_avatar.dart';

/// Uma receita ou despesa na lista de transações: categoria, descrição, data
/// e valor com sinal (+ entrada, - saída).
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final financeColors = FinanceColors.of(context);

    // switch sobre a classe sealed: o compilador avisa se surgir um tipo
    // novo de transação sem tratamento aqui.
    final (icon, category, signedCents, amountColor) = switch (transaction) {
      Expense(:final category, :final amountCents) => (
        category.icon,
        category.label(l10n),
        -amountCents,
        financeColors.expense,
      ),
      Income(:final category, :final amountCents) => (
        category.icon,
        category.label(l10n),
        amountCents,
        financeColors.income,
      ),
    };

    return ListTile(
      leading: CategoryAvatar(icon: icon),
      // Wrap em vez de `trailing`: descrição e valor dividem a linha quando
      // cabem; com fonte grande ou tela estreita, o valor desce para a linha
      // de baixo em vez de espremer a descrição.
      title: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.of(context).sm,
        children: [
          // Sem descrição (ex.: saldo inicial), mostra o nome da categoria.
          Text(
            transaction.description.isEmpty
                ? category
                : transaction.description,
          ),
          Text(
            BrFormat.signedCurrency(signedCents),
            style: textTheme.titleSmall?.copyWith(color: amountColor),
          ),
        ],
      ),
      subtitle: Text(
        l10n.transactionSubtitle(category, BrFormat.date(transaction.date)),
      ),
    );
  }
}
