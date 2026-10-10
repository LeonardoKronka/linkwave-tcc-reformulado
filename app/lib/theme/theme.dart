import 'package:flutter/material.dart';

import 'tokens.dart';
import 'type.dart';

/// Tema do aplicativo: liga os componentes do Flutter ao sistema visual das
/// placas. O fundo é sempre claro (sala iluminada, projetor, celular no
/// corredor), então não há tema escuro.
ThemeData buildAppTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.ink,
    onPrimary: AppColors.white,
    secondary: AppColors.blue,
    onSecondary: AppColors.white,
    error: AppColors.red,
    onError: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.ink,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.wall,
    fontFamily: 'Archivo',
    textTheme: const TextTheme(bodyLarge: AppText.body, bodyMedium: AppText.body, bodySmall: AppText.small),
    // Sem onda de tinta ao tocar: placa não é papel.
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.red,
      selectionColor: Color(0x33131614),
      selectionHandleColor: AppColors.ink,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      hintStyle: AppText.body.copyWith(color: AppColors.inkSoft),
      border: fieldBorder(AppColors.ink),
      enabledBorder: fieldBorder(AppColors.ink),
      disabledBorder: fieldBorder(AppColors.line),
      focusedBorder: fieldBorder(AppColors.blue, focused: true),
    ),
  );
}

/// Borda de campo. Com foco ela engrossa, como o anel de foco do site.
OutlineInputBorder fieldBorder(Color color, {bool focused = false}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSizes.radius),
    borderSide: BorderSide(color: color, width: focused ? AppSizes.keyline : AppSizes.border),
  );
}

/// Aparência de botão: uma chapa preta com texto na cor da superfície.
/// Pressionada (ou com o mouse em cima) ela fica vazada; a versão [ghost]
/// faz o contrário. [surface] é a cor de onde o botão está.
ButtonStyle plateButtonStyle({Color surface = AppColors.white, bool ghost = false, bool dense = false}) {
  bool hollow(Set<WidgetState> states) {
    final active = states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered);
    return ghost != active;
  }

  return ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(0, dense ? 40 : AppSizes.control)),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: dense ? 14 : 19, vertical: 8)),
    // A área de toque continua com 48 mesmo no botão baixo.
    tapTargetSize: MaterialTapTargetSize.padded,
    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radius))),
    side: WidgetStateProperty.resolveWith((states) {
      var color = AppColors.ink;
      if (states.contains(WidgetState.disabled)) color = AppColors.inkSoft;
      // Com foco pelo teclado, a borda engrossa e fica azul.
      final focused = states.contains(WidgetState.focused) && !states.contains(WidgetState.disabled);
      return BorderSide(color: focused ? AppColors.blue : color, width: focused ? AppSizes.keyline : AppSizes.border);
    }),
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return ghost ? Colors.transparent : AppColors.inkSoft;
      return hollow(states) ? Colors.transparent : AppColors.ink;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return ghost ? AppColors.inkSoft : surface;
      return hollow(states) ? AppColors.ink : surface;
    }),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: WidgetStatePropertyAll(dense ? AppText.button.copyWith(fontSize: 13) : AppText.button),
    splashFactory: NoSplash.splashFactory,
    animationDuration: const Duration(milliseconds: 150),
  );
}
