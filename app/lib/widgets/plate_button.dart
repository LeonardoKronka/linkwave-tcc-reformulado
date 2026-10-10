import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';

/// Botão: uma chapa preta com texto em caixa alta. Enquanto é pressionado
/// (ou com o mouse em cima) fica vazado. Ação comum nunca usa cor de
/// sinalização: é preta ou branca.
class PlateButton extends StatelessWidget {
  const PlateButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.trailing,
    this.ghost = false,
    this.dense = false,
    this.surface = AppColors.white,
  });

  /// Escrito normalmente ("Entrar"); a caixa alta é posta aqui.
  final String label;

  /// Sem ação, o botão fica desligado.
  final VoidCallback? onPressed;

  /// Ícone antes ou depois do texto.
  final Widget? leading;
  final Widget? trailing;

  /// Versão vazada, para a ação secundária.
  final bool ghost;

  /// Versão mais baixa, para escolhas dentro de um aviso.
  final bool dense;

  /// Cor da superfície onde o botão está.
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: plateButtonStyle(surface: surface, ghost: ghost, dense: dense),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 9)],
          Flexible(child: Text(label.toUpperCase(), semanticsLabel: label)),
          if (trailing != null) ...[const SizedBox(width: 9), trailing!],
        ],
      ),
    );
  }
}
