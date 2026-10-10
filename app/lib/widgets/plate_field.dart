import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../theme/type.dart';

/// Campo de formulário: rótulo em caixa alta acima e borda preta de 2px.
/// Com foco a borda fica azul; com erro, vermelha. O texto do erro não fica
/// aqui: o formulário mostra uma mensagem só, abaixo dos campos.
class PlateField extends StatelessWidget {
  const PlateField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.hint,
    this.invalid = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.trailing,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hint;

  /// Marca o campo que precisa ser corrigido.
  final bool invalid;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  /// O que fica no fim do campo, do lado de dentro (por exemplo, "Mostrar").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O leitor de tela lê o rótulo junto com o campo, logo abaixo.
        ExcludeSemantics(child: Text(label.toUpperCase(), style: AppText.label)),
        const SizedBox(height: 6),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            onSubmitted: onSubmitted,
            autocorrect: false,
            enableSuggestions: false,
            style: AppText.body,
            // Ao focar, o campo sobe o bastante para o botão não ficar atrás do teclado.
            scrollPadding: const EdgeInsets.only(top: 24, bottom: 140),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: trailing,
              enabledBorder: invalid ? fieldBorder(AppColors.red) : null,
              focusedBorder: invalid ? fieldBorder(AppColors.red, focused: true) : null,
            ),
          ),
        ),
      ],
    );
  }
}
