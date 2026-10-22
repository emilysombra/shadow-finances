import 'package:flutter/material.dart';

import 'package:shadow_finances/ui/core/themes/app_spacing.dart';

/// Temas claro e escuro do app.
///
/// Este é o único lugar onde uma cor é escrita diretamente: a cor-semente,
/// da qual o Material 3 deriva todo o `ColorScheme`.
abstract final class AppTheme {
  static const _seedColor = Colors.indigo;

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: brightness,
      ),
      extensions: const [AppSpacing.regular],
    );
  }
}
