import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shadow_finances/routing/routes.dart';
import 'package:shadow_finances/ui/home/view_models/home_view_model.dart';
import 'package:shadow_finances/ui/home/widgets/home_screen.dart';
import 'package:shadow_finances/ui/settings/widgets/settings_screen.dart';
import 'package:shadow_finances/ui/transactions/view_models/transactions_view_model.dart';
import 'package:shadow_finances/ui/transactions/widgets/transactions_screen.dart';

/// Cria a tela de cada rota, entregando a ela o seu ViewModel.
Route<void> onGenerateRoute(
  RouteSettings settings, {
  required String appTitle,
}) {
  return MaterialPageRoute(
    settings: settings,
    builder: (context) => switch (settings.name) {
      Routes.settings => SettingsScreen(viewModel: context.read()),
      Routes.transactions => _withViewModel(
        (context) => TransactionsViewModel(
          clock: context.read(),
          getPeriodOverview: context.read(),
          periodFilterRepository: context.read(),
        )..load(),
        (viewModel) => TransactionsScreen(viewModel: viewModel),
      ),
      _ => _withViewModel(
        (context) => HomeViewModel(
          clock: context.read(),
          getPeriodOverview: context.read(),
          periodFilterRepository: context.read(),
        )..load(),
        (viewModel) => HomeScreen(appTitle: appTitle, viewModel: viewModel),
      ),
    },
  );
}

/// Cria o ViewModel de uma tela e o entrega a ela pelo construtor.
///
/// O `ChangeNotifierProvider` cuida do ciclo de vida: cria o ViewModel uma
/// vez e chama `dispose()` quando a tela sai da pilha de navegação, para que
/// ele pare de escutar o estado compartilhado.
Widget _withViewModel<T extends ChangeNotifier>(
  T Function(BuildContext context) create,
  Widget Function(T viewModel) screen,
) {
  return ChangeNotifierProvider<T>(
    create: create,
    child: Builder(builder: (context) => screen(context.read<T>())),
  );
}
