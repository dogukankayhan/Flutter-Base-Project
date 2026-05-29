import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../theme/game/game_colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x99000000),
      child: Center(
        child: SpinKitSpinningLines(
          color: AppColors.gold,
          size: 60,
        ),
      ),
    );
  }
}
