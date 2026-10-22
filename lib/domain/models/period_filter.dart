import 'package:shadow_finances/domain/models/date_range.dart';

/// Períodos prontos que o usuário pode escolher na tela inicial.
///
/// Cada um só sabe produzir um [DateRange]; o resto do app trabalha com o
/// intervalo. Escolher um mês qualquer (planejado) será outra forma de
/// produzir um intervalo, sem mudar quem o consome.
enum PeriodFilter {
  currentMonth,
  currentYear,

  /// Hoje e os seis dias anteriores.
  lastSevenDays;

  /// Intervalo do período, tomando [today] como hoje.
  DateRange rangeOn(DateTime today) => switch (this) {
    // Dia 0 do mês seguinte é o último dia deste mês.
    currentMonth => DateRange(
      start: DateTime(today.year, today.month, 1),
      end: DateTime(today.year, today.month + 1, 0),
    ),
    currentYear => DateRange(
      start: DateTime(today.year, 1, 1),
      end: DateTime(today.year, 12, 31),
    ),
    lastSevenDays => DateRange(
      start: DateTime(today.year, today.month, today.day - 6),
      end: today,
    ),
  };
}
