import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/account/account_repository_static.dart';
import 'package:shadow_finances/data/services/sample_data_service.dart';
import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/account_summary.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/utils/result.dart';

void main() {
  final today = DateTime(2026, 10, 22);
  final data = SampleDataService(today: today);
  final repository = AccountRepositoryStatic(sampleData: data);

  test('resumo de cada conta vem dos totais guardados', () async {
    final range = PeriodFilter.currentMonth.rangeOn(today);

    final result = await repository.getAccountSummaries(range);

    expect(
      result,
      isA<Ok<List<AccountSummary>>>().having((r) => r.value, 'value', [
        AccountSummary(
          account: SampleDataService.mainAccount,
          summary: data.ledgers['main']!.summarize(range),
        ),
      ]),
    );
  });

  test('a conta principal é a padrão', () async {
    expect(
      await repository.getMainAccount(),
      isA<Ok<Account>>().having(
        (r) => r.value,
        'value',
        SampleDataService.mainAccount,
      ),
    );
  });
}
