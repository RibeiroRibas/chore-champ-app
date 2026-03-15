import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/infra/api_error_presentation.dart';
import 'package:chore_champ_app/src/infra/api_exception.dart';
import 'package:chore_champ_app/src/providers/auth_provider.dart';
import 'package:chore_champ_app/src/views/auth/components/auth_logo_component.dart';

class CreateAccountCodePage extends ConsumerStatefulWidget {
  const CreateAccountCodePage({super.key});

  @override
  ConsumerState<CreateAccountCodePage> createState() => _CreateAccountCodePageState();
}

class _CreateAccountCodePageState extends ConsumerState<CreateAccountCodePage> {
  final _codeControllers = List.generate(4, (_) => TextEditingController());
  final _codeFocusNodes = List.generate(4, (_) => FocusNode());
  bool _loading = false;
  int _resendSecondsRemaining = 120;
  Timer? _resendTimer;
  bool _resendLoading = false;

  String get _email => (GoRouterState.of(context).extra as Map<String, dynamic>?)?['email'] as String? ?? '';
  String get _password => (GoRouterState.of(context).extra as Map<String, dynamic>?)?['password'] as String? ?? '';

  bool get _canSubmit => _getCodeAsInt() != null;

  void _listenToForm() => setState(() {});

  @override
  void initState() {
    super.initState();
    for (final c in _codeControllers) {
      c.addListener(_listenToForm);
    }
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    if (_resendSecondsRemaining <= 0) return;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_resendSecondsRemaining > 0) {
          _resendSecondsRemaining--;
        }
        if (_resendSecondsRemaining <= 0) {
          _resendTimer?.cancel();
          _resendTimer = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _codeControllers) {
      c.removeListener(_listenToForm);
      c.dispose();
    }
    for (final f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  int? _getCodeAsInt() {
    final s = _codeControllers.map((c) => c.text.trim()).join();
    if (s.length != 4) return null;
    return int.tryParse(s);
  }

  Future<void> _handleResendCode() async {
    if (_email.isEmpty) return;
    setState(() => _resendLoading = true);
    try {
      await ref.read(authProvider.notifier).sendEmailCreateAuthCode(_email);
      if (!mounted) return;
      setState(() {
        _resendLoading = false;
        _resendSecondsRemaining = 120;
      });
      _startResendTimer();
      if (!mounted) return;
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

  String get _resendButtonLabel {
    if (_resendSecondsRemaining > 0) {
      final m = _resendSecondsRemaining ~/ 60;
      final s = _resendSecondsRemaining % 60;
      return 'Reenviar código por e-mail ($m:${s.toString().padLeft(2, '0')})';
    }
    return 'Reenviar código por e-mail';
  }

  Future<void> _handleConfirm() async {
    final code = _getCodeAsInt();
    if (code == null) {
      if (!mounted) return;
      showGenericErrorSnackBar(context, message: 'Informe o código de 4 dígitos.');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).createAuth(
            email: _email,
            password: _password,
            emailConfirmationCode: code,
          );
      if (!mounted) return;
      context.go('/login');
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
                      onPressed: _loading ? null : () => context.go('/create-account'),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text(AppStrings.backToLogin),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AuthLogoComponent(),
                  const SizedBox(height: 32),
                  Text(AppStrings.enterCode, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.enterCodeSentToEmail,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  if (_email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: SizedBox(
                          width: 52,
                          child: TextFormField(
                            controller: _codeControllers[i],
                            focusNode: _codeFocusNodes[i],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            decoration: const InputDecoration(counterText: ''),
                            onChanged: (v) {
                              if (v.isNotEmpty && i < 3) _codeFocusNodes[i + 1].requestFocus();
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
                      onPressed: (_loading || !_canSubmit) ? null : _handleConfirm,
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(AppStrings.confirmCode),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: (_resendSecondsRemaining > 0 || _resendLoading || _email.isEmpty)
                        ? null
                        : _handleResendCode,
                    child: _resendLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_resendButtonLabel),
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
