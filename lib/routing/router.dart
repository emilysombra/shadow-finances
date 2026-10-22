import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shadow_finances/routing/routes.dart';
import 'package:shadow_finances/ui/home/widgets/home_screen.dart';
import 'package:shadow_finances/ui/settings/widgets/settings_screen.dart';

/// Cria a tela de cada rota, entregando a ela o seu ViewModel.
Route<void> onGenerateRoute(
  RouteSettings settings, {
  required String appTitle,
}) {
  return MaterialPageRoute(
    settings: settings,
    builder: (context) => switch (settings.name) {
      Routes.settings => SettingsScreen(viewModel: context.read()),
      _ => HomeScreen(appTitle: appTitle),
    },
  );
}
