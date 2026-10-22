import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadow_finances/app.dart';
import 'package:shadow_finances/config/dependencies.dart';
import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/domain/models/app_theme_mode.dart';

import 'fakes/fake_settings_repository.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    required List<Locale> deviceLocales,
    FakeSettingsRepository? repository,
  }) async {
    tester.platformDispatcher.localesTestValue = deviceLocales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final providers = await providersFor(
      settingsRepository: repository ?? FakeSettingsRepository(),
    );
    await tester.pumpWidget(
      MultiProvider(providers: providers, child: const ShadowFinancesApp()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tela inicial exibe o nome do app', (tester) async {
    await pumpApp(tester, deviceLocales: const [Locale('pt', 'BR')]);

    expect(find.text('Shadow Finances'), findsOneWidget);
    expect(find.text('Suas finanças em um só lugar.'), findsOneWidget);
  });

  testWidgets('segue o idioma do dispositivo', (tester) async {
    await pumpApp(tester, deviceLocales: const [Locale('pt', 'PT')]);

    expect(find.text('As suas finanças num só lugar.'), findsOneWidget);
  });

  testWidgets('usa pt-BR se o idioma do dispositivo não é suportado', (
    tester,
  ) async {
    await pumpApp(tester, deviceLocales: const [Locale('de', 'DE')]);

    expect(find.text('Suas finanças em um só lugar.'), findsOneWidget);
  });

  testWidgets('idioma salvo tem prioridade sobre o do dispositivo', (
    tester,
  ) async {
    await pumpApp(
      tester,
      deviceLocales: const [Locale('pt', 'BR')],
      repository: FakeSettingsRepository(language: AppLanguage.fr),
    );

    expect(find.text('Vos finances en un seul endroit.'), findsOneWidget);
  });

  testWidgets('trocar o idioma nas configurações muda o app e salva', (
    tester,
  ) async {
    final repository = FakeSettingsRepository();
    await pumpApp(
      tester,
      deviceLocales: const [Locale('pt', 'BR')],
      repository: repository,
    );

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<RadioGroup<AppLanguage?>>(
            find.byType(RadioGroup<AppLanguage?>),
          )
          .groupValue,
      isNull,
      reason: 'sem escolha salva, "usar idioma do dispositivo" fica marcado',
    );

    await tester.tap(find.text('English (US)'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(repository.language, AppLanguage.enUS);

    await tester.tap(find.text('Use device language'));
    await tester.pumpAndSettle();

    expect(find.text('Configurações'), findsOneWidget);
    expect(repository.language, isNull);
  });

  testWidgets('trocar o tema nas configurações muda o app e salva', (
    tester,
  ) async {
    final repository = FakeSettingsRepository();
    await pumpApp(
      tester,
      deviceLocales: const [Locale('pt', 'BR')],
      repository: repository,
    );
    ThemeMode appThemeMode() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

    expect(appThemeMode(), ThemeMode.system);

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escuro'));
    await tester.pumpAndSettle();

    expect(appThemeMode(), ThemeMode.dark);
    expect(repository.themeMode, AppThemeMode.dark);

    await tester.tap(find.text('Usar tema do dispositivo'));
    await tester.pumpAndSettle();

    expect(appThemeMode(), ThemeMode.system);
    expect(repository.themeMode, isNull);
  });

  testWidgets('tema salvo é aplicado ao abrir o app', (tester) async {
    await pumpApp(
      tester,
      deviceLocales: const [Locale('pt', 'BR')],
      repository: FakeSettingsRepository(themeMode: AppThemeMode.light),
    );

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}
