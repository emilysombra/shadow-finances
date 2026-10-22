/// Idiomas suportados pelo app.
///
/// Os nomes dos valores (`ptBR`, `ptPT`...) são persistidos como preferência
/// do usuário; renomeá-los exige migrar o valor salvo.
enum AppLanguage {
  ptBR('pt', 'BR'),
  ptPT('pt', 'PT'),
  es419('es', '419'),
  enUS('en', 'US'),
  fr('fr');

  const AppLanguage(this.languageCode, [this.countryCode]);

  /// Código ISO 639 do idioma (ex.: `pt`).
  final String languageCode;

  /// Código do país ou região (ex.: `BR`, `419` = América Latina).
  final String? countryCode;

  /// Idioma usado quando nenhum idioma preferido do dispositivo é suportado.
  static const fallback = ptBR;

  /// Idioma suportado mais próximo de um idioma do dispositivo, ou `null`
  /// se o idioma não for suportado.
  static AppLanguage? match(String languageCode, String? countryCode) {
    return switch (languageCode) {
      'pt' => countryCode == 'PT' ? ptPT : ptBR,
      'es' => es419,
      'en' => enUS,
      'fr' => fr,
      _ => null,
    };
  }

  /// Escolhe o idioma do app a partir dos idiomas preferidos do dispositivo,
  /// em ordem de preferência, caindo em [fallback] se nenhum for suportado.
  static AppLanguage resolve(
    Iterable<({String languageCode, String? countryCode})> preferred,
  ) {
    for (final locale in preferred) {
      final language = match(locale.languageCode, locale.countryCode);
      if (language != null) return language;
    }
    return fallback;
  }
}
