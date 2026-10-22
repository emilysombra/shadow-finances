import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';

/// Uma conta com seus totais de receitas e despesas e o saldo.
///
/// Os totais são guardados junto com a conta pelo `AccountRepository` e
/// atualizados a cada transação ([add] / [remove]), para que nenhuma tela
/// precise somar todas as transações.
class AccountBalance {
  const AccountBalance({required this.account, required this.totals});

  final Account account;

  /// Receitas e despesas desta conta.
  final FinancialSummary totals;

  /// Receitas menos despesas da conta, em centavos.
  int get balanceCents => totals.balanceCents;

  /// Conta com [transaction] incluída nos totais.
  AccountBalance add(Transaction transaction) {
    _checkAccount(transaction);
    return AccountBalance(account: account, totals: totals.add(transaction));
  }

  /// Conta com [transaction] retirada dos totais.
  AccountBalance remove(Transaction transaction) {
    _checkAccount(transaction);
    return AccountBalance(account: account, totals: totals.remove(transaction));
  }

  void _checkAccount(Transaction transaction) {
    if (transaction.accountId != account.id) {
      throw ArgumentError.value(
        transaction.accountId,
        'transaction.accountId',
        'transação de outra conta (esperada ${account.id})',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AccountBalance &&
      other.account == account &&
      other.totals == totals;

  @override
  int get hashCode => Object.hash(account, totals);
}
