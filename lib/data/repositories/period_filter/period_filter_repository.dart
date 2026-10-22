import 'package:shadow_finances/domain/models/period_filter.dart';

/// Fonte da verdade do período escolhido pelo usuário, compartilhado por
/// todas as telas: escolher um filtro em qualquer tela vale para o app todo.
abstract class PeriodFilterRepository {
  /// Filtro escolhido; começa no mês atual.
  PeriodFilter get filter;

  /// Avisa cada troca de filtro, com o filtro novo.
  Stream<PeriodFilter> get changes;

  /// Escolhe o filtro e avisa quem escuta [changes] (nada acontece se for o
  /// mesmo filtro).
  void select(PeriodFilter filter);
}
