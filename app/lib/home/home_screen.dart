import 'package:flutter/material.dart';

import '../auth/session.dart';
import '../theme/tokens.dart';
import '../theme/type.dart';
import '../widgets/app_icon.dart';
import '../widgets/notice.dart';
import '../widgets/plate.dart';
import '../widgets/plate_button.dart';
import '../widgets/top_bar.dart';

/// Primeira tela depois do login. Por enquanto ela só mostra quem entrou:
/// as telas do supervisor e do operador ainda não foram construídas, e o
/// aviso amarelo diz isso.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.session, required this.onSignOut});

  final Session session;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final pending = session.role == Role.machineOperator
        ? 'Em construção: a consulta das suas capacitações e validades ainda não foi feita neste aplicativo.'
        : 'Em construção: as tentativas ao vivo e a situação das máquinas ainda não foram feitas neste aplicativo.';

    return Scaffold(
      body: Column(
        children: [
          const AppTopBar(),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: AppSizes.plateMaxWidth),
                    child: Plate(
                      head: PlateHead(
                        word: session.role.label,
                        line: session.name,
                        flipDelay: const Duration(milliseconds: 150),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _Fact(
                              label: 'E-mail',
                              value: Text(session.email, style: AppText.body),
                            ),
                            const SizedBox(height: 16),
                            // Horário é dado medido: vai na fonte monoespaçada.
                            _Fact(
                              label: 'Entrou às',
                              value: Text(_clock(session.startedAt), style: AppText.data),
                            ),
                            const SizedBox(height: 24),
                            Notice(text: pending),
                            const SizedBox(height: 20),
                            PlateButton(
                              label: 'Sair',
                              ghost: true,
                              leading: const AppIcon(AppIconShape.back),
                              onPressed: onSignOut,
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

  /// Horário como se escreve no Brasil: 14:05.
  static String _clock(DateTime time) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}';
  }
}

/// Uma informação com a legenda em cima.
class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            semanticsLabel: label,
            style: AppText.label.copyWith(color: AppColors.inkSoft),
          ),
          value,
        ],
      ),
    );
  }
}
