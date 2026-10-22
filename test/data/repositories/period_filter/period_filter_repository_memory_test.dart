import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/period_filter/period_filter_repository_memory.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';

void main() {
  test('começa no mês atual', () {
    expect(PeriodFilterRepositoryMemory().filter, PeriodFilter.currentMonth);
  });

  test('select troca o filtro e avisa todos que escutam', () async {
    final repository = PeriodFilterRepositoryMemory();
    final first = <PeriodFilter>[];
    final second = <PeriodFilter>[];
    repository.changes.listen(first.add);
    repository.changes.listen(second.add);

    repository.select(PeriodFilter.currentYear);
    repository.select(PeriodFilter.currentYear); // mesmo filtro: sem aviso
    repository.select(PeriodFilter.lastSevenDays);
    await pumpEventQueue();

    expect(repository.filter, PeriodFilter.lastSevenDays);
    expect(first, [PeriodFilter.currentYear, PeriodFilter.lastSevenDays]);
    expect(second, first);
  });
}
