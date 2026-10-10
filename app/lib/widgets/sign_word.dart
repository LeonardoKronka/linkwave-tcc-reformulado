import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Palavra de sinal: o título da placa, em caixa alta e condensado.
///
/// Com [flip], as letras giram no eixo horizontal como plaquetas, uma a uma.
/// Quando a animação termina, a palavra volta a ser um texto corrido.
class SignWord extends StatelessWidget {
  const SignWord(this.text, {super.key, required this.style, this.flip});

  /// Escrito normalmente ("Acesso restrito"); a caixa alta é posta aqui.
  final String text;
  final TextStyle style;

  /// Vai de 0 a 1 ao longo de [flipDuration]. Sem ela, a palavra aparece pronta.
  final Animation<double>? flip;

  static const _letterTime = Duration(milliseconds: 600);
  static const _stagger = Duration(milliseconds: 35);

  /// Tempo para todas as letras de [text] girarem.
  static Duration flipDuration(String text) {
    final letters = text.replaceAll(' ', '').characters.length;
    return _letterTime + _stagger * math.max(0, letters - 1);
  }

  @override
  Widget build(BuildContext context) {
    final label = text.toUpperCase();
    final plain = Text(label, style: style, semanticsLabel: text);
    final flip = this.flip;
    if (flip == null) return plain;

    return AnimatedBuilder(
      animation: flip,
      builder: (context, _) {
        if (flip.value >= 1) return plain;
        return Semantics(
          label: text,
          child: ExcludeSemantics(child: _letters(context, label, flip.value)),
        );
      },
    );
  }

  /// A palavra separada em letras, cada uma no seu ponto do giro.
  Widget _letters(BuildContext context, String label, double progress) {
    final elapsed = progress * flipDuration(text).inMicroseconds;
    var index = 0;

    return Wrap(
      spacing: _spaceWidth(context),
      children: [
        for (final word in label.split(' '))
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final letter in word.characters)
                _tile(letter, (elapsed - _stagger.inMicroseconds * index++) / _letterTime.inMicroseconds),
            ],
          ),
      ],
    );
  }

  Widget _tile(String letter, double time) {
    final turn = Curves.easeOutExpo.transform(time.clamp(0, 1));
    return Opacity(
      opacity: turn,
      child: Transform(
        alignment: Alignment.center,
        // A terceira linha da matriz dá a perspectiva: sem ela o giro fica chapado.
        transform: Matrix4.identity()
          ..setEntry(3, 2, 1 / 700)
          ..rotateX((1 - turn) * math.pi / 2),
        child: Text(letter, style: style),
      ),
    );
  }

  /// Largura de um espaço neste estilo, para as palavras ficarem à mesma
  /// distância do texto corrido.
  double _spaceWidth(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: ' ', style: DefaultTextStyle.of(context).style.merge(style)),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}
