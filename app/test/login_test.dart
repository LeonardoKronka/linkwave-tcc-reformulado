import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lockmachine/app.dart';
import 'package:lockmachine/auth/auth_service.dart';
import 'package:lockmachine/auth/fake_auth_service.dart';
import 'package:lockmachine/auth/session.dart';

/// Servidor fora do ar: toda tentativa falha por falta de resposta.
class OfflineAuthService implements AuthService {
  @override
  Future<Session> signIn({required String email, required String password}) async {
    throw const AuthException(AuthFailure.serverUnreachable);
  }
}

/// Abre o aplicativo numa tela de celular e espera a placa terminar de cair.
Future<void> openApp(
  WidgetTester tester, {
  AuthService? auth,
  Size screen = const Size(360, 780),
  double textScale = 1,
  bool still = false,
}) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = screen * 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  if (still) {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
  }
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  await tester.pumpWidget(
    LockMachineApp(
      auth: auth ?? FakeAuthService(delay: Duration.zero),
      demoAccounts: FakeAuthService.shortcuts,
    ),
  );
  await tester.pumpAndSettle();
}

Finder get emailField => find.byType(TextField).at(0);
Finder get passwordField => find.byType(TextField).at(1);

/// Preenche os dois campos e toca em "Entrar".
Future<void> signIn(WidgetTester tester, String email, String password) async {
  await tester.enterText(emailField, email);
  await tester.enterText(passwordField, password);
  await tester.tap(find.text('ENTRAR'));
  await tester.pumpAndSettle();
}

/// Rola a tela até o alvo aparecer e toca nele.
Future<void> tapAfterScrolling(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pump();
}

void main() {
  testWidgets('abre na placa de acesso restrito, com o aviso de demonstração', (tester) async {
    await openApp(tester);

    expect(find.text('ACESSO RESTRITO'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.textContaining('Modo demonstração'), findsOneWidget);
  });

  testWidgets('com os campos vazios, pede e-mail e senha', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('ENTRAR'));
    await tester.pumpAndSettle();

    expect(find.text('Preencha o e-mail e a senha para continuar.'), findsOneWidget);
    expect(find.text('ACESSO RESTRITO'), findsOneWidget);
  });

  testWidgets('com e-mail mal escrito, mostra como ele deve ser', (tester) async {
    await openApp(tester);

    await signIn(tester, 'supervisor', '1234');

    expect(find.text('Digite um e-mail válido, como supervisor@empresa.com.'), findsOneWidget);
  });

  testWidgets('com a senha errada, continua no login e diz o motivo', (tester) async {
    await openApp(tester);

    await signIn(tester, 'supervisor@empresa.test', 'errada');

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.text('ACESSO RESTRITO'), findsOneWidget);
  });

  testWidgets('o atalho do aviso preenche a conta de teste', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('OPERADOR'));
    await tester.pump();

    expect(tester.widget<TextField>(emailField).controller!.text, 'marina@empresa.test');
    expect(tester.widget<TextField>(passwordField).controller!.text, '1234');
  });

  testWidgets('o supervisor entra: a placa vira "Liberado" e abre a área dele', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('SUPERVISOR'));
    await tester.pump();
    await tester.tap(find.text('ENTRAR'));
    // A resposta chega e a cabeça da placa começa a virar.
    await tester.pump(const Duration(milliseconds: 50));
    // No meio da virada, ela já mostra o veredito.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('LIBERADO'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('SUPERVISOR'), findsOneWidget);
    expect(find.text('Leonardo Silva'), findsOneWidget);
    expect(find.textContaining('Em construção'), findsOneWidget);
    expect(find.text('ACESSO RESTRITO'), findsNothing);
  });

  testWidgets('o operador entra e vê a área dele', (tester) async {
    await openApp(tester);

    await signIn(tester, 'marina@empresa.test', '1234');

    expect(find.text('OPERADOR'), findsOneWidget);
    expect(find.text('Marina Costa'), findsOneWidget);
    expect(find.textContaining('capacitações'), findsOneWidget);
  });

  testWidgets('"Sair" volta para o login, com os campos limpos', (tester) async {
    await openApp(tester);
    await signIn(tester, 'supervisor@empresa.test', '1234');

    await tester.tap(find.text('SAIR'));
    await tester.pumpAndSettle();

    expect(find.text('ACESSO RESTRITO'), findsOneWidget);
    expect(tester.widget<TextField>(emailField).controller!.text, isEmpty);
    expect(tester.widget<TextField>(passwordField).controller!.text, isEmpty);
  });

  testWidgets('sem resposta do servidor, avisa e continua no login', (tester) async {
    await openApp(tester, auth: OfflineAuthService());

    await signIn(tester, 'supervisor@empresa.test', '1234');

    expect(find.text('Sem resposta do servidor. Confira a rede e tente de novo.'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
  });

  testWidgets('conta desativada não entra', (tester) async {
    final auth = FakeAuthService(
      delay: Duration.zero,
      accounts: const [
        DemoAccount(name: 'Ana Lima', email: 'ana@empresa.test', role: Role.machineOperator, active: false),
      ],
    );
    await openApp(tester, auth: auth);

    await signIn(tester, 'ana@empresa.test', '1234');

    expect(find.text('Esta conta está desativada. Fale com o administrador.'), findsOneWidget);
  });

  testWidgets('com as animações do sistema desligadas, o login funciona igual', (tester) async {
    await openApp(tester, still: true);

    await signIn(tester, 'supervisor@empresa.test', '1234');

    expect(find.text('SUPERVISOR'), findsOneWidget);
    expect(find.text('Leonardo Silva'), findsOneWidget);
  });

  testWidgets('cabe numa tela pequena com a letra ampliada', (tester) async {
    // Um texto que não coubesse faria o teste falhar, com erro de estouro.
    await openApp(tester, screen: const Size(320, 568), textScale: 1.5);

    await tapAfterScrolling(tester, find.text('ENTRAR'));
    await tester.pumpAndSettle();
    expect(find.text('Preencha o e-mail e a senha para continuar.'), findsOneWidget);

    await tapAfterScrolling(tester, find.text('SUPERVISOR'));
    await tapAfterScrolling(tester, find.text('ENTRAR'));
    await tester.pumpAndSettle();

    expect(find.text('Leonardo Silva'), findsOneWidget);
  });
}
