import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:shadow_finances/data/repositories/period_filter/period_filter_repository.dart';
import 'package:shadow_finances/domain/models/date_range.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';
import 'package:shadow_finances/domain/models/transaction.dart';
import 'package:shadow_finances/domain/use_cases/get_period_overview_use_case.dart';
import 'package:shadow_finances/utils/clock.dart';
import 'package:shadow_finances/utils/result.dart';

/// Estado comum às telas que mostram um período: resumo e transações do
/// filtro escolhido. Cada tela estende esta classe (`HomeViewModel`,
/// `TransactionsViewModel`) e acrescenta o que é só dela.
///
/// O filtro não é guardado aqui: vem do [PeriodFilterRepository],
/// compartilhado pelo app inteiro. Quando ele muda (nesta ou em outra tela),
/// este ViewModel avisa a tela e recarrega sozinho.
abstract class PeriodViewModel extends ChangeNotifier {
  PeriodViewModel({
    required this._clock,
    required this._getPeriodOverview,
    required this._periodFilterRepository,
  }) {
    // load() avisa a tela logo no início, então o seletor já mostra o
    // filtro novo enquanto os dados dele carregam.
    _filterChanges = _periodFilterRepository.changes.listen(
      (_) => unawaited(load()),
    );
  }

  final Clock _clock;
  final GetPeriodOverviewUseCase _getPeriodOverview;
  final PeriodFilterRepository _periodFilterRepository;
  late final StreamSubscription<PeriodFilter> _filterChanges;

  PeriodSummary? _summary;
  List<Transaction> _transactions = const [];
  bool _hasError = false;

  /// Intervalo dos dados em [summary] e [transactions]; `null` se não há
  /// dados carregados.
  DateRange? _loadedRange;

  /// Conta os carregamentos, para descartar respostas de um período que o
  /// usuário já trocou por outro (ou de uma tela já fechada).
  int _loadVersion = 0;
  bool _disposed = false;

  /// Período escolhido, o mesmo em todas as telas.
  PeriodFilter get filter => _periodFilterRepository.filter;

  /// Intervalo de datas do período escolhido.
  DateRange get range => filter.rangeOn(_clock.now());

  /// Resumo do período; `null` enquanto carrega um período novo ou se o
  /// carregamento falhou.
  PeriodSummary? get summary => _summary;

  /// Todas as receitas e despesas do período, mais recentes primeiro.
  List<Transaction> get transactions => _transactions;

  /// Se o último carregamento falhou.
  bool get hasError => _hasError;

  /// Escolhe o período para o app inteiro. Esta e as outras telas abertas
  /// recarregam ao receber o aviso do Repository.
  void selectFilter(PeriodFilter filter) =>
      _periodFilterRepository.select(filter);

  /// Carrega (ou recarrega) o resumo e as transações do período.
  ///
  /// Avisa a tela no início e no fim. Se o período mudou (outro filtro ou
  /// virada do dia), os dados antigos saem da tela na hora, para que ela
  /// mostre o carregamento em vez de valores de outro período. Recarregar o
  /// mesmo período (ex.: ao voltar ao app) mantém os dados até chegarem os
  /// novos, sem piscar.
  Future<void> load() async {
    if (_disposed) return;
    final version = ++_loadVersion;
    final range = this.range;
    if (range != _loadedRange) {
      _summary = null;
      _transactions = const [];
      _loadedRange = null;
    }
    _hasError = false;
    notifyListeners();

    final result = await _getPeriodOverview(range);

    // Período trocado ou tela fechada enquanto este carregava: descarta.
    if (_disposed || version != _loadVersion) return;

    switch (result) {
      case Ok(:final value):
        _summary = value.summary;
        _transactions = value.transactions;
        _loadedRange = range;
      case Failure():
        // Não deixa na tela os dados do período anterior.
        _summary = null;
        _transactions = const [];
        _loadedRange = null;
        _hasError = true;
    }
    notifyListeners();
  }

  /// Chamado quando a tela fecha: para de escutar o filtro.
  @override
  void dispose() {
    _disposed = true;
    unawaited(_filterChanges.cancel());
    super.dispose();
  }
}
