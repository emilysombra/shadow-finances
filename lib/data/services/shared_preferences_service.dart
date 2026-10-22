import 'package:shared_preferences/shared_preferences.dart';

/// Acesso ao armazenamento chave-valor do dispositivo.
///
/// Não tem regras: só lê e grava. Erros de plataforma são lançados como
/// exceções e tratados pelos Repositories.
class SharedPreferencesService {
  SharedPreferencesService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  Future<String?> getString(String key) => _preferences.getString(key);

  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  Future<void> remove(String key) => _preferences.remove(key);
}
