import 'package:shadow_finances/domain/models/financial_summary.dart';

/// Resumo de um período: o que entrou e saiu nele e o saldo acumulado.
///
/// O saldo de um período carrega para o seguinte: [balanceCents] é o
/// [previousBalanceCents] (tudo antes do início do período, positivo ou
/// negativo) mais o saldo do próprio período.
class PeriodSummary {
  const PeriodSummary({
    required this.previousBalanceCents,
    required this.totals,
  });

  static const zero = PeriodSummary(
    previousBalanceCents: 0,
    totals: FinancialSummary.zero,
  );

  /// Soma de vários resumos do mesmo período (ex.: de todas as contas).
  factory PeriodSummary.sum(Iterable<PeriodSummary> summaries) =>
      summaries.fold(zero, (total, summary) => total + summary);

  /// Saldo acumulado até o dia anterior ao início do período.
  final int previousBalanceCents;

  /// Receitas e despesas dentro do período.
  final FinancialSummary totals;

  /// Saldo ao fim do período, incluindo o saldo anterior.
  int get balanceCents => previousBalanceCents + totals.balanceCents;

  PeriodSummary operator +(PeriodSummary other) => PeriodSummary(
    previousBalanceCents: previousBalanceCents + other.previousBalanceCents,
    totals: totals + other.totals,
  );

  @override
  bool operator ==(Object other) =>
      other is PeriodSummary &&
      other.previousBalanceCents == previousBalanceCents &&
      other.totals == totals;

  @override
  int get hashCode => Object.hash(previousBalanceCents, totals);

  @override
  String toString() =>
      'PeriodSummary(anterior: $previousBalanceCents, '
      'receitas: ${totals.incomeCents}, despesas: ${totals.expensesCents})';
}
