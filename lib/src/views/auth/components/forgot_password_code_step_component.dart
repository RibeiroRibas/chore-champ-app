import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

class ForgotPasswordCodeStepComponent extends StatelessWidget {
  const ForgotPasswordCodeStepComponent({
    super.key,
    required this.email,
    required this.codeControllers,
    required this.codeFocusNodes,
    required this.onVerify,
    required this.onResend,
  });

  final String email;
  final List<TextEditingController> codeControllers;
  final List<FocusNode> codeFocusNodes;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(AppStrings.enterCode, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: [
              const TextSpan(text: '${AppStrings.weSentCodeTo} '),
              TextSpan(
                text: email,
                style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.foreground),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 44,
                child: TextFormField(
                  controller: codeControllers[i],
                  focusNode: codeFocusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: const InputDecoration(counterText: ''),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) codeFocusNodes[i + 1].requestFocus();
                  },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onVerify,
            child: const Text(AppStrings.verifyCode),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onResend,
          child: const Text(AppStrings.resendCode),
        ),
      ],
    );
  }
}
