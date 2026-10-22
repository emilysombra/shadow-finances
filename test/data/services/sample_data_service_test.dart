import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/services/sample_data_service.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/income_category.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

void main() {
  // Dias "difíceis": começo de mês, começo de ano, fim de fevereiro.
  for (final today in [
    DateTime(2026, 10, 22),
    DateTime(2026, 11, 1),
    DateTime(2027, 1, 2),
    DateTime(2028, 2, 29),
  ]) {
    group('hoje = $today', () {
      final data = SampleDataService(today: today);
      final transactions = <Transaction>[...data.incomes, ...data.expenses];

      test('nenhuma transação no futuro', () {
        expect(transactions.where((t) => t.date.isAfter(today)), isEmpty);
      });

      test('ids únicos e toda transação numa conta existente', () {
        final ids = transactions.map((t) => t.id);
        expect(ids.toSet(), hasLength(ids.length));
        final accountIds = data.accounts.map((a) => a.id).toSet();
        expect(transactions.map((t) => t.accountId).toSet(), accountIds);
      });

      test('uma conta principal, com saldo inicial', () {
        expect(data.accounts.where((a) => a.isMain), hasLength(1));
        expect(
          data.incomes.where(
            (i) => i.category == IncomeCategory.initialBalance,
          ),
          hasLength(1),
        );
      });

      test('todo filtro mostra algo e há saldo anterior no mês atual', () {
        for (final filter in PeriodFilter.values) {
          final range = filter.rangeOn(today);
          expect(
            transactions.where((t) => range.contains(t.date)),
            isNotEmpty,
            reason: '$filter',
          );
        }
        final month = PeriodFilter.currentMonth.rangeOn(today);
        expect(
          transactions.where((t) => t.date.isBefore(month.start)),
          isNotEmpty,
        );
      });

      test('totais guardados batem com as transações em qualquer filtro', () {
        final ledger = data.ledgers[SampleDataService.mainAccount.id]!;
        for (final filter in PeriodFilter.values) {
          final range = filter.rangeOn(today);
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
            reason: '$filter',
          );
        }
      });
    });
  }
}
