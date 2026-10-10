import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/auth_service.dart';
import '../auth/fake_auth_service.dart';
import '../auth/session.dart';
import '../theme/tokens.dart';
import '../theme/type.dart';
import '../widgets/app_icon.dart';
import '../widgets/notice.dart';
import '../widgets/plate.dart';
import '../widgets/plate_button.dart';
import '../widgets/plate_field.dart';
import '../widgets/reader_waves.dart';
import '../widgets/top_bar.dart';

/// Tela de login: a placa "Acesso restrito".
///
/// Ao abrir, a placa cai e é fixada. Com os dados certos, a cabeça dela vira
/// "Liberado" e o aplicativo abre; com erro, a placa balança de um lado para
/// o outro, como no site. Com as animações do sistema desligadas nada se
/// move: o estado muda na hora.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth, required this.onSignedIn, this.demoAccounts = const []});

  final AuthService auth;

  /// Chamado quando a pessoa entrou e a placa terminou de virar.
  final ValueChanged<Session> onSignedIn;

  /// Contas de teste oferecidas no aviso amarelo. Quando o login for de
  /// verdade a lista vem vazia, e o aviso some.
  final List<DemoAccount> demoAccounts;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Stage { idle, checking, granted }

enum _Field { email, password }

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // Virada da cabeça da placa, em milissegundos: fecha, abre e espera um instante.
  static const _flipClose = 180;
  static const _flipOpen = 350;
  static const _flipHold = 100;
  static const _flipTotal = _flipClose + _flipOpen + _flipHold;

  static final _emailShape = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _drop;
  late final AnimationController _shake;
  late final AnimationController _flip;
  late final CurvedAnimation _dropIn;
  late final CurvedAnimation _shakeEase;
  late final Animation<double> _shakeX;
  late final Animation<double> _flipAngle;

  var _stage = _Stage.idle;
  var _hidden = true;
  var _opened = false;
  _Field? _invalid;
  String? _error;
  Session? _session;

  /// O sistema pediu menos movimento.
  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _drop = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _flip = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _flipTotal),
    );

    _dropIn = CurvedAnimation(parent: _drop, curve: Curves.easeOutExpo);
    _shakeEase = CurvedAnimation(parent: _shake, curve: Curves.easeOut);

    // Um "não" com a cabeça: cada ida e volta menor que a anterior.
    _shakeX = TweenSequence<double>([
      for (final (from, to) in const [(0.0, -14.0), (-14.0, 12.0), (12.0, -8.0), (-8.0, 5.0), (5.0, 0.0)])
        TweenSequenceItem(
          tween: Tween(begin: from, end: to),
          weight: 1,
        ),
    ]).animate(_shakeEase);

    // A cabeça gira até ficar de perfil, troca de texto e volta.
    _flipAngle = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: math.pi / 2).chain(CurveTween(curve: Curves.easeIn)),
        weight: _flipClose.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: math.pi / 2, end: 0.0).chain(CurveTween(curve: Curves.easeOutExpo)),
        weight: _flipOpen.toDouble(),
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: _flipHold.toDouble()),
    ]).animate(_flip);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_opened) return;
    _opened = true;

    // A placa cai e é fixada. Sem animação, ela já aparece no lugar.
    if (_still) {
      _drop.value = 1;
    } else {
      _drop.forward();
    }
  }

  @override
  void dispose() {
    _dropIn.dispose();
    _shakeEase.dispose();
    _drop.dispose();
    _shake.dispose();
    _flip.dispose();
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stage != _Stage.idle) return;

    final email = _email.text.trim();
    final password = _password.text;

    if (email.isEmpty || password.trim().isEmpty) {
      _deny('Preencha o e-mail e a senha para continuar.', field: email.isEmpty ? _Field.email : _Field.password);
      return;
    }
    if (!_emailShape.hasMatch(email)) {
      _deny('Digite um e-mail válido, como supervisor@empresa.com.', field: _Field.email);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _stage = _Stage.checking;
      _error = null;
      _invalid = null;
    });

    final Session session;
    try {
      session = await widget.auth.signIn(email: email, password: password);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _stage = _Stage.idle);
      _deny(_failureText(error.failure));
      return;
    } catch (_) {
      // Um erro que o serviço não previu: a tela volta ao normal, para ninguém
      // ficar preso em "Conferindo", e o erro segue adiante para aparecer no log.
      if (mounted) {
        setState(() => _stage = _Stage.idle);
        _deny('Não foi possível entrar agora. Tente de novo.');
      }
      rethrow;
    }
    if (!mounted) return;

    // Acesso aceito: a cabeça da placa vira "Liberado" e o aplicativo abre.
    TextInput.finishAutofillContext();
    setState(() {
      _stage = _Stage.granted;
      _session = session;
    });
    await _flip.forward(from: 0);
    if (mounted) widget.onSignedIn(session);
  }

  /// Acesso negado: mostra o motivo, marca o campo e a placa balança.
  void _deny(String message, {_Field? field}) {
    setState(() {
      _error = message;
      _invalid = field;
    });

    switch (field) {
      case _Field.email:
        _emailFocus.requestFocus();
      case _Field.password:
        _passwordFocus.requestFocus();
      case null:
        break;
    }

    HapticFeedback.vibrate();
    if (!_still) _shake.forward(from: 0);
  }

  String _failureText(AuthFailure failure) {
    return switch (failure) {
      AuthFailure.invalidCredentials => 'E-mail ou senha incorretos.',
      AuthFailure.inactiveAccount => 'Esta conta está desativada. Fale com o administrador.',
      AuthFailure.serverUnreachable => 'Sem resposta do servidor. Confira a rede e tente de novo.',
    };
  }

  /// Preenche os campos com uma conta de teste.
  void _fill(DemoAccount account) {
    _email.text = account.email;
    _password.text = account.password;
    setState(() {
      _error = null;
      _invalid = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(),
          Expanded(
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, viewport) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter, vertical: 24),
                  child: ConstrainedBox(
                    // Com espaço sobrando, a placa fica no meio da tela.
                    constraints: BoxConstraints(minHeight: math.max(0, viewport.maxHeight - 48)),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: AppSizes.plateMaxWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _sign(),
                            const SizedBox(height: 20),
                            Text(
                              'Um projeto da LinkWave · TCC SENAI 2026',
                              textAlign: TextAlign.center,
                              style: AppText.small.copyWith(color: AppColors.inkSoft),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A placa inteira, com a queda da abertura e o balanço do "negado".
  Widget _sign() {
    return AnimatedBuilder(
      animation: Listenable.merge([_drop, _shake]),
      builder: (context, child) {
        final placed = _dropIn.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: placed,
          child: Transform.translate(
            offset: Offset(_shakeX.value, (1 - placed) * -70),
            child: Transform.rotate(angle: (1 - placed) * -3 * math.pi / 180, child: child),
          ),
        );
      },
      child: Plate(head: _head(), body: _body()),
    );
  }

  Widget _head() {
    return AnimatedBuilder(
      animation: _flip,
      builder: (context, _) {
        // O texto troca quando a cabeça está de perfil, sem ninguém ver.
        final granted = _stage == _Stage.granted && (_still || _flip.value * _flipTotal >= _flipClose);

        return Semantics(
          container: true,
          liveRegion: granted,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 1 / 800)
              ..rotateX(_still ? 0 : _flipAngle.value),
            child: PlateHead(
              word: granted ? 'Liberado' : 'Acesso restrito',
              line: granted
                  ? 'Abrindo a área do ${_session!.role.label.toLowerCase()}.'
                  : 'Supervisores e operadores cadastrados.',
              color: granted ? AppColors.green : AppColors.ink,
              lineColor: granted ? AppColors.white : AppColors.whiteSoft,
              flipDelay: const Duration(milliseconds: 300),
            ),
          ),
        );
      },
    );
  }

  Widget _body() {
    final busy = _stage != _Stage.idle;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlateField(
              label: 'E-mail',
              hint: 'supervisor@empresa.com',
              controller: _email,
              focusNode: _emailFocus,
              invalid: _invalid == _Field.email,
              enabled: !busy,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username, AutofillHints.email],
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 20),
            PlateField(
              label: 'Senha',
              hint: 'Digite sua senha',
              controller: _password,
              focusNode: _passwordFocus,
              invalid: _invalid == _Field.password,
              enabled: !busy,
              obscureText: _hidden,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              trailing: _PasswordToggle(
                hidden: _hidden,
                onPressed: busy ? null : () => setState(() => _hidden = !_hidden),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
              Semantics(liveRegion: true, child: Text(_error!, style: AppText.error)),
            ],
            const SizedBox(height: 20),
            PlateButton(
              label: busy ? 'Conferindo' : 'Entrar',
              trailing: busy ? const ReaderWaves() : const AppIcon(AppIconShape.arrow),
              onPressed: busy ? null : _submit,
            ),
            if (widget.demoAccounts.isNotEmpty) ...[
              const SizedBox(height: 20),
              Notice(
                text:
                    'Modo demonstração: o servidor ainda não existe. '
                    'Entre com uma conta de teste (a senha é ${widget.demoAccounts.first.password}).',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final account in widget.demoAccounts)
                      PlateButton(
                        label: account.role.label,
                        ghost: true,
                        dense: true,
                        surface: AppColors.yellow,
                        onPressed: busy ? null : () => _fill(account),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Mostrar" e "Ocultar", do lado de dentro do campo de senha.
class _PasswordToggle extends StatelessWidget {
  const _PasswordToggle({required this.hidden, required this.onPressed});

  final bool hidden;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final word = hidden ? 'Mostrar' : 'Ocultar';

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          disabledForegroundColor: AppColors.inkSoft,
          textStyle: AppText.label,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radius - 3)),
        ),
        child: Text(word.toUpperCase(), semanticsLabel: '$word senha'),
      ),
    );
  }
}
