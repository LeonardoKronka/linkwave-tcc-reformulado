import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// O Flutter roda este arquivo antes de todos os testes da pasta.
///
/// Sem isto, os testes usam uma fonte de quadradinhos, bem mais larga que a
/// de verdade, e os textos quebram linha onde no aplicativo não quebram.
/// Aqui carregamos as fontes do aplicativo, para as medidas serem as reais.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFont('Archivo', 'assets/fonts/archivo-variable.ttf');
  await _loadFont('Martian Mono', 'assets/fonts/martian-mono-variable.ttf');
  await testMain();
}

Future<void> _loadFont(String family, String asset) async {
  final loader = FontLoader(family)..addFont(rootBundle.load(asset));
  await loader.load();
}
