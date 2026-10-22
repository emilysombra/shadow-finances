import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_summary.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/utils/result.dart';

/// Fonte da verdade das contas do usuário e dos totais de cada uma.
///
/// Implementações guardam os totais de cada conta por dia e por mês
/// (`TotalsLedger`) e os atualizam a cada transação gravada, na mesma operação
/// que grava a transação. Nunca recalculam somando todas as transações.
abstract class AccountRepository {
  /// Todas as contas, com receitas e despesas de [range] e saldo acumulado.
  Future<Result<List<AccountSummary>>> getAccountSummaries(DateRange range);

  /// Conta padrão para transações novas.
  Future<Result<Account>> getMainAccount();
}
