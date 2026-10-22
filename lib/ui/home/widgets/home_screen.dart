import 'package:flutter/material.dart';

import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/routing/routes.dart';
import 'package:shadow_finances/ui/core/themes/app_spacing.dart';
import 'package:shadow_finances/ui/core/widgets/page_body.dart';

/// Tela inicial. Ainda não tem estado, por isso não tem ViewModel.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.appTitle});

  final String appTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final spacing = AppSpacing.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
          ),
        ],
      ),
      body: PageBody(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: Text(
              l10n.homeTagline,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
