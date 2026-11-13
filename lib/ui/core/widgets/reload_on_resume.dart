import 'dart:async';

import 'package:flutter/widgets.dart';

/// Chama [onResume] sempre que o app volta ao primeiro plano (o usuário
/// reabre o app que estava em segundo plano).
///
/// Telas de período usam para recarregar: se o dia virou com o app aberto,
/// "mês atual" e "últimos 7 dias" já são outro intervalo.
///
/// Fica na View porque saber do ciclo de vida do app é coisa de widget; o
/// ViewModel só recebe o pedido de recarregar.
class ReloadOnResume extends StatefulWidget {
  const ReloadOnResume({
    super.key,
    required this.onResume,
    required this.child,
  });

  final Future<void> Function() onResume;
  final Widget child;

  @override
  State<ReloadOnResume> createState() => _ReloadOnResumeState();
}

class _ReloadOnResumeState extends State<ReloadOnResume> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    // widget.onResume lido na hora do aviso, para seguir o callback atual.
    _listener = AppLifecycleListener(
      onResume: () => unawaited(widget.onResume()),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
