import 'package:flutter/widgets.dart';

/// Faixas de largura de janela do Material 3, usadas para adaptar layouts.
///
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowSizeClass {
  /// Celulares em pé (< 600 dp).
  compact,

  /// Tablets em pé, celulares deitados (600–840 dp).
  medium,

  /// Tablets deitados, desktop e web (≥ 840 dp).
  expanded;

  static WindowSizeClass fromWidth(double width) {
    if (width < 600) return compact;
    if (width < 840) return medium;
    return expanded;
  }

  static WindowSizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}
