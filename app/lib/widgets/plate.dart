import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import '../theme/type.dart';
import 'sign_word.dart';

/// Placa branca: uma chapa esmaltada lisa, com borda preta, cantos
/// arredondados e a sombra curta de quem está presa à parede.
/// Sem filete e sem parafusos (decisão do grupo, ver DESIGN.md).
class Plate extends StatelessWidget {
  const Plate({super.key, required this.head, required this.body});

  /// A faixa de cima, com a palavra de sinal ([PlateHead]).
  final Widget head;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final corners = BorderRadius.circular(AppSizes.radiusPlate);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.white, borderRadius: corners, boxShadow: AppShadows.plate),
      // A borda é pintada por cima do conteúdo: assim a cabeça da placa
      // encosta nela sem deixar uma linha clara nos cantos.
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: AppColors.ink, width: AppSizes.keyline),
        borderRadius: corners,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.keyline),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [head, body],
        ),
      ),
    );
  }
}

/// Cabeça da placa: a palavra de sinal, que é o título, e uma linha de
/// situação logo abaixo.
class PlateHead extends StatefulWidget {
  const PlateHead({
    super.key,
    required this.word,
    required this.line,
    this.color = AppColors.ink,
    this.lineColor = AppColors.whiteSoft,
    this.flipDelay,
  });

  final String word;
  final String line;

  /// Cor da faixa. Preto é neutro; as cores de sinalização só entram quando o
  /// significado delas é verdadeiro (verde: liberado).
  final Color color;
  final Color lineColor;

  /// Com um valor, as letras da palavra giram como plaquetas quando a placa
  /// aparece, depois desta espera. Sem valor, a palavra aparece pronta.
  final Duration? flipDelay;

  @override
  State<PlateHead> createState() => _PlateHeadState();
}

class _PlateHeadState extends State<PlateHead> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  CurvedAnimation? _flip;
  String? _flippingWord;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    // Com as animações do sistema desligadas, a palavra aparece pronta.
    final delay = widget.flipDelay;
    if (delay == null || MediaQuery.disableAnimationsOf(context)) return;

    final total = delay + SignWord.flipDuration(widget.word);
    final controller = AnimationController(vsync: this, duration: total);
    _controller = controller;
    _flip = CurvedAnimation(parent: controller, curve: Interval(delay.inMicroseconds / total.inMicroseconds, 1));
    _flippingWord = widget.word;
    controller.forward();
  }

  @override
  void dispose() {
    _flip?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A palavra cresce um pouco em telas mais largas, como no site.
    final width = MediaQuery.sizeOf(context).width;
    final wordStyle = AppText.signWord.copyWith(fontSize: (24 + width * 0.034).clamp(34, 52));
    // Só a palavra original gira; se ela mudar (por exemplo, para "Liberado"),
    // a nova entra pronta.
    final flip = widget.word == _flippingWord ? _flip : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
      color: widget.color,
      // O esmalte só vai nas cores de sinalização, nunca no preto.
      foregroundDecoration: widget.color == AppColors.ink ? null : const BoxDecoration(gradient: enamel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            // Com letra muito ampliada no sistema, o título para de crescer antes do resto.
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: SignWord(widget.word, style: wordStyle, flip: flip),
            ),
          ),
          const SizedBox(height: 10),
          Text(widget.line, style: AppText.small.copyWith(color: widget.lineColor)),
        ],
      ),
    );
  }
}
