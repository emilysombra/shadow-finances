import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';

void main() {
  test('saldo acumula o saldo anterior, positivo ou negativo', () {
    const totals = FinancialSummary(incomeCents: 1000, expensesCents: 400);

    expect(
      const PeriodSummary(
        previousBalanceCents: 500,
        totals: totals,
      ).balanceCents,
      1100,
    );
    expect(
      const PeriodSummary(
        previousBalanceCents: -800,
        totals: totals,
      ).balanceCents,
      -200,
    );
  });

  test('sum junta os resumos de várias contas', () {
    expect(
      PeriodSummary.sum(const [
        PeriodSummary(
          previousBalanceCents: 100,
          totals: FinancialSummary(incomeCents: 10, expensesCents: 1),
        ),
        PeriodSummary(
          previousBalanceCents: -30,
          totals: FinancialSummary(incomeCents: 20, expensesCents: 2),
        ),
      ]),
      const PeriodSummary(
        previousBalanceCents: 70,
        totals: FinancialSummary(incomeCents: 30, expensesCents: 3),
      ),
    );
    expect(PeriodSummary.sum(const []), PeriodSummary.zero);
  });
}
