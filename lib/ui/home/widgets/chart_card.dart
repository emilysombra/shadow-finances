import 'package:flutter/material.dart';

import 'package:shadow_finances/ui/core/themes/app_spacing.dart';

/// Moldura comum dos gráficos da tela inicial: título e o gráfico abaixo.
/// Gráficos novos entram como outro [ChartCard] na seção de gráficos.
class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(height: spacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
