import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Palavra de sinal: o título da placa, em caixa alta e condensado.
///
/// Com [flip], as letras giram no eixo horizontal como plaquetas, uma a uma.
/// Quando a animação termina, a palavra volta a ser um texto corrido.
///
/// Uma palavra de sinal nunca é cortada no meio: se a mais longa não couber
/// na largura (tela estreita, letra ampliada no sistema), a letra diminui
/// até caber.
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final label = text.toUpperCase();
        final fitted = _fit(context, label, constraints.maxWidth);
        final plain = Text(label, style: fitted, semanticsLabel: text);
        final flip = this.flip;
        if (flip == null) return plain;

        return AnimatedBuilder(
          animation: flip,
          builder: (context, _) {
            if (flip.value >= 1) return plain;
            return Semantics(
              label: text,
              child: ExcludeSemantics(child: _letters(context, label, fitted, flip.value)),
            );
          },
        );
      },
    );
  }

  /// O estilo com o tamanho de letra em que a palavra mais longa cabe em [maxWidth].
  TextStyle _fit(BuildContext context, String label, double maxWidth) {
    if (!maxWidth.isFinite) return style;

    var widest = 0.0;
    for (final word in label.split(' ')) {
      widest = math.max(widest, _measure(context, word, style));
    }
    if (widest <= maxWidth) return style;

    final size = style.fontSize ?? DefaultTextStyle.of(context).style.fontSize ?? 14;
    return style.copyWith(fontSize: size * maxWidth / widest);
  }

  /// A palavra separada em letras, cada uma no seu ponto do giro.
  Widget _letters(BuildContext context, String label, TextStyle style, double progress) {
    final elapsed = progress * flipDuration(text).inMicroseconds;
    var index = 0;

    return Wrap(
      spacing: _measure(context, ' ', style),
      children: [
        for (final word in label.split(' '))
          // Letra por letra a palavra pode ficar um fio mais larga do que
          // inteira; o FittedBox garante que ela nunca passe da borda.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final letter in word.characters)
                  _tile(letter, style, (elapsed - _stagger.inMicroseconds * index++) / _letterTime.inMicroseconds),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tile(String letter, TextStyle style, double time) {
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

  /// Largura de [piece] em uma linha só, do jeito que o Text vai desenhar.
  double _measure(BuildContext context, String piece, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: piece, style: DefaultTextStyle.of(context).style.merge(style)),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }
}
