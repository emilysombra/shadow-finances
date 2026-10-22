import 'package:shadow_finances/data/repositories/account/account_repository.dart';
import 'package:shadow_finances/data/services/sample_data_service.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_summary.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/utils/result.dart';

/// [AccountRepository] provisório sobre os dados fictícios do
/// [SampleDataService].
class AccountRepositoryStatic implements AccountRepository {
  AccountRepositoryStatic({required this._sampleData});

  final SampleDataService _sampleData;

  @override
  Future<Result<List<AccountSummary>>> getAccountSummaries(
    DateRange range,
  ) async {
    final ledgers = _sampleData.ledgers;
    return Result.ok([
      for (final account in _sampleData.accounts)
        AccountSummary(
          account: account,
          summary: ledgers[account.id]?.summarize(range) ?? PeriodSummary.zero,
        ),
    ]);
  }

  @override
  Future<Result<Account>> getMainAccount() async =>
      Result.ok(_sampleData.accounts.firstWhere((account) => account.isMain));
}
