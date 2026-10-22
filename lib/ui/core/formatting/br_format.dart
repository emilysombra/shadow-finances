import 'package:intl/intl.dart';

/// Formatação de moeda, números e datas **sempre no padrão brasileiro**,
/// independente do idioma da interface: o app é voltado a residentes no
/// Brasil, então um usuário com a interface em inglês ainda vê `R$ 1.234,56`
/// e `21/10/2026`.
///
/// Requer `initializeDateFormatting(BrFormat.locale)` antes do primeiro uso
/// de [date] ou [time] (feito em `main.dart`).
abstract final class BrFormat {
  static const locale = 'pt_BR';

  static final _currency = NumberFormat.currency(locale: locale, symbol: r'R$');
  static final _number = NumberFormat.decimalPattern(locale);
  static final _date = DateFormat('dd/MM/yyyy', locale);
  static final _time = DateFormat('HH:mm', locale);

  /// Valor monetário a partir de centavos: `123456` → `R$ 1.234,56`.
  static String currency(int cents) => _currency.format(cents / 100);

  /// Número com separadores brasileiros: `1234.5` → `1.234,5`.
  static String number(num value) => _number.format(value);

  /// Data numérica: `21/10/2026`.
  static String date(DateTime value) => _date.format(value);

  /// Hora em 24 h: `14:05`.
  static String time(DateTime value) => _time.format(value);
}
