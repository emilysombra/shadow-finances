import 'package:flutter/foundation.dart';

import 'package:shadow_finances/data/repositories/account/account_repository.dart';
import 'package:shadow_finances/data/repositories/expense/expense_repository.dart';
import 'package:shadow_finances/data/repositories/income/income_repository.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/utils/clock.dart';
import 'package:shadow_finances/utils/result.dart';

/// Estado da tela inicial: período escolhido, resumo e transações dele.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._clock,
    required this._accountRepository,
    required this._incomeRepository,
    required this._expenseRepository,
  });

  final Clock _clock;
  final AccountRepository _accountRepository;
  final IncomeRepository _incomeRepository;
  final ExpenseRepository _expenseRepository;

  PeriodFilter _filter = PeriodFilter.currentMonth;
  PeriodSummary? _summary;
  List<Transaction> _transactions = const [];
  bool _hasError = false;

  /// Conta os carregamentos, para descartar respostas de um período que o
  /// usuário já trocou por outro.
  int _loadVersion = 0;

  /// Período escolhido; o padrão é o mês atual.
  PeriodFilter get filter => _filter;

  /// Intervalo de datas do período escolhido.
  DateRange get range => _filter.rangeOn(_clock.now());

  /// Resumo do período; `null` enquanto carrega ou se o carregamento falhou.
  PeriodSummary? get summary => _summary;

  /// Receitas e despesas do período, das mais recentes para as mais antigas.
  List<Transaction> get transactions => _transactions;

  /// Se o último carregamento falhou.
  bool get hasError => _hasError;

  /// Troca o período e recarrega a tela.
  Future<void> selectFilter(PeriodFilter filter) async {
    if (filter == _filter) return;
    _filter = filter;
    notifyListeners();
    await load();
  }

  /// Carrega (ou recarrega) o resumo e as transações do período. Só exibe
  /// algo se tudo chegar, para nunca mostrar valores pela metade.
  ///
  /// O resumo vem dos totais guardados de cada conta: as transações servem
  /// só para a lista, nunca são somadas aqui.
  Future<void> load() async {
    final version = ++_loadVersion;
    final range = this.range;

    final (accounts, incomes, expenses) = await (
      _accountRepository.getAccountSummaries(range),
      _incomeRepository.getIncomes(range),
      _expenseRepository.getExpenses(range),
    ).wait;

    // O usuário trocou de período enquanto este carregava: descarta.
    if (version != _loadVersion) return;

    switch ((accounts, incomes, expenses)) {
      case (
        Ok(value: final accounts),
        Ok(value: final incomes),
        Ok(value: final expenses),
      ):
        _summary = PeriodSummary.sum(
          accounts.map((account) => account.summary),
        );
        _transactions = List.unmodifiable(
          <Transaction>[...incomes, ...expenses]
            ..sort((a, b) => b.date.compareTo(a.date)),
        );
        _hasError = false;
      default:
        // Não deixa na tela os dados do período anterior.
        _summary = null;
        _transactions = const [];
        _hasError = true;
    }
    notifyListeners();
  }
}
