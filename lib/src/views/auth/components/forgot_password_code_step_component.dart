import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:flutter/material.dart';

class ForgotPasswordCodeStepComponent extends StatefulWidget {
  const ForgotPasswordCodeStepComponent({
    super.key,
    required this.formKey,
    required this.email,
    required this.codeControllers,
    required this.codeFocusNodes,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onResetPassword,
    required this.onResend,
    this.loading = false,
    this.resendLoading = false,
  });

  final GlobalKey<FormState> formKey;
  final String email;
  final List<TextEditingController> codeControllers;
  final List<FocusNode> codeFocusNodes;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onResetPassword;
  final VoidCallback onResend;
  final bool loading;
  final bool resendLoading;

  @override
  State<ForgotPasswordCodeStepComponent> createState() =>
      _ForgotPasswordCodeStepComponentState();
}

class _ForgotPasswordCodeStepComponentState
    extends State<ForgotPasswordCodeStepComponent> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          Text(
            AppStrings.enterCode,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                const TextSpan(text: '${AppStrings.weSentCodeTo} '),
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  width: 52,
                  child: TextFormField(
                    controller: widget.codeControllers[i],
                    focusNode: widget.codeFocusNodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3)
                        widget.codeFocusNodes[i + 1].requestFocus();
                    },
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: AppStrings.password,
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.mutedForeground,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.mutedForeground,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe a nova senha';
              if (v.length < 6)
                return 'A senha deve ter no mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.confirmPasswordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: AppStrings.confirmPassword,
              hintText: '••••••••',
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.mutedForeground,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.mutedForeground,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirme a senha';
              if (v != widget.passwordController.text)
                return 'As senhas não coincidem';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.loading
                  ? null
                  : () {
                      if (widget.formKey.currentState?.validate() == true)
                        widget.onResetPassword();
                    },
              child: widget.loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(AppStrings.resetPasswordButton),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: (widget.resendLoading || widget.loading)
                ? null
                : widget.onResend,
            child: widget.resendLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppStrings.resendCode),
          ),
        ],
      ),
    );
  }
}
