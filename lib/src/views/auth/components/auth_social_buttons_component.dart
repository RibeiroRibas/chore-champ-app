import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:flutter/material.dart';

class AuthSocialButtonsComponent extends StatelessWidget {
  const AuthSocialButtonsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthSocialButton(
          label: AppStrings.continueWithGoogle,
          icon: Icons.g_mobiledata,
        ),
        const SizedBox(height: 12),
        _AuthSocialButton(
          label: AppStrings.continueWithApple,
          icon: Icons.apple,
        ),
      ],
    );
  }
}

class _AuthSocialButton extends StatelessWidget {
  const _AuthSocialButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}
