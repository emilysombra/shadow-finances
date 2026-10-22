import 'package:flutter/material.dart';

import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/domain/models/app_theme_mode.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/l10n/app_language_locale.dart';
import 'package:shadow_finances/ui/core/widgets/page_body.dart';
import 'package:shadow_finances/ui/core/widgets/section_header.dart';
import 'package:shadow_finances/ui/settings/view_models/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: PageBody(
        // ListenableBuilder redesenha só este trecho quando o ViewModel avisa
        // que o estado mudou (notifyListeners).
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => ListView(
            children: [
              SectionHeader(title: l10n.themeSectionTitle),
              RadioGroup<AppThemeMode?>(
                groupValue: viewModel.themeMode,
                onChanged: viewModel.setThemeMode,
                child: Column(
                  children: [
                    RadioListTile<AppThemeMode?>(
                      value: null,
                      title: Text(l10n.themeFollowDevice),
                    ),
                    for (final themeMode in AppThemeMode.values)
                      RadioListTile<AppThemeMode?>(
                        value: themeMode,
                        title: Text(switch (themeMode) {
                          AppThemeMode.light => l10n.themeLight,
                          AppThemeMode.dark => l10n.themeDark,
                        }),
                      ),
                  ],
                ),
              ),
              SectionHeader(title: l10n.languageSectionTitle),
              RadioGroup<AppLanguage?>(
                groupValue: viewModel.language,
                onChanged: viewModel.setLanguage,
                child: Column(
                  children: [
                    RadioListTile<AppLanguage?>(
                      value: null,
                      title: Text(l10n.languageFollowDevice),
                    ),
                    for (final language in AppLanguage.values)
                      RadioListTile<AppLanguage?>(
                        value: language,
                        title: Text(language.nativeName),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
