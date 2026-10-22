import 'package:flutter/material.dart';

import 'package:shadow_finances/domain/models/app_theme_mode.dart';

/// Ponte entre o modelo de domínio [AppThemeMode] (Dart puro) e o [ThemeMode]
/// do Flutter. `null` vira [ThemeMode.system] (segue o dispositivo).
extension AppThemeModeFlutter on AppThemeMode? {
  ThemeMode get themeMode => switch (this) {
    null => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
