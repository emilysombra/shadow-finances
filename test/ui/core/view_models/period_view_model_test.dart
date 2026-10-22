import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_finances/data/repositories/period_filter/period_filter_repository_memory.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/use_cases/get_period_overview_use_case.dart';
import 'package:shadow_finances/ui/core/view_models/period_view_model.dart';

import '../../../fakes/fake_account_repository.dart';
import '../../../fakes/fake_expense_repository.dart';
import '../../../fakes/fake_income_repository.dart';
import '../../../fakes/fixed_clock.dart';
import '../../../fakes/sample_transactions.dart';

/// [PeriodViewModel] é abstrata; testamos a parte comum por esta subclasse.
class _TestViewModel extends PeriodViewModel {
  _TestViewModel({
    required super.clock,
    required super.getPeriodOverview,
    required super.periodFilterRepository,
  });
}

void main() {
  final today = DateTime(2026, 10, 22);
  final salary = testIncome('i1', 5);
  final market = testExpense('e1', 20);
  final lastMonth = testExpense('e2', -10);

  late FakeAccountRepository accountRepository;
  late FakeExpenseRepository expenseRepository;
  late PeriodFilterRepositoryMemory filterRepository;

  _TestViewModel newViewModel() => _TestViewModel(
    clock: FixedClock(today),
    periodFilterRepository: filterRepository,
    getPeriodOverview: GetPeriodOverviewUseCase(
      accountRepository: accountRepository,
      incomeRepository: FakeIncomeRepository(incomes: [salary]),
      expenseRepository: expenseRepository,
    ),
  );

  late _TestViewModel viewModel;

  setUp(() {
    accountRepository = FakeAccountRepository();
    expenseRepository = FakeExpenseRepository(expenses: [market, lastMonth]);
    filterRepository = PeriodFilterRepositoryMemory();
    viewModel = newViewModel();
  });

  test('usa o filtro do Repository, sem resumo, transações nem erro', () {
    expect(viewModel.filter, PeriodFilter.currentMonth);
    expect(viewModel.range, PeriodFilter.currentMonth.rangeOn(today));
    expect(viewModel.summary, isNull);
    expect(viewModel.transactions, isEmpty);
    expect(viewModel.hasError, isFalse);
  });

  test('tela aberta depois de uma troca já nasce no filtro escolhido', () {
    filterRepository.select(PeriodFilter.lastSevenDays);
    expect(newViewModel().filter, PeriodFilter.lastSevenDays);
  });

  test('load traz o resumo e as transações do período e avisa a UI', () async {
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    await viewModel.load();

    expect(viewModel.summary, isNotNull);
    expect(viewModel.transactions, [market, salary]);
    expect(notifications, 1);
  });

  test('selectFilter escolhe para o app e recarrega o novo período', () async {
    await viewModel.load();

    viewModel.selectFilter(PeriodFilter.currentYear);
    await pumpEventQueue();

    expect(filterRepository.filter, PeriodFilter.currentYear);
    expect(viewModel.filter, PeriodFilter.currentYear);
    expect(
      accountRepository.requestedRanges.last,
      PeriodFilter.currentYear.rangeOn(today),
    );
    expect(viewModel.transactions, [market, salary, lastMonth]);
  });

  test('filtro escolhido em outra tela também recarrega esta', () async {
    final otherScreen = newViewModel();
    await viewModel.load();
    var notifications = 0;
    viewModel.addListener(() => notifications++);

    otherScreen.selectFilter(PeriodFilter.lastSevenDays);
    await pumpEventQueue();

    expect(viewModel.filter, PeriodFilter.lastSevenDays);
    expect(viewModel.transactions, [market]);
    expect(notifications, 2, reason: 'troca do seletor + dados novos');
  });

  test('tela fechada para de escutar o filtro', () async {
    final closed = newViewModel();
    await closed.load();
    final requests = accountRepository.requestedRanges.length;

    closed.dispose();
    viewModel.selectFilter(PeriodFilter.currentYear);
    await pumpEventQueue();

    // Só o ViewModel aberto recarregou.
    expect(accountRepository.requestedRanges, hasLength(requests + 1));
  });

  test('resposta que chega depois de a tela fechar é ignorada', () async {
    accountRepository.holdResponses = true;
    final load = viewModel.load();
    await pumpEventQueue();

    viewModel.dispose();
    accountRepository.pending.single.complete();

    // Sem o descarte, notifyListeners num ViewModel descartado lançaria erro.
    await expectLater(load, completes);
  });

  test('resposta atrasada de um filtro antigo é descartada', () async {
    accountRepository.holdResponses = true;
    final monthLoad = viewModel.load();
    viewModel.selectFilter(PeriodFilter.currentYear);
    await pumpEventQueue();
    expect(accountRepository.pending, hasLength(2));

    // O ano responde primeiro; o mês, que o usuário já trocou, por último.
    accountRepository.pending[1].complete();
    await pumpEventQueue();
    accountRepository.pending[0].complete();
    await monthLoad;

    expect(viewModel.filter, PeriodFilter.currentYear);
    expect(viewModel.transactions, [market, salary, lastMonth]);
  });

  test('falha marca erro e limpa os dados do período anterior', () async {
    await viewModel.load();
    expenseRepository.shouldFail = true;

    viewModel.selectFilter(PeriodFilter.currentYear);
    await pumpEventQueue();

    expect(viewModel.summary, isNull);
    expect(viewModel.transactions, isEmpty);
    expect(viewModel.hasError, isTrue);

    expenseRepository.shouldFail = false;
    await viewModel.load();
    expect(viewModel.summary, isNotNull);
    expect(viewModel.hasError, isFalse);
  });
}
