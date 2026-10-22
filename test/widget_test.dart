import 'package:flutter_test/flutter_test.dart';

import 'package:shadow_finances/main.dart';

void main() {
  testWidgets('tela inicial exibe o título do app', (tester) async {
    await tester.pumpWidget(const ShadowFinancesApp());

    expect(find.text('Shadow Finances'), findsOneWidget);
  });
}
