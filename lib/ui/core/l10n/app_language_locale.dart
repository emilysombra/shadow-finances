import 'dart:ui';

import 'package:shadow_finances/domain/models/app_language.dart';

/// Ponte entre o modelo de domínio [AppLanguage] (Dart puro) e o [Locale]
/// do Flutter.
extension AppLanguageLocale on AppLanguage {
  Locale get locale => Locale(languageCode, countryCode);

  /// Nome do idioma escrito nele mesmo ("English (US)", "Français"...). Não é
  /// traduzido: quem não entende o idioma atual precisa reconhecer o seu.
  String get nativeName => switch (this) {
    AppLanguage.ptBR => 'Português (Brasil)',
    AppLanguage.ptPT => 'Português (Portugal)',
    AppLanguage.es419 => 'Español (Latinoamérica)',
    AppLanguage.enUS => 'English (US)',
    AppLanguage.fr => 'Français',
  };
}

/// Locales que o app declara suportar, na ordem de [AppLanguage].
final List<Locale> supportedAppLocales = [
  for (final language in AppLanguage.values) language.locale,
];

/// Escolhe o locale do app a partir da lista de idiomas do dispositivo.
/// Usado como `localeListResolutionCallback` do `MaterialApp`.
Locale resolveAppLocale(List<Locale>? preferred, Iterable<Locale> _) {
  return AppLanguage.resolve([
    for (final locale in preferred ?? const <Locale>[])
      (languageCode: locale.languageCode, countryCode: locale.countryCode),
  ]).locale;
}
