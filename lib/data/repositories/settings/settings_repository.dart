import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/domain/models/app_theme_mode.dart';
import 'package:shadow_finances/utils/result.dart';

/// Fonte da verdade das preferências do usuário.
abstract class SettingsRepository {
  /// Idioma escolhido pelo usuário; `null` significa seguir o dispositivo.
  Future<Result<AppLanguage?>> getLanguage();

  /// Salva o idioma escolhido; `null` volta a seguir o dispositivo.
  Future<Result<void>> setLanguage(AppLanguage? language);

  /// Tema escolhido pelo usuário; `null` significa seguir o dispositivo.
  Future<Result<AppThemeMode?>> getThemeMode();

  /// Salva o tema escolhido; `null` volta a seguir o dispositivo.
  Future<Result<void>> setThemeMode(AppThemeMode? themeMode);
}
