import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../components/auth_logo_component.dart';
import '../components/forgot_password_code_step_component.dart';
import '../components/forgot_password_email_step_component.dart';
import '../components/forgot_password_success_step_component.dart';

enum ForgotStep { email, code, success }

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  ForgotStep _step = ForgotStep.email;
  final _emailController = TextEditingController();
  final _codeControllers = List.generate(6, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _codeControllers) c.dispose();
    for (final f in _codeFocusNodes) f.dispose();
    super.dispose();
  }

  void _handleSendCode() {
    setState(() => _step = ForgotStep.code);
  }

  void _handleVerifyCode() {
    setState(() => _step = ForgotStep.success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text(AppStrings.backToLogin),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AuthLogoComponent(),
                  const SizedBox(height: 32),
                  if (_step == ForgotStep.email)
                    ForgotPasswordEmailStepComponent(
                      emailController: _emailController,
                      onSendCode: _handleSendCode,
                    ),
                  if (_step == ForgotStep.code)
                    ForgotPasswordCodeStepComponent(
                      email: _emailController.text,
                      codeControllers: _codeControllers,
                      codeFocusNodes: _codeFocusNodes,
                      onVerify: _handleVerifyCode,
                      onResend: () {},
                    ),
                  if (_step == ForgotStep.success)
                    ForgotPasswordSuccessStepComponent(
                      onBackToLogin: () => context.go('/login'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
