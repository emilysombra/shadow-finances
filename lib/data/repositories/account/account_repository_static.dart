import 'package:shadow_finances/data/repositories/account/account_repository.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_balance.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/utils/result.dart';

/// [AccountRepository] provisório com a única conta do usuário, enquanto o
/// app ainda não salva contas.
class AccountRepositoryStatic implements AccountRepository {
  // Dado fictício; o nome é dado do usuário, por isso não é traduzido.
  static const mainAccount = Account(
    id: 'main',
    name: 'Conta principal',
    isMain: true,
  );

  /// Totais guardados, como estariam numa coluna do banco de dados. Batem
  /// com as transações fictícias de IncomeRepositoryStatic e
  /// ExpenseRepositoryStatic (conferido nos testes).
  static const mainAccountBalance = AccountBalance(
    account: mainAccount,
    totals: FinancialSummary(incomeCents: 954590, expensesCents: 313760),
  );

  @override
  Future<Result<List<AccountBalance>>> getAccountBalances() async =>
      const Result.ok([mainAccountBalance]);

  @override
  Future<Result<Account>> getMainAccount() async =>
      const Result.ok(mainAccount);
}
