import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:flutter/material.dart';

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
          child: const Icon(
            Icons.check_circle,
            color: AppColors.secondary,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.codeVerified,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.passwordResetSuccess,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
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
