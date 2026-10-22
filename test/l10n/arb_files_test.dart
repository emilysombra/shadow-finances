import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Garante que nenhuma tradução foi esquecida ao adicionar textos novos.
void main() {
  Set<String> keysOf(String file) {
    final json = jsonDecode(
      File('lib/l10n/$file').readAsStringSync(),
    ) as Map<String, dynamic>;
    return json.keys.where((key) => !key.startsWith('@')).toSet();
  }

  final templateKeys = keysOf('app_pt.arb');

  // pt_PT só contém o que difere do pt-BR, então não entra aqui.
  for (final file in ['app_es.arb', 'app_en.arb', 'app_fr.arb']) {
    test('$file tem todas as chaves do template', () {
      expect(keysOf(file), templateKeys);
    });
  }

  test('app_pt_PT.arb só usa chaves que existem no template', () {
    expect(templateKeys.containsAll(keysOf('app_pt_PT.arb')), isTrue);
  });
}
