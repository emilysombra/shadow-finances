import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shadow_finances/ui/core/formatting/br_format.dart';

/// O intl separa "R$" do número com um espaço não separável.
const nbsp = ' ';

void main() {
  setUpAll(() => initializeDateFormatting(BrFormat.locale));

  test('moeda em reais a partir de centavos', () {
    expect(BrFormat.currency(123456), 'R\$${nbsp}1.234,56');
    expect(BrFormat.currency(5), 'R\$${nbsp}0,05');
    expect(BrFormat.currency(-1050), '-R\$${nbsp}10,50');
  });

  test('moeda com sinal explícito', () {
    expect(BrFormat.signedCurrency(500), '+R\$${nbsp}5,00');
    expect(BrFormat.signedCurrency(-500), '-R\$${nbsp}5,00');
    expect(BrFormat.signedCurrency(0), 'R\$${nbsp}0,00');
  });

  test('números com vírgula decimal e ponto de milhar', () {
    expect(BrFormat.number(1234567.5), '1.234.567,5');
  });

  test('data e hora no padrão brasileiro', () {
    final moment = DateTime(2026, 10, 21, 14, 5);
    expect(BrFormat.date(moment), '21/10/2026');
    expect(BrFormat.time(moment), '14:05');
  });

  test('não depende do idioma padrão do intl', () {
    Intl.withLocale('en_US', () {
      expect(BrFormat.currency(123456), 'R\$${nbsp}1.234,56');
      expect(BrFormat.date(DateTime(2026, 10, 21)), '21/10/2026');
    });
  });
}
