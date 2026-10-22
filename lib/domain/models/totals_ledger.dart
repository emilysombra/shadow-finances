import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

/// Totais de receitas e despesas de uma conta, guardados **por dia e por
/// mês**, para responder qualquer período sem somar transações.
///
/// - Manutenção: cada transação gravada, editada ou excluída aplica só a
///   diferença ([add] / [remove]; editar = `remove(antiga).add(nova)`).
/// - Consulta ([summarize]): meses inteiros do período usam o total mensal;
///   pedaços de mês usam os totais diários. "Mês atual" lê 1 total, "ano
///   atual" até 12, "últimos 7 dias" até 7. O saldo anterior soma os meses
///   já fechados antes do período.
///
/// Os totais mensais também dizem quais meses têm transações, o que servirá
/// para o futuro seletor de mês.
class TotalsLedger {
  const TotalsLedger._(this._byDay, this._byMonth);

  static const empty = TotalsLedger._({}, {});

  /// Monta os totais do zero a partir de [transactions]. Percorre todas, então
  /// é só para criar os totais pela primeira vez (ex.: migração de dados).
  factory TotalsLedger.of(Iterable<Transaction> transactions) =>
      transactions.fold(empty, (ledger, t) => ledger.add(t));

  /// Chave `aaaammdd` → totais do dia.
  final Map<int, FinancialSummary> _byDay;

  /// Chave `aaaamm` → totais do mês.
  final Map<int, FinancialSummary> _byMonth;

  /// Totais com [transaction] incluída.
  TotalsLedger add(Transaction transaction) =>
      _apply(transaction, (totals) => totals.add(transaction));

  /// Totais com [transaction] retirada.
  TotalsLedger remove(Transaction transaction) =>
      _apply(transaction, (totals) => totals.remove(transaction));

  TotalsLedger _apply(
    Transaction transaction,
    FinancialSummary Function(FinancialSummary) change,
  ) {
    final day = _dayKey(transaction.date);
    final month = _monthKey(transaction.date);
    return TotalsLedger._(
      {..._byDay, day: change(_byDay[day] ?? FinancialSummary.zero)},
      {..._byMonth, month: change(_byMonth[month] ?? FinancialSummary.zero)},
    );
  }

  /// Receitas e despesas dentro de [range] e o saldo acumulado antes dele.
  PeriodSummary summarize(DateRange range) {
    final firstMonth = DateTime(range.start.year, range.start.month);

    // Saldo anterior: meses fechados antes do período + dias do primeiro mês
    // que ficam antes do início.
    var previous = FinancialSummary.sum([
      for (final MapEntry(:key, :value) in _byMonth.entries)
        if (key < _monthKey(firstMonth)) value,
    ]);
    previous += _sumDays(
      firstMonth,
      DateTime(range.start.year, range.start.month, range.start.day - 1),
    );

    var totals = FinancialSummary.zero;
    for (
      var month = firstMonth;
      !month.isAfter(range.end);
      month = DateTime(month.year, month.month + 1)
    ) {
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final wholeMonth =
          !range.start.isAfter(month) && !range.end.isBefore(lastDay);
      totals += wholeMonth
          ? _byMonth[_monthKey(month)] ?? FinancialSummary.zero
          : _sumDays(
              range.start.isAfter(month) ? range.start : month,
              range.end.isBefore(lastDay) ? range.end : lastDay,
            );
    }

    return PeriodSummary(
      previousBalanceCents: previous.balanceCents,
      totals: totals,
    );
  }

  /// Soma dos totais diários de [from] a [to] (vazio se [to] < [from]).
  FinancialSummary _sumDays(DateTime from, DateTime to) {
    var total = FinancialSummary.zero;
    for (
      var day = from;
      !day.isAfter(to);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      total += _byDay[_dayKey(day)] ?? FinancialSummary.zero;
    }
    return total;
  }

  static int _dayKey(DateTime date) =>
      date.year * 10000 + date.month * 100 + date.day;

  static int _monthKey(DateTime date) => date.year * 100 + date.month;
}
