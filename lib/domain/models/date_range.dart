/// Intervalo de dias, com início e fim incluídos. A hora é ignorada.
class DateRange {
  DateRange({required DateTime start, required DateTime end})
    : start = _day(start),
      end = _day(end) {
    if (this.end.isBefore(this.start)) {
      throw ArgumentError('fim ($end) antes do início ($start)');
    }
  }

  /// Primeiro dia do intervalo, à meia-noite.
  final DateTime start;

  /// Último dia do intervalo, à meia-noite.
  final DateTime end;

  /// Se o dia de [date] está dentro do intervalo.
  bool contains(DateTime date) {
    final day = _day(date);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start, $end)';
}
