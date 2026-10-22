import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:shadow_finances/data/repositories/account/account_repository.dart';
import 'package:shadow_finances/data/repositories/account/account_repository_static.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository_static.dart';
import 'package:shadow_finances/data/repositories/income/income_repository.dart';
import 'package:shadow_finances/data/repositories/income/income_repository_static.dart';
import 'package:shadow_finances/data/repositories/period_filter/period_filter_repository.dart';
import 'package:shadow_finances/data/repositories/period_filter/period_filter_repository_memory.dart';
import 'package:shadow_finances/data/repositories/settings/settings_repository.dart';
import 'package:shadow_finances/data/repositories/settings/settings_repository_local.dart';
import 'package:shadow_finances/data/services/sample_data_service.dart';
import 'package:shadow_finances/data/services/shared_preferences_service.dart';
import 'package:shadow_finances/domain/use_cases/get_period_overview_use_case.dart';
import 'package:shadow_finances/ui/settings/view_models/settings_view_model.dart';
import 'package:shadow_finances/utils/clock.dart';

/// Cria as dependências do app e carrega o estado global antes da primeira
/// tela, para que ela já abra no idioma salvo.
Future<List<SingleChildWidget>> createDependencies() async {
  final settingsRepository = SettingsRepositoryLocal(
    preferences: SharedPreferencesService(),
  );
  const clock = Clock();
  // Dados fictícios até o app salvar contas, receitas e despesas.
  final sampleData = SampleDataService(today: clock.now());
  return providersFor(
    clock: clock,
    settingsRepository: settingsRepository,
    accountRepository: AccountRepositoryStatic(sampleData: sampleData),
    incomeRepository: IncomeRepositoryStatic(sampleData: sampleData),
    expenseRepository: ExpenseRepositoryStatic(sampleData: sampleData),
  );
}

/// Monta os providers a partir dos Repositories. Separado de
/// [createDependencies] para que os testes passem implementações falsas.
Future<List<SingleChildWidget>> providersFor({
  required Clock clock,
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
    Provider<Clock>.value(value: clock),
    Provider<SettingsRepository>.value(value: settingsRepository),
    Provider<AccountRepository>.value(value: accountRepository),
    Provider<IncomeRepository>.value(value: incomeRepository),
    Provider<ExpenseRepository>.value(value: expenseRepository),
    // Estado compartilhado por todas as telas; só existe em memória, então
    // não depende de nada externo e os testes usam a implementação real.
    Provider<PeriodFilterRepository>.value(
      value: PeriodFilterRepositoryMemory(),
    ),
    Provider.value(
      value: GetPeriodOverviewUseCase(
        accountRepository: accountRepository,
        incomeRepository: incomeRepository,
        expenseRepository: expenseRepository,
      ),
    ),
    ChangeNotifierProvider.value(value: settingsViewModel),
  ];
}
