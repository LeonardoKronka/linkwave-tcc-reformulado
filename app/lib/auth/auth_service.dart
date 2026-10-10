import 'session.dart';

/// Contrato da autenticação: é tudo o que a tela de login conhece.
///
/// Hoje quem responde é o FakeAuthService, com contas de demonstração.
/// Quando a API em PHP existir (POST /api/login, no plano da apresentação),
/// entra no lugar outra classe com este mesmo contrato, e a tela não muda.
abstract interface class AuthService {
  /// Confere e-mail e senha. Devolve a sessão ou lança [AuthException].
  Future<Session> signIn({required String email, required String password});
}

/// Por que o login não deu certo.
enum AuthFailure {
  /// E-mail ou senha não conferem.
  invalidCredentials,

  /// A conta existe, mas foi desativada pelo administrador.
  inactiveAccount,

  /// O aplicativo não conseguiu falar com o servidor.
  serverUnreachable,
}

class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthException(${failure.name})';
}
