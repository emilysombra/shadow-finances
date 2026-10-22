import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:shadow_finances/data/repositories/account/account_repository.dart';
import 'package:shadow_finances/data/repositories/account/account_repository_static.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository_static.dart';
import 'package:shadow_finances/data/repositories/income/income_repository.dart';
import 'package:shadow_finances/data/repositories/income/income_repository_static.dart';
import 'package:shadow_finances/data/repositories/settings/settings_repository.dart';
import 'package:shadow_finances/data/repositories/settings/settings_repository_local.dart';
import 'package:shadow_finances/data/services/shared_preferences_service.dart';
import 'package:shadow_finances/ui/settings/view_models/settings_view_model.dart';

/// Cria as dependências do app e carrega o estado global antes da primeira
/// tela, para que ela já abra no idioma salvo.
Future<List<SingleChildWidget>> createDependencies() async {
  final settingsRepository = SettingsRepositoryLocal(
    preferences: SharedPreferencesService(),
  );
  return providersFor(
    settingsRepository: settingsRepository,
    // Dados fixos até o app salvar contas, receitas e despesas.
    accountRepository: AccountRepositoryStatic(),
    incomeRepository: IncomeRepositoryStatic(),
    expenseRepository: ExpenseRepositoryStatic(),
  );
}

/// Monta os providers a partir dos Repositories. Separado de
/// [createDependencies] para que os testes passem implementações falsas.
Future<List<SingleChildWidget>> providersFor({
  required SettingsRepository settingsRepository,
  required AccountRepository accountRepository,
  required IncomeRepository incomeRepository,
  required ExpenseRepository expenseRepository,
}) async {
  final settingsViewModel = SettingsViewModel(
    settingsRepository: settingsRepository,
  );
  await settingsViewModel.load();

  return [
    Provider<SettingsRepository>.value(value: settingsRepository),
    Provider<AccountRepository>.value(value: accountRepository),
    Provider<IncomeRepository>.value(value: incomeRepository),
    Provider<ExpenseRepository>.value(value: expenseRepository),
    ChangeNotifierProvider.value(value: settingsViewModel),
  ];
}
