import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

class ForgotPasswordEmailStepComponent extends StatelessWidget {
  const ForgotPasswordEmailStepComponent({
    super.key,
    required this.emailController,
    required this.onSendCode,
  });

  final TextEditingController emailController;
  final VoidCallback onSendCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(AppStrings.forgotPasswordTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(AppStrings.sendCodeToEmail, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: AppStrings.email,
            hintText: AppStrings.emailExample,
            prefixIcon: Icon(Icons.mail_outline, color: AppColors.mutedForeground, size: 20),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSendCode,
            child: const Text(AppStrings.sendCode),
          ),
        ),
      ],
    );
  }
}
