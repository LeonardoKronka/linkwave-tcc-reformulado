import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'auth/fake_auth_service.dart';

void main() {
  LicenseRegistry.addLicense(_fontLicenses);

  // Enquanto o servidor não existe, o login confere contas de demonstração.
  // Quando a API ficar pronta, é aqui que entra o serviço de verdade.
  runApp(LockMachineApp(auth: FakeAuthService(), demoAccounts: FakeAuthService.shortcuts));
}

/// As licenças das fontes entram na lista de licenças do aplicativo.
Stream<LicenseEntry> _fontLicenses() async* {
  yield LicenseEntryWithLineBreaks(['Archivo'], await rootBundle.loadString('assets/fonts/OFL-Archivo.txt'));
  yield LicenseEntryWithLineBreaks(['Martian Mono'], await rootBundle.loadString('assets/fonts/OFL-MartianMono.txt'));
}
