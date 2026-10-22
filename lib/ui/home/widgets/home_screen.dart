import 'package:flutter/material.dart';

import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/routing/routes.dart';
import 'package:shadow_finances/ui/core/widgets/page_body.dart';
import 'package:shadow_finances/ui/core/widgets/period_overview_scroll_view.dart';
import 'package:shadow_finances/ui/home/view_models/home_view_model.dart';

/// Tela inicial: seletor de período, resumo e as transações mais recentes,
/// com um botão para a lista completa.
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
          builder: (context, _) => PeriodOverviewScrollView(
            filter: viewModel.filter,
            range: viewModel.range,
            summary: viewModel.summary,
            hasError: viewModel.hasError,
            transactions: viewModel.recentTransactions,
            onFilterSelected: viewModel.selectFilter,
            listTitle: l10n.transactionsTitle,
            footer: Center(
              child: FilledButton.tonalIcon(
                // O filtro é compartilhado: a tela completa já abre nele.
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.transactions),
                icon: const Icon(Icons.arrow_forward),
                iconAlignment: IconAlignment.end,
                label: Text(l10n.viewAllTransactions),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
