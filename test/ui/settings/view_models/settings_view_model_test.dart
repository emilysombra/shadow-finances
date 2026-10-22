import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/ui/settings/view_models/settings_view_model.dart';

import '../../../fakes/fake_settings_repository.dart';

void main() {
  test('load traz o idioma salvo', () async {
    final viewModel = SettingsViewModel(
      settingsRepository: FakeSettingsRepository(language: AppLanguage.enUS),
    );

    await viewModel.load();

    expect(viewModel.language, AppLanguage.enUS);
  });

  test('load com falha segue o dispositivo', () async {
    final repository = FakeSettingsRepository(language: AppLanguage.enUS)
      ..shouldFail = true;
    final viewModel = SettingsViewModel(settingsRepository: repository);

    await viewModel.load();

    expect(viewModel.language, isNull);
  });

  test('setLanguage atualiza o estado, avisa a UI e salva', () async {
    final repository = FakeSettingsRepository();
    final viewModel = SettingsViewModel(settingsRepository: repository);
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.setLanguage(AppLanguage.fr);

    expect(viewModel.language, AppLanguage.fr);
    expect(repository.language, AppLanguage.fr);
    expect(notifications, 1);
  });

  test('setLanguage desfaz a troca se não conseguir salvar', () async {
    final repository = FakeSettingsRepository()..shouldFail = true;
    final viewModel = SettingsViewModel(settingsRepository: repository);

    await viewModel.setLanguage(AppLanguage.fr);

    expect(viewModel.language, isNull);
  });
}
