import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_balance.dart';
import 'package:shadow_finances/utils/result.dart';

/// Fonte da verdade das contas do usuário e dos totais de cada uma.
///
/// Implementações guardam os totais junto com a conta e os atualizam a cada
/// transação gravada (`AccountBalance.add` / `remove`), na mesma operação que
/// grava a transação. Nunca recalculam somando todas as transações.
abstract class AccountRepository {
  /// Todas as contas, com receitas, despesas e saldo.
  Future<Result<List<AccountBalance>>> getAccountBalances();

  /// Conta padrão para transações novas.
  Future<Result<Account>> getMainAccount();
}
