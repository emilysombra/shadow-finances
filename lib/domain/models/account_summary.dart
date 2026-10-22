import 'package:shadow_finances/domain/models/account.dart';
import 'package:shadow_finances/domain/models/period_summary.dart';

/// Uma conta e o seu resumo num período (receitas, despesas e saldo
/// acumulado).
class AccountSummary {
  const AccountSummary({required this.account, required this.summary});

  final Account account;
  final PeriodSummary summary;

  /// Saldo da conta ao fim do período, em centavos.
  int get balanceCents => summary.balanceCents;

  @override
  bool operator ==(Object other) =>
      other is AccountSummary &&
      other.account == account &&
      other.summary == summary;

  @override
  int get hashCode => Object.hash(account, summary);
}
