import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/infra/api_error_presentation.dart';
import 'package:chore_champ_app/src/infra/api_exception.dart';
import 'package:chore_champ_app/src/providers/session_provider.dart';
import 'package:chore_champ_app/src/views/auth/components/auth_logo_component.dart';
import 'package:chore_champ_app/src/views/auth/components/auth_sign_up_link_component.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _loading = true);
    try {
      await ref.read(sessionProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;
      final state = ref.read(sessionProvider).valueOrNull;
      if (state?.needFirstAccess == true) {
        context.go('/create-user-first-access');
      } else {
        context.go('/');
      }
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
                  const AuthLogoComponent(),
                  const SizedBox(height: 32),
                  Text(AppStrings.welcomeBack, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(AppStrings.signInToAccount, style: Theme.of(context).textTheme.bodySmall),
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
                            prefixIcon: Icon(Icons.mail_outline, color: AppColors.mutedForeground, size: 20),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Informe o e-mail' : null,
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppStrings.password, style: Theme.of(context).textTheme.labelMedium),
                                TextButton(
                                  onPressed: _loading ? null : () => context.go('/forgot-password'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(AppStrings.forgotPassword),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.mutedForeground, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: AppColors.mutedForeground,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha' : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _handleLogin,
                            child: _loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(AppStrings.signIn),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthSignUpLinkComponent(
                    onPressed: () => context.go('/create-account'),
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
