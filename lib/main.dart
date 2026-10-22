import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:shadow_finances/app.dart';
import 'package:shadow_finances/config/dependencies.dart';
import 'package:shadow_finances/ui/core/formatting/br_format.dart';

Future<void> main() async {
  // Necessário antes de usar plugins (shared_preferences) fora de um widget.
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(BrFormat.locale);

  runApp(
    MultiProvider(
      providers: await createDependencies(),
      child: const ShadowFinancesApp(),
    ),
  );
}
