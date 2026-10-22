import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/themes/app_theme.dart';
import 'package:shadow_finances/ui/core/themes/finance_colors.dart';
import 'package:shadow_finances/ui/home/widgets/balance_summary_card.dart';

/// O intl separa "R$" do número com um espaço não separável.
const nbsp = '\u00a0';

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    PeriodSummary summary, {
    ThemeData? theme,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: BalanceSummaryCard(summary: summary)),
      ),
    );
  }

  Color? colorOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style?.color;

  testWidgets('mostra saldo, receitas e despesas formatados', (tester) async {
    await pumpCard(
      tester,
      const PeriodSummary(
        previousBalanceCents: 0,
        totals: FinancialSummary(incomeCents: 850000, expensesCents: 523490),
      ),
    );

    expect(find.text('Saldo'), findsOneWidget);
    expect(find.text('R\$${nbsp}3.265,10'), findsOneWidget);
    expect(find.text('Receitas'), findsOneWidget);
    expect(find.text('R\$${nbsp}8.500,00'), findsOneWidget);
    expect(find.text('Despesas'), findsOneWidget);
    expect(find.text('R\$${nbsp}5.234,90'), findsOneWidget);
  });

  testWidgets('saldo negativo usa a cor de despesa', (tester) async {
    await pumpCard(
      tester,
      const PeriodSummary(
        previousBalanceCents: 0,
        totals: FinancialSummary(incomeCents: 1000, expensesCents: 1500),
      ),
    );

    expect(
      colorOf(tester, '-R\$${nbsp}5,00'),
      AppTheme.light.extension<FinanceColors>()!.expense,
    );
  });

  testWidgets('funciona no tema escuro', (tester) async {
    await pumpCard(
      tester,
      const PeriodSummary(
        previousBalanceCents: 0,
        totals: FinancialSummary(incomeCents: 1000, expensesCents: 1500),
      ),
      theme: AppTheme.dark,
    );

    expect(
      colorOf(tester, '-R\$${nbsp}5,00'),
      AppTheme.dark.extension<FinanceColors>()!.expense,
    );
  });

  testWidgets('saldo acumula o saldo anterior, que aparece no card', (
    tester,
  ) async {
    await pumpCard(
      tester,
      const PeriodSummary(
        previousBalanceCents: -20000,
        totals: FinancialSummary(incomeCents: 50000, expensesCents: 10000),
      ),
    );

    expect(find.text('R\$${nbsp}200,00'), findsOneWidget, reason: 'saldo');
    expect(find.text('Saldo anterior: -R\$${nbsp}200,00'), findsOneWidget);
    expect(find.text('R\$${nbsp}500,00'), findsOneWidget, reason: 'receitas');
  });
}
