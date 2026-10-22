import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/routing/router.dart';
import 'package:shadow_finances/routing/routes.dart';
import 'package:shadow_finances/ui/core/l10n/app_language_locale.dart';
import 'package:shadow_finances/ui/core/themes/app_theme.dart';
import 'package:shadow_finances/ui/settings/view_models/settings_view_model.dart';

class ShadowFinancesApp extends StatelessWidget {
  const ShadowFinancesApp({super.key});

  /// Nome do app. É marca, então não é traduzido.
  static const String title = 'Shadow Finances';

  @override
  Widget build(BuildContext context) {
    // watch: reconstrói o MaterialApp quando o idioma escolhido muda.
    final language = context.watch<SettingsViewModel>().language;

    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // null = segue o dispositivo, resolvido por resolveAppLocale.
      locale: language?.locale,
      supportedLocales: supportedAppLocales,
      localeListResolutionCallback: resolveAppLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      initialRoute: Routes.home,
      onGenerateRoute: (settings) => onGenerateRoute(settings, appTitle: title),
    );
  }
}
