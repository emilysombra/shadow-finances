import 'package:shadow_finances/data/services/shared_preferences_service.dart';

/// [SharedPreferencesService] em memória para testes.
class FakeSharedPreferencesService implements SharedPreferencesService {
  final Map<String, String> values = {};

  /// Quando `true`, todas as operações lançam exceção, como a plataforma faria.
  bool shouldThrow = false;

  @override
  Future<String?> getString(String key) async {
    _maybeThrow();
    return values[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    _maybeThrow();
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _maybeThrow();
    values.remove(key);
  }

  void _maybeThrow() {
    if (shouldThrow) throw Exception('falha simulada');
  }
}
