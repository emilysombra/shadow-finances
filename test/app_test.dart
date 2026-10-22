import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadow_finances/app.dart';
import 'package:shadow_finances/config/dependencies.dart';
import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/domain/models/account_summary.dart';
import 'package:shadow_finances/domain/models/app_theme_mode.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

import 'fakes/fake_account_repository.dart';
import 'fakes/fake_expense_repository.dart';
import 'fakes/fake_income_repository.dart';
import 'fakes/fake_settings_repository.dart';
import 'fakes/fixed_clock.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    required List<Locale> deviceLocales,
    FakeSettingsRepository? repository,
    FakeAccountRepository? accountRepository,
    FakeIncomeRepository? incomeRepository,
    FakeExpenseRepository? expenseRepository,
  }) async {
    tester.platformDispatcher.localesTestValue = deviceLocales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final providers = await providersFor(
      clock: FixedClock(DateTime(2026, 10, 22)),
      settingsRepository: repository ?? FakeSettingsRepository(),
      accountRepository: accountRepository ?? FakeAccountRepository(),
      incomeRepository: incomeRepository ?? FakeIncomeRepository(),
      expenseRepository: expenseRepository ?? FakeExpenseRepository(),
    );
    await tester.pumpWidget(
      MultiProvider(providers: providers, child: const ShadowFinancesApp()),
    );
    await tester.pumpAndSettle();
  }

  /// Valores em reais como o intl formata (espaço não separável após "R$").
  String brl(String value) => 'R\$\u00a0$value';

  testWidgets('tela inicial exibe o nome do app', (tester) async {
    await pumpApp(tester, deviceLocales: const [Locale('pt', 'BR')]);

    expect(find.text('Shadow Finances'), findsOneWidget);
  });

  testWidgets(
    'card mostra os totais guardados da conta; lista mostra as transações',
    (tester) async {
      await pumpApp(
        tester,
        deviceLocales: const [Locale('pt', 'BR')],
        accountRepository: FakeAccountRepository(
          summaries: [
            const AccountSummary(
              account: FakeAccountRepository.account,
              summary: PeriodSummary(
                previousBalanceCents: 0,
                totals: FinancialSummary(
                  incomeCents: 10000,
                  expensesCents: 2500,
                ),
              ),
            ),
          ],
        ),
        incomeRepository: FakeIncomeRepository(
          incomes: [
            Income.initialBalance(
              id: 'i1',
              amountCents: 10000,
              date: DateTime(2026, 10, 1),
              accountId: FakeAccountRepository.account.id,
            ),
          ],
        ),
        expenseRepository: FakeExpenseRepository(
          expenses: [
            Expense(
              id: '1',
              description: 'Padaria',
              amountCents: 1500,
              date: DateTime(2026, 10, 21),
              accountId: FakeAccountRepository.account.id,
              category: ExpenseCategory.food,
            ),
            Expense(
              id: '2',
              description: 'Ônibus',
              amountCents: 1000,
              date: DateTime(2026, 10, 20),
              accountId: FakeAccountRepository.account.id,
              category: ExpenseCategory.transport,
            ),
          ],
        ),
      );

      expect(find.text(brl('100,00')), findsOneWidget, reason: 'receitas');
      expect(find.text(brl('25,00')), findsOneWidget, reason: 'despesas');
      expect(find.text(brl('75,00')), findsOneWidget, reason: 'saldo');
      expect(find.text('Transações'), findsOneWidget);
      expect(find.text('Padaria'), findsOneWidget);
      expect(find.text('Alimentação · 21/10/2026'), findsOneWidget);
      expect(find.text('-${brl('15,00')}'), findsOneWidget);
      expect(find.text('Ônibus'), findsOneWidget);

      // A lista só constrói as linhas visíveis: rola até a última.
      await tester.scrollUntilVisible(find.text('Saldo inicial'), 100);
      expect(find.text('Saldo inicial'), findsOneWidget);
      expect(find.text('+${brl('100,00')}'), findsOneWidget);
    },
  );

  testWidgets('sem transações no período, avisa que a lista está vazia', (
    tester,
  ) async {
    await pumpApp(tester, deviceLocales: const [Locale('pt', 'BR')]);

    expect(find.text('Nenhuma transação neste período.'), findsOneWidget);
  });

  testWidgets('filtros: começa no mês atual e trocar muda a tela inteira', (
    tester,
  ) async {
    final accountRepository = FakeAccountRepository();
    await pumpApp(
      tester,
      deviceLocales: const [Locale('pt', 'BR')],
      accountRepository: accountRepository,
      expenseRepository: FakeExpenseRepository(
        expenses: [
          Expense(
            id: '1',
            description: 'Mês passado',
            amountCents: 1000,
            date: DateTime(2026, 9, 10),
            accountId: FakeAccountRepository.account.id,
            category: ExpenseCategory.other,
          ),
        ],
      ),
    );

    expect(find.text('01/10/2026 – 31/10/2026'), findsOneWidget);
    expect(find.text('Mês passado'), findsNothing);

    await tester.tap(find.text('Ano atual'));
    await tester.pumpAndSettle();

    expect(find.text('01/01/2026 – 31/12/2026'), findsOneWidget);
    expect(find.text('Mês passado'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Ano atual'))
          .selected,
      isTrue,
    );

    await tester.tap(find.text('Últimos 7 dias'));
    await tester.pumpAndSettle();

    expect(find.text('16/10/2026 – 22/10/2026'), findsOneWidget);
    expect(find.text('Mês passado'), findsNothing);
  });

  testWidgets('avisa se os dados não carregarem', (tester) async {
    await pumpApp(
      tester,
      deviceLocales: const [Locale('pt', 'BR')],
      expenseRepository: FakeExpenseRepository()..shouldFail = true,
    );

    expect(
      find.text('Não foi possível carregar suas finanças.'),
      findsOneWidget,
    );
    expect(find.text('Saldo'), findsNothing);
    expect(
      find.text('Ano atual'),
      findsOneWidget,
      reason: 'o seletor continua visível para trocar de período',
    );
  });

  testWidgets('segue o idioma do dispositivo', (tester) async {
    await pumpApp(tester, deviceLocales: const [Locale('pt', 'PT')]);

    expect(find.byTooltip('Definições'), findsOneWidget);
  });

  testWidgets('usa pt-BR se o idioma do dispositivo não é suportado', (
    tester,
  ) async {
    await pumpApp(tester, deviceLocales: const [Locale('de', 'DE')]);

    expect(find.byTooltip('Configurações'), findsOneWidget);
  });

  testWidgets('idioma salvo tem prioridade sobre o do dispositivo', (
    tester,
  ) async {
    await pumpApp(
      tester,
      deviceLocales: const [Locale('pt', 'BR')],
      repository: FakeSettingsRepository(language: AppLanguage.fr),
    );

    expect(find.byTooltip('Paramètres'), findsOneWidget);
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
