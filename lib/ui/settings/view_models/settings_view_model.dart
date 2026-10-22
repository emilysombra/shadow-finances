import 'package:flutter/foundation.dart';

import 'package:shadow_finances/data/repositories/settings/settings_repository.dart';
import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/utils/result.dart';

/// Estado das preferências do usuário.
///
/// É global (registrado em `config/dependencies.dart`) porque o idioma afeta
/// o app inteiro, não só a tela de configurações.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required this._settingsRepository});

  final SettingsRepository _settingsRepository;

  AppLanguage? _language;

  /// Idioma escolhido; `null` significa seguir o idioma do dispositivo.
  AppLanguage? get language => _language;

  /// Carrega as preferências salvas. Em caso de falha, segue o dispositivo.
  Future<void> load() async {
    final result = await _settingsRepository.getLanguage();
    if (result case Ok(:final value)) {
      _language = value;
      notifyListeners();
    }
  }

  /// Troca o idioma imediatamente e salva a escolha. Se não for possível
  /// salvar, desfaz a troca.
  Future<void> setLanguage(AppLanguage? language) async {
    if (language == _language) return;

    final previous = _language;
    _language = language;
    notifyListeners();

    final result = await _settingsRepository.setLanguage(language);
    if (result is Failure) {
      _language = previous;
      notifyListeners();
    }
  }
}
