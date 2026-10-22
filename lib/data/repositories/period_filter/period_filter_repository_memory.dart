import 'dart:async';

import 'package:shadow_finances/data/repositories/period_filter/period_filter_repository.dart';
import 'package:shadow_finances/domain/models/period_filter.dart';

/// [PeriodFilterRepository] que guarda o filtro só na memória: ao reabrir o
/// app, ele volta para o mês atual.
class PeriodFilterRepositoryMemory implements PeriodFilterRepository {
  PeriodFilter _filter = PeriodFilter.currentMonth;

  // broadcast: várias telas podem escutar ao mesmo tempo.
  final _changes = StreamController<PeriodFilter>.broadcast();

  @override
  PeriodFilter get filter => _filter;

  @override
  Stream<PeriodFilter> get changes => _changes.stream;

  @override
  void select(PeriodFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    _changes.add(filter);
  }
}
