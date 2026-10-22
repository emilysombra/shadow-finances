import 'package:flutter/material.dart';

import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/widgets/page_body.dart';
import 'package:shadow_finances/ui/core/widgets/period_overview_scroll_view.dart';
import 'package:shadow_finances/ui/transactions/view_models/transactions_view_model.dart';

/// Tela de transações: o mesmo conteúdo da tela inicial, com a lista
/// completa do período.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key, required this.viewModel});

  final TransactionsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactionsTitle)),
      body: PageBody(
        child: ListenableBuilder(
          listenable: viewModel,
          // Sem título de lista: a barra do topo já diz "Transações".
          builder: (context, _) => PeriodOverviewScrollView(
            filter: viewModel.filter,
            range: viewModel.range,
            summary: viewModel.summary,
            hasError: viewModel.hasError,
            transactions: viewModel.transactions,
            onFilterSelected: viewModel.selectFilter,
          ),
        ),
      ),
    );
  }
}
