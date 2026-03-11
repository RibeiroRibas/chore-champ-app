import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../infra/api_error_presentation.dart';
import '../../../infra/api_exception.dart';
import '../../../providers/auth_provider.dart';
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
  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeControllers = List.generate(4, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(4, (_) => FocusNode());
  bool _loadingSendCode = false;
  bool _loadingReset = false;
  bool _resendLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (_emailFormKey.currentState?.validate() != true) return;
    setState(() => _loadingSendCode = true);
    try {
      await ref.read(authProvider.notifier).sendEmailForgetPasswordCode(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _loadingSendCode = false;
        _step = ForgotStep.code;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingSendCode = false);
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingSendCode = false);
      showGenericErrorSnackBar(context);
    }
  }

  int? _getCodeAsInt() {
    final s = _codeControllers.map((c) => c.text.trim()).join();
    if (s.length != 4) return null;
    return int.tryParse(s);
  }

  Future<void> _handleResetPassword() async {
    if (_codeFormKey.currentState?.validate() != true) return;
    final code = _getCodeAsInt();
    if (code == null) {
      showGenericErrorSnackBar(context, message: 'Informe o código de 4 dígitos.');
      return;
    }
    setState(() => _loadingReset = true);
    try {
      await ref.read(authProvider.notifier).resetPassword(
            email: _emailController.text.trim(),
            confirmationCode: code,
            password: _passwordController.text,
          );
      if (!mounted) return;
      setState(() {
        _loadingReset = false;
        _step = ForgotStep.success;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadingReset = false);
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingReset = false);
      showGenericErrorSnackBar(context);
    }
  }

  Future<void> _handleResend() async {
    setState(() => _resendLoading = true);
    try {
      await ref.read(authProvider.notifier).sendEmailForgetPasswordCode(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _resendLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código reenviado para o seu e-mail.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _resendLoading = false);
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      setState(() => _resendLoading = false);
      showGenericErrorSnackBar(context);
    }
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
                      formKey: _emailFormKey,
                      emailController: _emailController,
                      onSendCode: _handleSendCode,
                      loading: _loadingSendCode,
                    ),
                  if (_step == ForgotStep.code)
                    ForgotPasswordCodeStepComponent(
                      formKey: _codeFormKey,
                      email: _emailController.text,
                      codeControllers: _codeControllers,
                      codeFocusNodes: _codeFocusNodes,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      onResetPassword: _handleResetPassword,
                      onResend: _handleResend,
                      loading: _loadingReset,
                      resendLoading: _resendLoading,
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
