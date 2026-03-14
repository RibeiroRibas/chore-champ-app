import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:flutter/material.dart';

final _emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
);

class ForgotPasswordEmailStepComponent extends StatelessWidget {
  const ForgotPasswordEmailStepComponent({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.onSendCode,
    this.loading = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final VoidCallback onSendCode;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Text(AppStrings.forgotPasswordTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(AppStrings.sendCodeToEmail, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: AppStrings.email,
              hintText: AppStrings.emailExample,
              prefixIcon: Icon(Icons.mail_outline, color: AppColors.mutedForeground, size: 20),
            ),
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) return 'Informe o e-mail';
              if (!_emailRegex.hasMatch(value)) return AppStrings.invalidEmail;
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onSendCode,
              child: loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(AppStrings.sendCode),
            ),
          ),
        ],
      ),
    );
  }
}
