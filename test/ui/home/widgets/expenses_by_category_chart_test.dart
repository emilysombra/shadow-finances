import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/themes/app_theme.dart';
import 'package:shadow_finances/ui/home/widgets/expenses_by_category_chart.dart';

const nbsp = ' ';

void main() {
  Future<void> pumpChart(
    WidgetTester tester,
    List<({ExpenseCategory category, int cents})> expenses, {
    ThemeData? theme,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ExpensesByCategoryChart(expenses: expenses)),
      ),
    );
  }

  const expenses = [
    (category: ExpenseCategory.housing, cents: 150000),
    (category: ExpenseCategory.food, cents: 75000),
    (category: ExpenseCategory.health, cents: 25000),
  ];

  testWidgets('mostra nome, valor e porcentagem de cada categoria', (
    tester,
  ) async {
    await pumpChart(tester, expenses);

    expect(find.text('Moradia'), findsOneWidget);
    expect(find.text('R\$${nbsp}1.500,00  60%'), findsOneWidget);
    expect(find.text('Alimentação'), findsOneWidget);
    expect(find.text('R\$${nbsp}750,00  30%'), findsOneWidget);
    expect(find.text('Saúde'), findsOneWidget);
    expect(find.text('R\$${nbsp}250,00  10%'), findsOneWidget);
  });

  testWidgets('barras proporcionais à maior categoria', (tester) async {
    await pumpChart(tester, expenses);

    final factors = tester
        .widgetList<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .map((box) => box.widthFactor);
    expect(factors, [1.0, 0.5, 1 / 6]);
  });

  testWidgets('leitor de tela lê cada linha inteira', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpChart(tester, expenses);

    expect(
      find.bySemanticsLabel(RegExp(r'^Moradia\nR\$.1\.500,00  60%$')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('sem gastos, mostra uma mensagem', (tester) async {
    await pumpChart(tester, const []);

    expect(find.text('Nenhum gasto neste período.'), findsOneWidget);
    expect(find.byType(FractionallySizedBox), findsNothing);
  });

  testWidgets('funciona no tema escuro', (tester) async {
    await pumpChart(tester, expenses, theme: AppTheme.dark);

    expect(find.text('Moradia'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
