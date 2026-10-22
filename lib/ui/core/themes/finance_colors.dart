import 'package:flutter/material.dart';

/// Cores semânticas de dinheiro que o Material não tem: receita e despesa.
///
/// Derivadas dos esquemas de cores em [AppTheme], então se ajustam sozinhas
/// aos temas claro e escuro. Widgets usam `FinanceColors.of(context).income`.
@immutable
class FinanceColors extends ThemeExtension<FinanceColors> {
  const FinanceColors({
    required this.income,
    required this.incomeContainer,
    required this.onIncomeContainer,
    required this.expense,
    required this.expenseContainer,
    required this.onExpenseContainer,
  });

  /// Receita vem do esquema gerado pela semente de receita; despesa reaproveita
  /// os papéis de erro do esquema do app.
  factory FinanceColors.from({
    required ColorScheme colorScheme,
    required ColorScheme incomeColorScheme,
  }) {
    return FinanceColors(
      income: incomeColorScheme.primary,
      incomeContainer: incomeColorScheme.primaryContainer,
      onIncomeContainer: incomeColorScheme.onPrimaryContainer,
      expense: colorScheme.error,
      expenseContainer: colorScheme.errorContainer,
      onExpenseContainer: colorScheme.onErrorContainer,
    );
  }

  /// Texto e ícones de receita sobre as superfícies do app.
  final Color income;

  /// Fundo de destaque de receita.
  final Color incomeContainer;

  /// Texto e ícones sobre [incomeContainer].
  final Color onIncomeContainer;

  /// Texto e ícones de despesa sobre as superfícies do app.
  final Color expense;

  /// Fundo de destaque de despesa.
  final Color expenseContainer;

  /// Texto e ícones sobre [expenseContainer].
  final Color onExpenseContainer;

  static FinanceColors of(BuildContext context) =>
      Theme.of(context).extension<FinanceColors>()!;

  @override
  FinanceColors copyWith({
    Color? income,
    Color? incomeContainer,
    Color? onIncomeContainer,
    Color? expense,
    Color? expenseContainer,
    Color? onExpenseContainer,
  }) {
    return FinanceColors(
      income: income ?? this.income,
      incomeContainer: incomeContainer ?? this.incomeContainer,
      onIncomeContainer: onIncomeContainer ?? this.onIncomeContainer,
      expense: expense ?? this.expense,
      expenseContainer: expenseContainer ?? this.expenseContainer,
      onExpenseContainer: onExpenseContainer ?? this.onExpenseContainer,
    );
  }

  @override
  FinanceColors lerp(FinanceColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return FinanceColors(
      income: mix(income, other.income),
      incomeContainer: mix(incomeContainer, other.incomeContainer),
      onIncomeContainer: mix(onIncomeContainer, other.onIncomeContainer),
      expense: mix(expense, other.expense),
      expenseContainer: mix(expenseContainer, other.expenseContainer),
      onExpenseContainer: mix(onExpenseContainer, other.onExpenseContainer),
    );
  }
}
