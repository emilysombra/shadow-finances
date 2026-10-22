import 'package:shadow_finances/domain/models/transaction.dart';

/// Totais de receitas e despesas e o saldo resultante, de uma conta
/// (`AccountBalance`) ou de várias somadas (card da tela inicial).
///
/// Os totais são **mantidos**, não recalculados: ao registrar, editar ou
/// excluir uma transação, aplique só a diferença com [add] / [remove]
/// (editar = `remove(antiga).add(nova)`). Somar todas as transações com
/// [FinancialSummary.of] fica para quando não há totais salvos (ex.:
/// conferência ou migração de dados).
///
/// Valores em centavos (ver regra de dinheiro no CLAUDE.md).
class FinancialSummary {
  const FinancialSummary({
    required this.incomeCents,
    required this.expensesCents,
  });

  static const zero = FinancialSummary(incomeCents: 0, expensesCents: 0);

  /// Totais calculados do zero a partir de [transactions]. Percorre todas,
  /// então não use para atualizar totais existentes (use [add]).
  factory FinancialSummary.of(Iterable<Transaction> transactions) =>
      transactions.fold(zero, (summary, t) => summary.add(t));

  /// Soma de vários totais (ex.: de todas as contas).
  factory FinancialSummary.sum(Iterable<FinancialSummary> summaries) =>
      summaries.fold(zero, (total, summary) => total + summary);

  /// Total de receitas, em centavos.
  final int incomeCents;

  /// Total de despesas, em centavos, como número positivo.
  final int expensesCents;

  /// Receitas menos despesas; negativo quando se gastou mais do que entrou.
  int get balanceCents => incomeCents - expensesCents;

  /// Totais com [transaction] incluída.
  FinancialSummary add(Transaction transaction) => this + _of(transaction);

  /// Totais com [transaction] retirada.
  FinancialSummary remove(Transaction transaction) => this - _of(transaction);

  FinancialSummary operator +(FinancialSummary other) => FinancialSummary(
    incomeCents: incomeCents + other.incomeCents,
    expensesCents: expensesCents + other.expensesCents,
  );

  FinancialSummary operator -(FinancialSummary other) => FinancialSummary(
    incomeCents: incomeCents - other.incomeCents,
    expensesCents: expensesCents - other.expensesCents,
  );

  static FinancialSummary _of(Transaction transaction) => switch (transaction) {
    Income(:final amountCents) => FinancialSummary(
      incomeCents: amountCents,
      expensesCents: 0,
    ),
    Expense(:final amountCents) => FinancialSummary(
      incomeCents: 0,
      expensesCents: amountCents,
    ),
  };

  @override
  bool operator ==(Object other) =>
      other is FinancialSummary &&
      other.incomeCents == incomeCents &&
      other.expensesCents == expensesCents;

  @override
  int get hashCode => Object.hash(incomeCents, expensesCents);
}
