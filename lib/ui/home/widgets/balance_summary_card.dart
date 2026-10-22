import 'package:flutter/material.dart';

import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/formatting/br_format.dart';
import 'package:shadow_finances/ui/core/themes/app_spacing.dart';
import 'package:shadow_finances/ui/core/themes/finance_colors.dart';

/// Card com o saldo acumulado em destaque, o saldo que veio do período
/// anterior e, abaixo, as receitas e despesas do período.
class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({super.key, required this.summary});

  final PeriodSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = AppSpacing.of(context);
    final financeColors = FinanceColors.of(context);
    final balance = summary.balanceCents;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MergeSemantics: leitores de tela anunciam "Saldo, R$ ..." juntos.
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.summaryBalance,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    BrFormat.currency(balance),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: balance < 0
                          ? financeColors.expense
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    l10n.summaryPreviousBalance(
                      BrFormat.currency(summary.previousBalanceCents),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SummaryEntry(
                    icon: Icons.arrow_upward,
                    label: l10n.summaryIncome,
                    cents: summary.totals.incomeCents,
                    containerColor: financeColors.incomeContainer,
                    onContainerColor: financeColors.onIncomeContainer,
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: _SummaryEntry(
                    icon: Icons.arrow_downward,
                    label: l10n.summaryExpenses,
                    cents: summary.totals.expensesCents,
                    containerColor: financeColors.expenseContainer,
                    onContainerColor: financeColors.onExpenseContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Um total (receitas ou despesas) dentro de um bloco colorido.
class _SummaryEntry extends StatelessWidget {
  const _SummaryEntry({
    required this.icon,
    required this.label,
    required this.cents,
    required this.containerColor,
    required this.onContainerColor,
  });

  final IconData icon;
  final String label;
  final int cents;
  final Color containerColor;
  final Color onContainerColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final spacing = AppSpacing.of(context);

    return MergeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(spacing.radius),
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // O ícone é decorativo: o rótulo já diz o que é.
                  ExcludeSemantics(child: Icon(icon, color: onContainerColor)),
                  SizedBox(width: spacing.xs),
                  Flexible(
                    child: Text(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                        color: onContainerColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
              Text(
                BrFormat.currency(cents),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onContainerColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
