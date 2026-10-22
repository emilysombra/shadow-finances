import 'package:flutter/material.dart';

import 'package:shadow_finances/ui/core/layout/window_size_class.dart';

/// Corpo padrão das telas: respeita as áreas seguras do sistema e, em telas
/// largas, centraliza o conteúdo ocupando só parte da largura, para que
/// linhas de texto e listas não fiquem esticadas.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final widthFactor = switch (WindowSizeClass.of(context)) {
      WindowSizeClass.compact => 1.0,
      WindowSizeClass.medium => 0.85,
      WindowSizeClass.expanded => 0.6,
    };

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(widthFactor: widthFactor, child: child),
      ),
    );
  }
}
