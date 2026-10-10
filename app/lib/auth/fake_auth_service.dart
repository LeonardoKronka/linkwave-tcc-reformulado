import 'auth_service.dart';
import 'session.dart';

/// Conta de teste. As pessoas são fictícias, as mesmas do site: o supervisor
/// do painel e os três operadores do simulador.
class DemoAccount {
  const DemoAccount({required this.name, required this.email, required this.role, this.active = true});

  final String name;
  final String email;
  final Role role;

  /// Conta desativada não entra, mesmo com a senha certa.
  final bool active;

  /// Todas as contas de teste usam a mesma senha, mostrada na tela de login.
  String get password => FakeAuthService.demoPassword;
}

/// Autenticação de demonstração: confere contas fixas, sem servidor nenhum.
/// Existe só até a API ficar pronta.
class FakeAuthService implements AuthService {
  FakeAuthService({this.delay = const Duration(milliseconds: 900), this.accounts = demoAccounts});

  /// Espera fingida, do tamanho de uma resposta de rede, para a tela mostrar
  /// que está conferindo.
  final Duration delay;

  final List<DemoAccount> accounts;

  static const demoPassword = '1234';

  static const supervisorAccount = DemoAccount(
    name: 'Leonardo Silva',
    email: 'supervisor@empresa.test',
    role: Role.supervisor,
  );

  static const operatorAccount = DemoAccount(
    name: 'Marina Costa',
    email: 'marina@empresa.test',
    role: Role.machineOperator,
  );

  static const demoAccounts = [
    supervisorAccount,
    operatorAccount,
    DemoAccount(name: 'Carlos Souza', email: 'carlos@empresa.test', role: Role.machineOperator),
    DemoAccount(name: 'Pedro Alves', email: 'pedro@empresa.test', role: Role.machineOperator),
  ];

  /// As contas que a tela de login oferece para preencher com um toque:
  /// uma de cada perfil que o aplicativo atende.
  static const shortcuts = [supervisorAccount, operatorAccount];

  @override
  Future<Session> signIn({required String email, required String password}) async {
    await Future<void>.delayed(delay);

    final wanted = email.trim().toLowerCase();
    for (final account in accounts) {
      if (account.email != wanted || password != demoPassword) continue;
      if (!account.active) throw const AuthException(AuthFailure.inactiveAccount);
      return Session(name: account.name, email: account.email, role: account.role, startedAt: DateTime.now());
    }
    throw const AuthException(AuthFailure.invalidCredentials);
  }
}
