/// Categorias de despesa.
///
/// Os nomes dos valores serão persistidos junto com as despesas; renomeá-los
/// exige migrar os dados salvos.
enum ExpenseCategory {
  food,
  transport,
  housing,
  health,
  leisure,
  education,
  shopping,
  other,
}
