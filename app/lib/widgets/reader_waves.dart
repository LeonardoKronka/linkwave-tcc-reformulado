import 'package:flutter/widgets.dart';

/// As ondas do leitor de crachá, pulsando uma depois da outra enquanto o
/// aplicativo confere alguma coisa. É o mesmo desenho do leitor do site.
///
/// Com as animações do sistema desligadas, as ondas ficam paradas.
class ReaderWaves extends StatefulWidget {
  const ReaderWaves({super.key, this.size = 18, this.color});

  final double size;

  /// Sem cor definida, usa a do botão ou do texto ao redor.
  final Color? color;

  @override
  State<ReaderWaves> createState() => _ReaderWavesState();
}

class _ReaderWavesState extends State<ReaderWaves> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _WavesPainter(_pulse, color, still: MediaQuery.disableAnimationsOf(context)),
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  _WavesPainter(this.pulse, this.color, {required this.still}) : super(repaint: pulse);

  final Animation<double> pulse;
  final Color color;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final waves = [
      Path()
        ..moveTo(5, 9)
        ..relativeLineTo(0, 6),
      Path()
        ..moveTo(10, 6.5)
        ..relativeCubicTo(2, 3.4, 2, 7.6, 0, 11),
      Path()
        ..moveTo(14.5, 4)
        ..relativeCubicTo(3.2, 5, 3.2, 11, 0, 16),
    ];

    for (var index = 0; index < waves.length; index++) {
      final paint = Paint()
        ..color = color.withValues(alpha: color.a * _strength(index))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6;
      canvas.drawPath(waves[index], paint);
    }
  }

  /// Cada onda acende e apaga, um pouco depois da anterior.
  double _strength(int index) {
    if (still) return 1;
    final phase = (pulse.value - index * 0.1) % 1;
    return phase < 0.3 ? 0.25 + 0.75 * (phase / 0.3) : 1 - 0.75 * ((phase - 0.3) / 0.7);
  }

  @override
  bool shouldRepaint(_WavesPainter oldDelegate) => oldDelegate.color != color || oldDelegate.still != still;
}
