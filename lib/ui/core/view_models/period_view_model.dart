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
    _filterChanges = _periodFilterRepository.changes.listen((_) {
      notifyListeners(); // o seletor já mostra o filtro novo
      load();
    });
  }

  final Clock _clock;
  final GetPeriodOverviewUseCase _getPeriodOverview;
  final PeriodFilterRepository _periodFilterRepository;
  late final StreamSubscription<PeriodFilter> _filterChanges;

  PeriodSummary? _summary;
  List<Transaction> _transactions = const [];
  bool _hasError = false;

  /// Conta os carregamentos, para descartar respostas de um período que o
  /// usuário já trocou por outro (ou de uma tela já fechada).
  int _loadVersion = 0;
  bool _disposed = false;

  /// Período escolhido, o mesmo em todas as telas.
  PeriodFilter get filter => _periodFilterRepository.filter;

  /// Intervalo de datas do período escolhido.
  DateRange get range => filter.rangeOn(_clock.now());

  /// Resumo do período; `null` enquanto carrega ou se o carregamento falhou.
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
  Future<void> load() async {
    final version = ++_loadVersion;
    final result = await _getPeriodOverview(range);

    // Período trocado ou tela fechada enquanto este carregava: descarta.
    if (_disposed || version != _loadVersion) return;

    switch (result) {
      case Ok(:final value):
        _summary = value.summary;
        _transactions = value.transactions;
        _hasError = false;
      case Failure():
        // Não deixa na tela os dados do período anterior.
        _summary = null;
        _transactions = const [];
        _hasError = true;
    }
    notifyListeners();
  }

  /// Chamado quando a tela fecha: para de escutar o filtro.
  @override
  void dispose() {
    _disposed = true;
    _filterChanges.cancel();
    super.dispose();
  }
}
