import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

class ForgotPasswordSuccessStepComponent extends StatelessWidget {
  const ForgotPasswordSuccessStepComponent({
    super.key,
    required this.onBackToLogin,
  });

  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppColors.secondary, size: 32),
        ),
        const SizedBox(height: 24),
        Text(AppStrings.codeVerified, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(AppStrings.youCanResetPassword, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onBackToLogin,
            child: const Text(AppStrings.backToLogin),
          ),
        ),
      ],
    );
  }
}
