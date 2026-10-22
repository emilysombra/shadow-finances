import 'package:flutter/material.dart';

/// Escala de espaçamentos e raios do app, disponível pelo tema.
///
/// Widgets nunca usam números soltos para margens e espaços: usam
/// `AppSpacing.of(context).md` etc.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.radius,
  });

  static const regular = AppSpacing(
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
    radius: 12,
  );

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  /// Raio padrão de cantos arredondados (cards, campos).
  final double radius;

  static AppSpacing of(BuildContext context) =>
      Theme.of(context).extension<AppSpacing>()!;

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? radius,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      radius: radius ?? this.radius,
    );
  }

  @override
  AppSpacing lerp(AppSpacing? other, double t) {
    if (other == null) return this;
    double mix(double a, double b) => a + (b - a) * t;
    return AppSpacing(
      xs: mix(xs, other.xs),
      sm: mix(sm, other.sm),
      md: mix(md, other.md),
      lg: mix(lg, other.lg),
      xl: mix(xl, other.xl),
      radius: mix(radius, other.radius),
    );
  }
}
