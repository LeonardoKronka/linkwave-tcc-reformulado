/// Perfil de quem entra. O servidor terá os três; o aplicativo atende o
/// supervisor e o operador (o administrador trabalha no painel web).
enum Role {
  admin('Administrador'),
  supervisor('Supervisor'),
  // "operator" sozinho é palavra reservada da linguagem Dart.
  machineOperator('Operador');

  const Role(this.label);

  /// Nome do perfil como aparece na tela.
  final String label;
}

/// Quem está usando o aplicativo agora.
class Session {
  const Session({required this.name, required this.email, required this.role, required this.startedAt});

  final String name;
  final String email;
  final Role role;

  /// Quando a pessoa entrou.
  final DateTime startedAt;
}
