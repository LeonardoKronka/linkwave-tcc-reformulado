import 'package:flutter/painting.dart';

/// Cores do sistema visual, as mesmas do site
/// (linkwave-tcc-reformulado/assets/css/base.css). Se mudar lá, mude aqui.
///
/// A cor nunca decora, sempre significa: vermelho proíbe, amarelo alerta,
/// azul obriga, verde libera. Botões e textos comuns são pretos ou brancos.
abstract final class AppColors {
  // Código de cores da sinalização
  static const red = Color(0xFFC81E27);
  static const yellow = Color(0xFFFFC20E);
  static const blue = Color(0xFF0B55C4);
  static const green = Color(0xFF17714A);

  // Neutros, puxados para o cinza de parede de fábrica
  static const ink = Color(0xFF131614);
  static const inkSoft = Color(0xFF4D544F);
  static const wall = Color(0xFFE3E6E2);
  static const white = Color(0xFFFCFDFB);
  static const whiteSoft = Color(0xFFC9CFCA);
  static const line = Color(0xFFBFC5BF);
}

/// Medidas que se repetem. No site elas estão em rem; aqui, em pixels lógicos
/// (1rem = 16).
abstract final class AppSizes {
  /// Canto de botão, campo e aviso.
  static const radius = 10.0;

  /// Canto de placa.
  static const radiusPlate = 14.0;

  /// Borda de botão e de campo.
  static const border = 2.0;

  /// Borda da placa e anel de foco.
  static const keyline = 3.0;

  /// Altura mínima de botão e de campo: cabe um dedo.
  static const control = 48.0;

  /// Margem lateral da tela.
  static const gutter = 20.0;

  /// Altura da barra superior.
  static const topBar = 60.0;

  /// Largura máxima de uma placa, para tablet e navegador.
  static const plateMaxWidth = 480.0;
}

abstract final class AppShadows {
  /// Sombra curta de chapa presa à parede.
  static const plate = [
    BoxShadow(color: Color(0x38131614), offset: Offset(0, 1), blurRadius: 1),
    BoxShadow(color: Color(0x8C131614), offset: Offset(0, 14), blurRadius: 22, spreadRadius: -16),
  ];
}

/// Esmalte: a luz vertical muito leve de toda superfície colorida, mais clara
/// em cima e mais escura embaixo.
const enamel = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0x14FFFFFF), Color(0x00FFFFFF), Color(0x14000000)],
  stops: [0, 0.3, 1],
);
