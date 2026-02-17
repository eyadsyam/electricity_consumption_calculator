import 'package:flutter/material.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:animate_do/animate_do.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.bgBlack,
      body: Center(
        child: SpinPerfect(
          infinite: true,
          duration: const Duration(seconds: 2),
          child: Image.asset(
            'assets/images/app_logo_elegant.png',
            width: isSmallScreen ? 120 : 160,
            height: isSmallScreen ? 120 : 160,
          ),
        ),
      ),
    );
  }
}
