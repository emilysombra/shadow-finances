import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/settings/settings_repository_local.dart';
import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/domain/models/app_theme_mode.dart';
import 'package:shadow_finances/utils/result.dart';

import '../../../fakes/fake_shared_preferences_service.dart';

void main() {
  late FakeSharedPreferencesService preferences;
  late SettingsRepositoryLocal repository;

  setUp(() {
    preferences = FakeSharedPreferencesService();
    repository = SettingsRepositoryLocal(preferences: preferences);
  });

  test('sem nada salvo, segue o dispositivo (null)', () async {
    final result = await repository.getLanguage();
    expect(
      result,
      isA<Ok<AppLanguage?>>().having((r) => r.value, 'value', isNull),
    );
  });

  test('salva e lê o idioma escolhido', () async {
    await repository.setLanguage(AppLanguage.fr);

    final result = await repository.getLanguage();
    expect(
      result,
      isA<Ok<AppLanguage?>>().having((r) => r.value, 'value', AppLanguage.fr),
    );
  });

  test('salvar null apaga a escolha', () async {
    await repository.setLanguage(AppLanguage.fr);
    await repository.setLanguage(null);

    expect(preferences.values, isEmpty);
  });

  test(
    'valor salvo desconhecido é tratado como seguir o dispositivo',
    () async {
      preferences.values['language'] = 'klingon';

      final result = await repository.getLanguage();
      expect(
        result,
        isA<Ok<AppLanguage?>>().having((r) => r.value, 'value', isNull),
      );
    },
  );

  test('erros da plataforma viram Failure em vez de exceção', () async {
    preferences.shouldThrow = true;

    expect(await repository.getLanguage(), isA<Failure<AppLanguage?>>());
    expect(await repository.setLanguage(AppLanguage.fr), isA<Failure<void>>());
  });

  group('tema', () {
    test('sem nada salvo, segue o dispositivo (null)', () async {
      final result = await repository.getThemeMode();
      expect(
        result,
        isA<Ok<AppThemeMode?>>().having((r) => r.value, 'value', isNull),
      );
    });

    test('salva e lê o tema escolhido', () async {
      await repository.setThemeMode(AppThemeMode.dark);

      final result = await repository.getThemeMode();
      expect(
        result,
        isA<Ok<AppThemeMode?>>().having(
          (r) => r.value,
          'value',
          AppThemeMode.dark,
        ),
      );
    });

    test('salvar null apaga a escolha', () async {
      await repository.setThemeMode(AppThemeMode.dark);
      await repository.setThemeMode(null);

      expect(preferences.values, isEmpty);
    });

    test('não interfere no idioma salvo', () async {
      await repository.setLanguage(AppLanguage.fr);
      await repository.setThemeMode(AppThemeMode.light);

      expect(
        await repository.getLanguage(),
        isA<Ok<AppLanguage?>>().having((r) => r.value, 'value', AppLanguage.fr),
      );
    });

    test(
      'valor salvo desconhecido é tratado como seguir o dispositivo',
      () async {
        preferences.values['themeMode'] = 'sepia';

        final result = await repository.getThemeMode();
        expect(
          result,
          isA<Ok<AppThemeMode?>>().having((r) => r.value, 'value', isNull),
        );
      },
    );

    test('erros da plataforma viram Failure em vez de exceção', () async {
      preferences.shouldThrow = true;

      expect(await repository.getThemeMode(), isA<Failure<AppThemeMode?>>());
      expect(
        await repository.setThemeMode(AppThemeMode.dark),
        isA<Failure<void>>(),
      );
    });
  });
}
