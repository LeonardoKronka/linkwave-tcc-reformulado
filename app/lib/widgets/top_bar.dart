import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'brand.dart';

/// Barra superior preta com a marca, igual à do site. Ela entra por baixo da
/// barra de status do celular, que fica com os ícones claros.
class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0x00000000),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.wall,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        color: AppColors.ink,
        child: const SafeArea(
          bottom: false,
          child: SizedBox(
            height: AppSizes.topBar,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.gutter),
              child: Align(alignment: Alignment.centerLeft, child: Brand()),
            ),
          ),
        ),
      ),
    );
  }
}
