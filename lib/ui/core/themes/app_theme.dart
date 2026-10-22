import 'package:flutter/material.dart';

import 'package:shadow_finances/ui/core/themes/app_spacing.dart';
import 'package:shadow_finances/ui/core/themes/finance_colors.dart';

/// Temas claro e escuro do app.
///
/// Este é o único lugar onde cores são escritas diretamente: as cores-semente,
/// das quais o Material 3 deriva os esquemas de cores.
abstract final class AppTheme {
  static const _seedColor = Colors.indigo;

  /// Semente das cores de receita ([FinanceColors]).
  static const _incomeSeedColor = Colors.green;

  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      extensions: [
        AppSpacing.regular,
        FinanceColors.from(
          colorScheme: colorScheme,
          incomeColorScheme: ColorScheme.fromSeed(
            seedColor: _incomeSeedColor,
            brightness: brightness,
          ),
        ),
      ],
    );
  }
}
