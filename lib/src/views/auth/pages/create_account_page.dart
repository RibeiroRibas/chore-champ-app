import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../infra/api_error_presentation.dart';
import '../../../infra/api_exception.dart';
import '../../../providers/auth_provider.dart';
import '../components/auth_logo_component.dart';
import '../components/auth_sign_up_link_component.dart';

class CreateAccountPage extends ConsumerStatefulWidget {
  const CreateAccountPage({super.key});

  @override
  ConsumerState<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends ConsumerState<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .sendEmailCreateAuthCode(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _loading = false);
      await context.push(
        '/create-account-code',
        extra: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showApiErrorSnackBar(context, e);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
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
                      onPressed: _loading ? null : () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text(AppStrings.backToLogin),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AuthLogoComponent(),
                  const SizedBox(height: 32),
                  Text(
                    AppStrings.createAccount,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.joinFamilyTeam,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: AppStrings.email,
                            hintText: AppStrings.emailExample,
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: AppColors.mutedForeground,
                              size: 20,
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Informe o e-mail'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
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
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.mutedForeground,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Informe a senha';
                            }
                            if (v.length < 6) {
                              return 'A senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscurePassword,
                          decoration: const InputDecoration(
                            labelText: AppStrings.confirmPassword,
                            hintText: '••••••••',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppColors.mutedForeground,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Confirme a senna';
                            }
                            if (v.length < 6) {
                              return 'A senha deve ter no mínimo 6 caracteres';
                            }
                            if (v != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _handleSendCode,
                            child: _loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(AppStrings.sendCode),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthSignUpLinkComponent(
                    onPressed: () => context.go('/login'),
                    promptText: AppStrings.alreadyHaveAccount,
                    linkText: AppStrings.signIn,
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
