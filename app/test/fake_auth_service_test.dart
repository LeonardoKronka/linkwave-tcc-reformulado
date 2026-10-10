import 'package:flutter_test/flutter_test.dart';
import 'package:lockmachine/auth/auth_service.dart';
import 'package:lockmachine/auth/fake_auth_service.dart';
import 'package:lockmachine/auth/session.dart';

/// Confere que o login falhou pelo motivo esperado.
Matcher failsWith(AuthFailure failure) {
  return throwsA(isA<AuthException>().having((error) => error.failure, 'motivo', failure));
}

void main() {
  final auth = FakeAuthService(delay: Duration.zero);

  test('a conta do supervisor entra com o perfil de supervisor', () async {
    final session = await auth.signIn(email: 'supervisor@empresa.test', password: '1234');

    expect(session.name, 'Leonardo Silva');
    expect(session.role, Role.supervisor);
  });

  test('os três operadores do simulador entram com o perfil de operador', () async {
    for (final email in ['marina@empresa.test', 'carlos@empresa.test', 'pedro@empresa.test']) {
      final session = await auth.signIn(email: email, password: '1234');
      expect(session.role, Role.machineOperator, reason: email);
    }
  });

  test('o e-mail vale com maiúsculas e com espaços em volta', () async {
    final session = await auth.signIn(email: '  Marina@Empresa.TEST ', password: '1234');

    expect(session.name, 'Marina Costa');
  });

  test('senha errada não entra', () {
    expect(
      auth.signIn(email: 'supervisor@empresa.test', password: 'errada'),
      failsWith(AuthFailure.invalidCredentials),
    );
  });

  test('e-mail desconhecido não entra', () {
    expect(auth.signIn(email: 'ninguem@empresa.test', password: '1234'), failsWith(AuthFailure.invalidCredentials));
  });

  test('conta desativada não entra, mesmo com a senha certa', () {
    final auth = FakeAuthService(
      delay: Duration.zero,
      accounts: const [
        DemoAccount(name: 'Ana Lima', email: 'ana@empresa.test', role: Role.machineOperator, active: false),
      ],
    );

    expect(auth.signIn(email: 'ana@empresa.test', password: '1234'), failsWith(AuthFailure.inactiveAccount));
  });
}
