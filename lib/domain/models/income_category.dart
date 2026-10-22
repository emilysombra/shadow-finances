/// Categorias de receita.
///
/// Os nomes dos valores serão persistidos junto com as receitas; renomeá-los
/// exige migrar os dados salvos.
enum IncomeCategory {
  salary,
  freelance,
  investments,
  gift,
  refund,

  /// Saldo informado ao criar uma conta (ver `Income.initialBalance`).
  initialBalance,
  other,
}
