import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

/// Totais de receitas e despesas, o saldo resultante e as despesas por
/// categoria, de uma conta ou de várias somadas, num dia, mês ou período.
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
    this.expensesByCategory = const {},
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

  /// Total de despesas de cada categoria, em centavos. Categorias sem gasto
  /// não aparecem. Somadas, dão [expensesCents].
  final Map<ExpenseCategory, int> expensesByCategory;

  /// Receitas menos despesas; negativo quando se gastou mais do que entrou.
  int get balanceCents => incomeCents - expensesCents;

  /// Categorias com gasto, da que mais gastou para a que menos gastou
  /// (empate: ordem do enum, para a lista não mudar de lugar à toa).
  List<({ExpenseCategory category, int cents})> get expensesByCategoryRanked =>
      [
        for (final MapEntry(key: category, value: cents)
            in expensesByCategory.entries)
          (category: category, cents: cents),
      ]..sort(
        (a, b) => b.cents != a.cents
            ? b.cents.compareTo(a.cents)
            : a.category.index.compareTo(b.category.index),
      );

  /// Totais com [transaction] incluída.
  FinancialSummary add(Transaction transaction) => this + _of(transaction);

  /// Totais com [transaction] retirada.
  FinancialSummary remove(Transaction transaction) => this - _of(transaction);

  FinancialSummary operator +(FinancialSummary other) => FinancialSummary(
    incomeCents: incomeCents + other.incomeCents,
    expensesCents: expensesCents + other.expensesCents,
    expensesByCategory: _combine(other.expensesByCategory, 1),
  );

  FinancialSummary operator -(FinancialSummary other) => FinancialSummary(
    incomeCents: incomeCents - other.incomeCents,
    expensesCents: expensesCents - other.expensesCents,
    expensesByCategory: _combine(other.expensesByCategory, -1),
  );

  /// [expensesByCategory] somado (`sign` = 1) ou subtraído (`sign` = -1) de
  /// [other]. Categorias que zeram saem do mapa, para que `add` seguido de
  /// `remove` volte exatamente ao original.
  Map<ExpenseCategory, int> _combine(
    Map<ExpenseCategory, int> other,
    int sign,
  ) {
    if (other.isEmpty) return expensesByCategory;
    final result = {...expensesByCategory};
    for (final MapEntry(key: category, value: cents) in other.entries) {
      final total = (result[category] ?? 0) + sign * cents;
      if (total == 0) {
        result.remove(category);
      } else {
        result[category] = total;
      }
    }
    return Map.unmodifiable(result);
  }

  static FinancialSummary _of(Transaction transaction) => switch (transaction) {
    Income(:final amountCents) => FinancialSummary(
      incomeCents: amountCents,
      expensesCents: 0,
    ),
    Expense(:final amountCents, :final category) => FinancialSummary(
      incomeCents: 0,
      expensesCents: amountCents,
      expensesByCategory: {category: amountCents},
    ),
  };

  @override
  bool operator ==(Object other) =>
      other is FinancialSummary &&
      other.incomeCents == incomeCents &&
      other.expensesCents == expensesCents &&
      other.expensesByCategory.length == expensesByCategory.length &&
      expensesByCategory.entries.every(
        (entry) => other.expensesByCategory[entry.key] == entry.value,
      );

  @override
  int get hashCode => Object.hash(
    incomeCents,
    expensesCents,
    Object.hashAllUnordered(
      expensesByCategory.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() =>
      'FinancialSummary(receitas: $incomeCents, despesas: $expensesCents, '
      'por categoria: $expensesByCategory)';
}
