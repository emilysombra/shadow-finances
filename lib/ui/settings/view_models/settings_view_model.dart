import 'package:flutter/foundation.dart';

import 'package:shadow_finances/data/repositories/settings/settings_repository.dart';
import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/domain/models/app_theme_mode.dart';
import 'package:shadow_finances/utils/result.dart';

/// Estado das preferências do usuário.
///
/// É global (registrado em `config/dependencies.dart`) porque idioma e tema
/// afetam o app inteiro, não só a tela de configurações.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required this._settingsRepository});

  final SettingsRepository _settingsRepository;

  AppLanguage? _language;
  AppThemeMode? _themeMode;

  /// Idioma escolhido; `null` significa seguir o idioma do dispositivo.
  AppLanguage? get language => _language;

  /// Tema escolhido; `null` significa seguir o tema do dispositivo.
  AppThemeMode? get themeMode => _themeMode;

  /// Carrega as preferências salvas. O que falhar segue o dispositivo.
  Future<void> load() async {
    final (language, themeMode) = await (
      _settingsRepository.getLanguage(),
      _settingsRepository.getThemeMode(),
    ).wait;
    if (language case Ok(:final value)) _language = value;
    if (themeMode case Ok(:final value)) _themeMode = value;
    notifyListeners();
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

  /// Troca o tema imediatamente e salva a escolha. Se não for possível
  /// salvar, desfaz a troca.
  Future<void> setThemeMode(AppThemeMode? themeMode) async {
    if (themeMode == _themeMode) return;

    final previous = _themeMode;
    _themeMode = themeMode;
    notifyListeners();

    final result = await _settingsRepository.setThemeMode(themeMode);
    if (result is Failure) {
      _themeMode = previous;
      notifyListeners();
    }
  }
}
