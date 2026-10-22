import 'package:flutter/material.dart';

import 'package:shadow_finances/domain/models/app_language.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/l10n/app_language_locale.dart';
import 'package:shadow_finances/ui/core/widgets/page_body.dart';
import 'package:shadow_finances/ui/settings/view_models/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: PageBody(
        // ListenableBuilder redesenha só este trecho quando o ViewModel avisa
        // que o estado mudou (notifyListeners).
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => RadioGroup<AppLanguage?>(
            groupValue: viewModel.language,
            onChanged: viewModel.setLanguage,
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                    l10n.languageSectionTitle,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
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
        ),
      ),
    );
  }
}
