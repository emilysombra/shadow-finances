import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/utils/result.dart';
import 'package:shadow_finances/data/services/shared_preferences_service.dart';
import 'package:shadow_finances/data/repositories/settings/settings_repository.dart';

/// [SettingsRepository] que guarda as preferências no próprio dispositivo.
class SettingsRepositoryLocal implements SettingsRepository {
  SettingsRepositoryLocal({required this._preferences});

  static const _languageKey = 'language';

  final SharedPreferencesService _preferences;

  @override
  Future<Result<AppLanguage?>> getLanguage() async {
    try {
      final stored = await _preferences.getString(_languageKey);
      // Valor desconhecido (ex.: idioma removido do app) volta a seguir o
      // dispositivo em vez de quebrar.
      return Result.ok(
        stored == null ? null : AppLanguage.values.asNameMap()[stored],
      );
    } on Exception catch (error) {
      return Result.failure(error);
    }
  }

  @override
  Future<Result<void>> setLanguage(AppLanguage? language) async {
    try {
      if (language == null) {
        await _preferences.remove(_languageKey);
      } else {
        await _preferences.setString(_languageKey, language.name);
      }
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.failure(error);
    }
  }
}
