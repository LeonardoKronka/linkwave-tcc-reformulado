import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'auth/auth_service.dart';
import 'auth/fake_auth_service.dart';
import 'auth/session.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';
import 'theme/theme.dart';

/// Raiz do aplicativo: aplica o tema e decide entre o login e a tela inicial.
class LockMachineApp extends StatefulWidget {
  const LockMachineApp({super.key, required this.auth, this.demoAccounts = const []});

  /// Quem confere e-mail e senha.
  final AuthService auth;

  /// Contas de teste que o login oferece enquanto o servidor não existe.
  final List<DemoAccount> demoAccounts;

  @override
  State<LockMachineApp> createState() => _LockMachineAppState();
}

class _LockMachineAppState extends State<LockMachineApp> {
  /// Quem entrou. Sem sessão, o aplicativo mostra o login.
  Session? _session;

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return MaterialApp(
      title: 'LockMachine',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Builder(
        builder: (context) => AnimatedSwitcher(
          // Uma tela some e a outra aparece; sem animação, a troca é na hora.
          duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 350),
          child: session == null
              ? LoginScreen(
                  key: const ValueKey('login'),
                  auth: widget.auth,
                  demoAccounts: widget.demoAccounts,
                  onSignedIn: (session) => setState(() => _session = session),
                )
              : HomeScreen(
                  key: const ValueKey('home'),
                  session: session,
                  onSignOut: () => setState(() => _session = null),
                ),
        ),
      ),
    );
  }
}
