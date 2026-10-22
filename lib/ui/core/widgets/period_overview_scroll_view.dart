import 'package:flutter/material.dart';

import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/formatting/br_format.dart';
import 'package:shadow_finances/ui/core/themes/app_spacing.dart';
import 'package:shadow_finances/ui/core/widgets/balance_summary_card.dart';
import 'package:shadow_finances/ui/core/widgets/period_filter_chips.dart';
import 'package:shadow_finances/ui/core/widgets/section_header.dart';
import 'package:shadow_finances/ui/core/widgets/transaction_list_tile.dart';

/// Conteúdo rolável de uma tela de período: seletor de período e intervalo,
/// card de resumo (ou carregamento / erro), lista de transações e um rodapé
/// opcional. Usado pela tela inicial e pela tela de transações.
///
/// Recebe tudo por parâmetro: só a tela conhece o ViewModel.
class PeriodOverviewScrollView extends StatelessWidget {
  const PeriodOverviewScrollView({
    super.key,
    required this.filter,
    required this.range,
    required this.summary,
    required this.hasError,
    required this.transactions,
    required this.onFilterSelected,
    this.listTitle,
    this.footer,
  });

  final PeriodFilter filter;
  final DateRange range;

  /// `null` enquanto carrega ou se o carregamento falhou.
  final PeriodSummary? summary;
  final bool hasError;
  final List<Transaction> transactions;
  final ValueChanged<PeriodFilter> onFilterSelected;

  /// Cabeçalho da lista; sem ele, a lista começa logo após o card.
  final String? listTitle;

  /// Mostrado ao fim da lista, quando os dados carregaram.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = AppSpacing.of(context);
    final summary = this.summary;
    final listTitle = this.listTitle;
    final footer = this.footer;

    // CustomScrollView + SliverList.builder: só os itens visíveis da lista
    // são construídos, o que mantém a tela leve com muitas transações.
    return CustomScrollView(
      slivers: [
        // Seletor de período sempre visível, mesmo com erro, para o usuário
        // poder trocar de período.
        SliverPadding(
          padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.md, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PeriodFilterChips(
                  selected: filter,
                  onSelected: onFilterSelected,
                ),
                SizedBox(height: spacing.sm),
                Text(
                  l10n.periodRange(
                    BrFormat.date(range.start),
                    BrFormat.date(range.end),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(spacing.md),
          sliver: SliverToBoxAdapter(
            child: summary != null
                ? BalanceSummaryCard(summary: summary)
                : hasError
                ? _Message(text: l10n.homeLoadError)
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
        if (summary != null) ...[
          if (listTitle != null)
            SliverToBoxAdapter(child: SectionHeader(title: listTitle)),
          if (transactions.isEmpty)
            SliverToBoxAdapter(child: _Message(text: l10n.transactionsEmpty))
          else
            SliverList.builder(
              itemCount: transactions.length,
              // A chave é a transação inteira, não só o id: receitas e
              // despesas podem ter ids iguais entre si.
              itemBuilder: (context, index) => TransactionListTile(
                key: ValueKey(transactions[index]),
                transaction: transactions[index],
              ),
            ),
          if (footer != null)
            SliverPadding(
              padding: EdgeInsets.all(spacing.md),
              sliver: SliverToBoxAdapter(child: footer),
            ),
        ],
      ],
    );
  }
}

/// Texto informativo centralizado (lista vazia, erro de carregamento).
class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.of(context).lg),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
