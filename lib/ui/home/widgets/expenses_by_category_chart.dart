import 'package:flutter/material.dart';

import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/formatting/br_format.dart';
import 'package:shadow_finances/ui/core/l10n/category_label.dart';
import 'package:shadow_finances/ui/core/themes/app_spacing.dart';
import 'package:shadow_finances/ui/core/themes/finance_colors.dart';

/// Gráfico de barras horizontais com o gasto de cada categoria no período,
/// da maior para a menor.
///
/// Escolhas (ver skill de visualização de dados):
/// - Barras, não pizza: o leitor compara tamanhos, e barras alinhadas na
///   mesma base mostram diferenças pequenas que fatias escondem.
/// - Uma cor só (a de despesa) para todas as barras: a categoria já está
///   escrita ao lado, então cor por categoria não acrescentaria nada.
/// - Cada linha é texto de verdade (nome, valor, porcentagem), que cresce
///   com a fonte do sistema e é lido pelo leitor de tela; a barra é só o
///   reforço visual.
class ExpensesByCategoryChart extends StatelessWidget {
  const ExpensesByCategoryChart({super.key, required this.expenses});

  /// Gasto por categoria, já em ordem decrescente.
  final List<({ExpenseCategory category, int cents})> expenses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);

    if (expenses.isEmpty) {
      return Text(
        l10n.chartExpensesByCategoryEmpty,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final total = expenses.fold(0, (sum, e) => sum + e.cents);
    final largest = expenses.first.cents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, expense) in expenses.indexed) ...[
          if (index > 0) SizedBox(height: spacing.md),
          _CategoryBar(
            label: expense.category.label(l10n),
            cents: expense.cents,
            share: expense.cents / total,
            relativeSize: expense.cents / largest,
          ),
        ],
      ],
    );
  }
}

/// Uma linha do gráfico: nome e valores em cima, barra embaixo.
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({
    required this.label,
    required this.cents,
    required this.share,
    required this.relativeSize,
  });

  final String label;
  final int cents;

  /// Fração do total de gastos (para a porcentagem).
  final double share;

  /// Tamanho em relação à maior categoria (para o comprimento da barra).
  final double relativeSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = AppSpacing.of(context);

    // MergeSemantics: o leitor de tela anuncia "Moradia, R$ 1.800,00, 57%".
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wrap: com fonte grande, os valores descem para a linha de baixo.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: spacing.sm,
            children: [
              Text(label, style: theme.textTheme.bodyMedium),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: BrFormat.currency(cents),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: BrFormat.percent(share),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          // A barra sai sempre da mesma base (esquerda), com a ponta
          // arredondada e a base reta.
          ExcludeSemantics(
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: relativeSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: FinanceColors.of(context).expense,
                  borderRadius: BorderRadiusDirectional.horizontal(
                    end: Radius.circular(spacing.xs),
                  ),
                ),
                child: SizedBox(height: spacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
