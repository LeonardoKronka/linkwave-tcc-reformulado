import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import '../theme/type.dart';

/// A marca LockMachine: o cadeado branco no quadrado vermelho e o nome.
/// É o mesmo desenho do site (lá ele é feito em CSS, .brand-mark--lock).
class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'LockMachine',
      child: const ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(size: Size.square(32), painter: _LockMarkPainter()),
            SizedBox(width: 10),
            Text('LOCKMACHINE', style: AppText.brand),
          ],
        ),
      ),
    );
  }
}

class _LockMarkPainter extends CustomPainter {
  const _LockMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32);
    final white = Paint()..color = AppColors.white;

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 32, 32), const Radius.circular(6)),
      Paint()..color = AppColors.red,
    );

    // Haste do cadeado: sobe, faz o arco e desce.
    final shackle = Path()
      ..moveTo(11.6, 16)
      ..lineTo(11.6, 10.9)
      ..arcToPoint(const Offset(20.4, 10.9), radius: const Radius.circular(4.4))
      ..lineTo(20.4, 16);
    canvas.drawPath(
      shackle,
      white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.7,
    );

    // Corpo do cadeado.
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(6.7, 13.4, 18.6, 12.8), const Radius.circular(2.2)),
      white..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_LockMarkPainter oldDelegate) => false;
}
