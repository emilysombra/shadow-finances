import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/themes/app_theme.dart';
import 'package:shadow_finances/ui/core/themes/finance_colors.dart';
import 'package:shadow_finances/ui/core/widgets/transaction_list_tile.dart';

/// O intl separa "R$" do número com um espaço não separável.
const nbsp = ' ';

void main() {
  final financeColors = AppTheme.light.extension<FinanceColors>()!;

  final expense = Expense(
    id: '1',
    description: 'Supermercado',
    amountCents: 45890,
    date: DateTime(2026, 10, 20),
    accountId: 'conta',
    category: ExpenseCategory.food,
  );
  final salary = Income(
    id: '2',
    description: 'Salário',
    amountCents: 650000,
    date: DateTime(2026, 10, 3),
    category: IncomeCategory.salary,
    accountId: 'conta',
  );

  Future<void> pumpTile(
    WidgetTester tester,
    Transaction transaction, {
    Locale locale = const Locale('pt', 'BR'),
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: TransactionListTile(transaction: transaction)),
      ),
    );
  }

  Color? colorOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style?.color;

  testWidgets('despesa: valor negativo na cor de despesa', (tester) async {
    await pumpTile(tester, expense);

    expect(find.text('Supermercado'), findsOneWidget);
    expect(find.text('Alimentação · 20/10/2026'), findsOneWidget);
    expect(colorOf(tester, '-R\$${nbsp}458,90'), financeColors.expense);
  });

  testWidgets('receita: valor positivo na cor de receita', (tester) async {
    await pumpTile(tester, salary);

    expect(find.text('Salário · 03/10/2026'), findsOneWidget);
    expect(colorOf(tester, '+R\$${nbsp}6.500,00'), financeColors.income);
  });

  testWidgets('sem descrição, o título é o nome da categoria', (tester) async {
    await pumpTile(
      tester,
      Income.initialBalance(
        id: '3',
        amountCents: 120000,
        date: DateTime(2026, 10, 1),
        accountId: 'conta',
      ),
    );

    expect(find.text('Saldo inicial'), findsOneWidget, reason: 'título');
    expect(find.text('Saldo inicial · 01/10/2026'), findsOneWidget);
  });

  testWidgets('categoria segue o idioma; data e moeda seguem o padrão BR', (
    tester,
  ) async {
    await pumpTile(tester, expense, locale: const Locale('en', 'US'));

    expect(find.text('Food · 20/10/2026'), findsOneWidget);
    expect(find.text('-R\$${nbsp}458,90'), findsOneWidget);
  });
}
