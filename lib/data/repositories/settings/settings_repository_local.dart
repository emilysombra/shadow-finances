import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/domain/models/app_theme_mode.dart';
import 'package:shadow_finances/utils/result.dart';
import 'package:shadow_finances/data/services/shared_preferences_service.dart';
import 'package:shadow_finances/data/repositories/settings/settings_repository.dart';

/// [SettingsRepository] que guarda as preferências no próprio dispositivo.
class SettingsRepositoryLocal implements SettingsRepository {
  SettingsRepositoryLocal({required this._preferences});

  static const _languageKey = 'language';
  static const _themeModeKey = 'themeMode';

  final SharedPreferencesService _preferences;

  @override
  Future<Result<AppLanguage?>> getLanguage() =>
      _getEnum(_languageKey, AppLanguage.values);

  @override
  Future<Result<void>> setLanguage(AppLanguage? language) =>
      _setEnum(_languageKey, language);

  @override
  Future<Result<AppThemeMode?>> getThemeMode() =>
      _getEnum(_themeModeKey, AppThemeMode.values);

  @override
  Future<Result<void>> setThemeMode(AppThemeMode? themeMode) =>
      _setEnum(_themeModeKey, themeMode);

  /// Lê um enum salvo pelo nome. Valor desconhecido (ex.: opção removida do
  /// app) vira `null`, isto é, volta a seguir o dispositivo em vez de quebrar.
  Future<Result<T?>> _getEnum<T extends Enum>(
    String key,
    List<T> values,
  ) async {
    try {
      final stored = await _preferences.getString(key);
      return Result.ok(stored == null ? null : values.asNameMap()[stored]);
    } on Exception catch (error) {
      return Result.failure(error);
    }
  }

  /// Salva um enum pelo nome; `null` apaga a escolha.
  Future<Result<void>> _setEnum(String key, Enum? value) async {
    try {
      if (value == null) {
        await _preferences.remove(key);
      } else {
        await _preferences.setString(key, value.name);
      }
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.failure(error);
    }
  }
}
