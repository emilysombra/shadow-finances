import 'package:flutter/material.dart';

import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/routing/routes.dart';
import 'package:shadow_finances/ui/core/themes/app_spacing.dart';
import 'package:shadow_finances/ui/core/widgets/page_body.dart';
import 'package:shadow_finances/ui/core/widgets/section_header.dart';
import 'package:shadow_finances/ui/home/view_models/home_view_model.dart';
import 'package:shadow_finances/ui/home/widgets/balance_summary_card.dart';
import 'package:shadow_finances/ui/home/widgets/transaction_list_tile.dart';

/// Tela inicial: resumo financeiro no topo e, abaixo, as transações.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.appTitle,
    required this.viewModel,
  });

  final String appTitle;
  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
          ),
        ],
      ),
      body: PageBody(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.summary != null) return _content(context);
            if (viewModel.hasError) {
              return _Message(text: l10n.homeLoadError);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);
    final transactions = viewModel.transactions;

    // CustomScrollView + SliverList.builder: só os itens visíveis da lista
    // são construídos, o que mantém a tela leve com muitas transações.
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(spacing.md),
          sliver: SliverToBoxAdapter(
            child: BalanceSummaryCard(summary: viewModel.summary!),
          ),
        ),
        SliverToBoxAdapter(child: SectionHeader(title: l10n.transactionsTitle)),
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
