import 'package:flutter/material.dart';
import 'package:finalproject/core/theme/app_colors.dart';

class LuxuryDivider extends StatelessWidget {
  final String text;
  const LuxuryDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white12)),
      ],
    );
  }
}

class LuxuryLoading extends StatelessWidget {
  const LuxuryLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.electricBlue),
    );
  }
}
