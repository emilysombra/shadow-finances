import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/totals_ledger.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

void main() {
  var nextId = 0;
  Income income(DateTime date, int cents) => Income(
    id: 'i${nextId++}',
    description: '',
    amountCents: cents,
    date: date,
    accountId: 'conta',
    category: IncomeCategory.other,
  );
  Expense expense(DateTime date, int cents) => Expense(
    id: 'e${nextId++}',
    description: '',
    amountCents: cents,
    date: date,
    accountId: 'conta',
    category: ExpenseCategory.other,
  );

  PeriodSummary summary(int previous, int income, int expenses) =>
      PeriodSummary(
        previousBalanceCents: previous,
        totals: FinancialSummary(incomeCents: income, expensesCents: expenses),
      );

  // Agosto positivo (+500), setembro negativo (-900), outubro com
  // movimentos no começo e no fim do mês.
  final transactions = <Transaction>[
    income(DateTime(2026, 8, 5), 1000),
    expense(DateTime(2026, 8, 20), 500),
    expense(DateTime(2026, 9, 10), 900),
    income(DateTime(2026, 10, 1), 2000),
    expense(DateTime(2026, 10, 15), 300),
    expense(DateTime(2026, 10, 21), 70),
    income(DateTime(2026, 10, 22), 40),
  ];
  final ledger = TotalsLedger.of(transactions);
  final today = DateTime(2026, 10, 22);

  test('mês atual: saldo anterior acumula os meses fechados', () {
    expect(
      ledger.summarize(PeriodFilter.currentMonth.rangeOn(today)),
      summary(500 - 900, 2040, 370),
    );
  });

  test('saldo negativo de um mês carrega para o seguinte', () {
    final october = PeriodFilter.currentMonth.rangeOn(today);
    final september = DateRange(
      start: DateTime(2026, 9, 1),
      end: DateTime(2026, 9, 30),
    );

    expect(ledger.summarize(september), summary(500, 0, 900));
    expect(
      ledger.summarize(september).balanceCents,
      ledger.summarize(october).previousBalanceCents,
    );
  });

  test('ano atual soma os meses do ano; nada antes dele', () {
    expect(
      ledger.summarize(PeriodFilter.currentYear.rangeOn(today)),
      summary(0, 3040, 1770),
    );
  });

  test(
    'últimos 7 dias: só os dias do intervalo; o resto do mês é anterior',
    () {
      // 16 a 22 de outubro: pega os dias 21 e 22, e o dia 15 fica no anterior.
      expect(
        ledger.summarize(PeriodFilter.lastSevenDays.rangeOn(today)),
        summary(500 - 900 + 2000 - 300, 40, 70),
      );
    },
  );

  test('intervalo que atravessa a virada do mês usa os dias dos dois', () {
    final range = DateRange(
      start: DateTime(2026, 9, 28),
      end: DateTime(2026, 10, 2),
    );
    expect(ledger.summarize(range), summary(500 - 900, 2000, 0));
  });

  test('add e remove atualizam dias e meses; editar = remove + add', () {
    final lunch = expense(DateTime(2026, 10, 21), 25);
    final october = PeriodFilter.currentMonth.rangeOn(today);
    final week = PeriodFilter.lastSevenDays.rangeOn(today);

    final withLunch = ledger.add(lunch);
    expect(withLunch.summarize(october).totals.expensesCents, 395);
    expect(withLunch.summarize(week).totals.expensesCents, 95);
    expect(
      withLunch.remove(lunch).summarize(october),
      ledger.summarize(october),
    );

    final moved = expense(DateTime(2026, 9, 3), 25);
    final edited = withLunch.remove(lunch).add(moved);
    expect(edited.summarize(october).previousBalanceCents, 500 - 900 - 25);
  });

  test('resultado é o mesmo que somar as transações do período', () {
    for (final filter in PeriodFilter.values) {
      for (final day in [
        DateTime(2026, 10, 22),
        DateTime(2026, 9, 2),
        DateTime(2026, 8, 1),
        DateTime(2027, 1, 3),
      ]) {
        final range = filter.rangeOn(day);
        expect(
          ledger.summarize(range),
          PeriodSummary(
            previousBalanceCents: FinancialSummary.of(
              transactions.where((t) => t.date.isBefore(range.start)),
            ).balanceCents,
            totals: FinancialSummary.of(
              transactions.where((t) => range.contains(t.date)),
            ),
          ),
          reason: '$filter em $day',
        );
      }
    }
  });

  test('sem transações, tudo é zero', () {
    expect(
      TotalsLedger.empty.summarize(PeriodFilter.currentYear.rangeOn(today)),
      PeriodSummary.zero,
    );
  });
}
