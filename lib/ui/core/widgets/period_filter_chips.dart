import 'package:flutter/material.dart';

import 'package:shadow_finances/domain/models/period_filter.dart';
import 'package:shadow_finances/l10n/app_localizations.dart';
import 'package:shadow_finances/ui/core/themes/app_spacing.dart';

/// Seletor de período da tela inicial: um chip por [PeriodFilter].
///
/// `Wrap` em vez de `SegmentedButton`: com fonte grande ou tela estreita, os
/// chips passam para a linha de baixo em vez de transbordar.
class PeriodFilterChips extends StatelessWidget {
  const PeriodFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PeriodFilter selected;
  final ValueChanged<PeriodFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = AppSpacing.of(context);

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: [
        for (final filter in PeriodFilter.values)
          ChoiceChip(
            label: Text(switch (filter) {
              PeriodFilter.currentMonth => l10n.filterCurrentMonth,
              PeriodFilter.currentYear => l10n.filterCurrentYear,
              PeriodFilter.lastSevenDays => l10n.filterLastSevenDays,
            }),
            selected: filter == selected,
            onSelected: (_) => onSelected(filter),
          ),
      ],
    );
  }
}
