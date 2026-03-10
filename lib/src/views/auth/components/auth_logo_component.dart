import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

class AuthLogoComponent extends StatelessWidget {
  const AuthLogoComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.emoji_events, color: AppColors.primaryForeground, size: 28),
        ),
        const SizedBox(width: 8),
        Text(
          AppStrings.appName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground),
        ),
      ],
    );
  }
}
