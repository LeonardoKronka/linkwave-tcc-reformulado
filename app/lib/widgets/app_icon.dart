import 'package:flutter/widgets.dart';

/// Ícones do aplicativo, os mesmos do site (.icon--* no base.css).
enum AppIconShape { arrow, back, warn }

/// Ícone desenhado: traço único de 2,6 numa grade de 24. Não usamos seta ou
/// símbolo de teclado como ícone.
class AppIcon extends StatelessWidget {
  const AppIcon(this.shape, {super.key, this.size = 18, this.color});

  final AppIconShape shape;
  final double size;

  /// Sem cor definida, usa a do botão ou do texto ao redor.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final paintColor = color ?? IconTheme.of(context).color ?? const Color(0xFF000000);
    return ExcludeSemantics(
      child: CustomPaint(size: Size.square(size), painter: _IconPainter(shape, paintColor)),
    );
  }
}

class _IconPainter extends CustomPainter {
  const _IconPainter(this.shape, this.color);

  final AppIconShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6;

    switch (shape) {
      case AppIconShape.arrow:
        final path = Path()
          ..moveTo(3, 12)
          ..lineTo(19, 12)
          ..moveTo(12, 5)
          ..lineTo(19, 12)
          ..lineTo(12, 19);
        canvas.drawPath(path, stroke);
      case AppIconShape.back:
        final path = Path()
          ..moveTo(21, 12)
          ..lineTo(5, 12)
          ..moveTo(12, 5)
          ..lineTo(5, 12)
          ..lineTo(12, 19);
        canvas.drawPath(path, stroke);
      case AppIconShape.warn:
        // Triângulo cheio com a exclamação vazada.
        final path = Path()
          ..fillType = PathFillType.evenOdd
          ..moveTo(12, 2)
          ..lineTo(23, 22)
          ..lineTo(1, 22)
          ..close()
          ..addRect(const Rect.fromLTWH(10.7, 9, 2.6, 6.5))
          ..addRect(const Rect.fromLTWH(10.7, 17.2, 2.6, 2.6));
        canvas.drawPath(path, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) => oldDelegate.shape != shape || oldDelegate.color != color;
}
