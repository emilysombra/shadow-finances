import 'package:shadow_finances/data/repositories/account/account_repository.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_balance.dart';
import 'package:shadow_finances/domain/models/financial_summary.dart';
import 'package:shadow_finances/utils/result.dart';

/// [AccountRepository] em memória para testes. Os totais de cada conta são
/// os passados em [balances], sem conferir com transação alguma.
class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository({List<AccountBalance>? balances})
    : balances =
          balances ??
          [
            const AccountBalance(
              account: account,
              totals: FinancialSummary.zero,
            ),
          ];

  /// Conta principal usada por padrão nos testes.
  static const account = Account(
    id: 'conta',
    name: 'Conta de teste',
    isMain: true,
  );

  List<AccountBalance> balances;

  /// Quando `true`, todas as operações falham.
  bool shouldFail = false;

  @override
  Future<Result<List<AccountBalance>>> getAccountBalances() async {
    if (shouldFail) return Result.failure(Exception('falha simulada'));
    return Result.ok(balances);
  }

  @override
  Future<Result<Account>> getMainAccount() async {
    if (shouldFail) return Result.failure(Exception('falha simulada'));
    return Result.ok(
      balances.map((b) => b.account).firstWhere((a) => a.isMain),
    );
  }
}
