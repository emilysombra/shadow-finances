import 'package:shadow_finances/domain/models/expense_category.dart';
import 'package:shadow_finances/domain/models/income_category.dart';

/// Movimentação de dinheiro numa conta: uma [Expense] (saída) ou uma
/// [Income] (entrada). Toda transação pertence a uma conta; ao criar uma sem
/// conta escolhida, use a conta principal (`AccountRepository.getMainAccount`).
///
/// É `sealed`: só existem esses dois tipos, e um `switch` sobre uma
/// transação obriga a tratar ambos. Por isso os três ficam neste arquivo
/// (o Dart exige que subtipos de uma classe `sealed` estejam na mesma
/// biblioteca).
///
/// Para adicionar um campo comum: inclua-o aqui e nos construtores, `==` e
/// `hashCode` das subclasses. Campo de um só tipo: só na subclasse.
sealed class Transaction {
  const Transaction({
    required this.id,
    required this.description,
    required this.amountCents,
    required this.date,
    required this.accountId,
  });

  /// Identificador único, usado para editar ou excluir a transação.
  final String id;

  /// Texto livre do usuário. Pode ser vazio: a interface mostra o nome da
  /// categoria no lugar.
  final String description;

  /// Valor em centavos, sempre positivo; o tipo diz se entra ou sai.
  final int amountCents;

  /// Dia da transação (a hora é ignorada).
  final DateTime date;

  /// [Account.id] da conta de onde o dinheiro saiu ou para onde entrou.
  final String accountId;
}

/// Dinheiro que saiu.
final class Expense extends Transaction {
  const Expense({
    required super.id,
    required super.description,
    required super.amountCents,
    required super.date,
    required super.accountId,
    required this.category,
  });

  final ExpenseCategory category;

  @override
  bool operator ==(Object other) =>
      other is Expense &&
      other.id == id &&
      other.description == description &&
      other.amountCents == amountCents &&
      other.date == date &&
      other.accountId == accountId &&
      other.category == category;

  @override
  int get hashCode =>
      Object.hash(id, description, amountCents, date, accountId, category);
}

/// Dinheiro que entrou numa conta.
final class Income extends Transaction {
  const Income({
    required super.id,
    required super.description,
    required super.amountCents,
    required super.date,
    required super.accountId,
    required this.category,
  });

  /// Receita que registra o saldo inicial informado ao criar uma conta.
  ///
  /// Saldo inicial é opcional: se o usuário não informar, nenhuma receita é
  /// criada e a conta começa com saldo zero.
  const Income.initialBalance({
    required super.id,
    required super.amountCents,
    required super.date,
    required super.accountId,
  }) : category = IncomeCategory.initialBalance,
       super(description: '');

  final IncomeCategory category;

  @override
  bool operator ==(Object other) =>
      other is Income &&
      other.id == id &&
      other.description == description &&
      other.amountCents == amountCents &&
      other.date == date &&
      other.accountId == accountId &&
      other.category == category;

  @override
  int get hashCode =>
      Object.hash(id, description, amountCents, date, accountId, category);
}
