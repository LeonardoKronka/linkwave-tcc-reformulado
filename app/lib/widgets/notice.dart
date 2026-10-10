import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import '../theme/type.dart';
import 'app_icon.dart';

/// Aviso: uma plaquinha amarela. Todo trecho de demonstração ou em
/// construção leva um, para ninguém tomar por pronto o que ainda não é.
class Notice extends StatelessWidget {
  const Notice({super.key, required this.text, this.child});

  final String text;

  /// Conteúdo extra abaixo do texto (por exemplo, as contas de teste).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(color: AppColors.yellow, borderRadius: BorderRadius.circular(AppSizes.radius)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: AppIcon(AppIconShape.warn, size: 21, color: AppColors.ink),
              ),
              const SizedBox(width: 11),
              Expanded(child: Text(text, style: AppText.notice)),
            ],
          ),
          if (child != null) Padding(padding: const EdgeInsets.only(top: 12), child: child),
        ],
      ),
    );
  }
}
