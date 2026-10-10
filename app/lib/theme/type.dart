import 'package:flutter/painting.dart';

import 'tokens.dart';

/// Vozes do texto, as mesmas do site.
///
/// A Archivo é uma fonte variável: um arquivo só traz todos os pesos (wght) e
/// larguras (wdth), escolhidos aqui. Quanto maior o texto, mais condensado.
///
/// O Flutter não tem "caixa alta" no estilo: quem escreve em maiúsculas é o
/// widget, com toUpperCase().
abstract final class AppText {
  static const _archivo = 'Archivo';
  static const _mono = 'Martian Mono';

  /// Palavra de sinal: o título da placa.
  static const signWord = TextStyle(
    fontFamily: _archivo,
    fontSize: 38,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation.weight(800), FontVariation.width(68)],
    height: 0.88,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.38,
    color: AppColors.white,
  );

  /// Nome da marca na barra superior.
  static const brand = TextStyle(
    fontFamily: _archivo,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation.weight(800), FontVariation.width(80)],
    height: 1.2,
    letterSpacing: 0.4,
    color: AppColors.white,
  );

  /// Texto corrido.
  static const body = TextStyle(
    fontFamily: _archivo,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation.weight(400), FontVariation.width(100)],
    height: 1.55,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.ink,
  );

  /// Texto de apoio.
  static const small = TextStyle(
    fontFamily: _archivo,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation.weight(400), FontVariation.width(100)],
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.ink,
  );

  /// Mensagem de erro do formulário.
  static const error = TextStyle(
    fontFamily: _archivo,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation.weight(600), FontVariation.width(100)],
    height: 1.4,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.red,
  );

  /// Aviso amarelo.
  static const notice = TextStyle(
    fontFamily: _archivo,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation.weight(500), FontVariation.width(100)],
    height: 1.45,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.ink,
  );

  /// Rótulo: só para legenda de campo e cabeçalho de tabela.
  static const label = TextStyle(
    fontFamily: _archivo,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation.weight(700), FontVariation.width(100)],
    height: 1.55,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.78,
    color: AppColors.ink,
  );

  /// Texto de botão.
  static const button = TextStyle(
    fontFamily: _archivo,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation.weight(700), FontVariation.width(88)],
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0.75,
  );

  /// Dado medido ou código: RFID, horário, data. Só para isso.
  static const data = TextStyle(
    fontFamily: _mono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation.weight(400), FontVariation.width(87.5)],
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.55,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: 0,
    color: AppColors.ink,
  );
}
