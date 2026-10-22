import 'package:shadow_finances/data/repositories/settings/settings_repository.dart';
import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/utils/result.dart';

/// [SettingsRepository] em memória para testes.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({this.language});

  AppLanguage? language;

  /// Quando `true`, todas as operações falham.
  bool shouldFail = false;

  @override
  Future<Result<AppLanguage?>> getLanguage() async {
    if (shouldFail) return Result.failure(Exception('falha simulada'));
    return Result.ok(language);
  }

  @override
  Future<Result<void>> setLanguage(AppLanguage? language) async {
    if (shouldFail) return Result.failure(Exception('falha simulada'));
    this.language = language;
    return const Result.ok(null);
  }
}
