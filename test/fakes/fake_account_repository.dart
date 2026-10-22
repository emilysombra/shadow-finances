import 'dart:async';

import 'package:shadow_finances/data/repositories/account/account_repository.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_summary.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/utils/result.dart';

/// [AccountRepository] em memória para testes. Devolve [summaries] para
/// qualquer período, sem conferir com transação alguma.
class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository({List<AccountSummary>? summaries})
    : summaries =
          summaries ??
          [const AccountSummary(account: account, summary: PeriodSummary.zero)];

  /// Conta principal usada por padrão nos testes.
  static const account = Account(
    id: 'conta',
    name: 'Conta de teste',
    isMain: true,
  );

  List<AccountSummary> summaries;

  /// Quando `true`, todas as operações falham.
  bool shouldFail = false;

  /// Períodos pedidos, em ordem.
  final requestedRanges = <DateRange>[];

  /// Quando `true`, cada resposta de [getAccountSummaries] espera até o teste
  /// completar o [Completer] correspondente em [pending].
  bool holdResponses = false;
  final pending = <Completer<void>>[];

  @override
  Future<Result<List<AccountSummary>>> getAccountSummaries(
    DateRange range,
  ) async {
    requestedRanges.add(range);
    final answer = shouldFail
        ? Result<List<AccountSummary>>.failure(Exception('falha simulada'))
        : Result.ok(summaries);
    if (holdResponses) {
      final gate = Completer<void>();
      pending.add(gate);
      await gate.future;
    }
    return answer;
  }

  @override
  Future<Result<Account>> getMainAccount() async {
    if (shouldFail) return Result.failure(Exception('falha simulada'));
    return Result.ok(
      summaries.map((s) => s.account).firstWhere((a) => a.isMain),
    );
  }
}
