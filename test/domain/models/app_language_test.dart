import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/app_language.dart';

({String languageCode, String? countryCode}) device(
  String languageCode, [
  String? countryCode,
]) => (languageCode: languageCode, countryCode: countryCode);

void main() {
  group('AppLanguage.resolve', () {
    test('usa o idioma e país exatos', () {
      expect(AppLanguage.resolve([device('pt', 'PT')]), AppLanguage.ptPT);
      expect(AppLanguage.resolve([device('en', 'US')]), AppLanguage.enUS);
      expect(AppLanguage.resolve([device('es', '419')]), AppLanguage.es419);
    });

    test('português fora de Portugal vira pt-BR', () {
      expect(AppLanguage.resolve([device('pt')]), AppLanguage.ptBR);
      expect(AppLanguage.resolve([device('pt', 'AO')]), AppLanguage.ptBR);
    });

    test('qualquer variante suportada do idioma é aproveitada', () {
      expect(AppLanguage.resolve([device('es', 'ES')]), AppLanguage.es419);
      expect(AppLanguage.resolve([device('en', 'GB')]), AppLanguage.enUS);
      expect(AppLanguage.resolve([device('fr', 'CA')]), AppLanguage.fr);
    });

    test('respeita a ordem de preferência do dispositivo', () {
      expect(
        AppLanguage.resolve([device('de', 'DE'), device('fr', 'FR')]),
        AppLanguage.fr,
      );
    });

    test('cai em pt-BR se nenhum idioma for suportado', () {
      expect(AppLanguage.resolve([device('de', 'DE')]), AppLanguage.ptBR);
      expect(AppLanguage.resolve([]), AppLanguage.ptBR);
    });
  });
}
