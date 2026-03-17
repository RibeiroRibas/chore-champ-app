import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/helpers/phone.dart';
import 'package:chore_champ_app/src/infra/api_error_presentation.dart';
import 'package:chore_champ_app/src/infra/api_exception.dart';
import 'package:chore_champ_app/src/providers/session_provider.dart';
import 'package:chore_champ_app/src/views/auth/components/auth_logo_component.dart';

class CreateUserFirstAccessPage extends ConsumerStatefulWidget {
  const CreateUserFirstAccessPage({super.key});

  @override
  ConsumerState<CreateUserFirstAccessPage> createState() =>
      _CreateUserFirstAccessPageState();
}

class _CreateUserFirstAccessPageState
    extends ConsumerState<CreateUserFirstAccessPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;

  String get _phoneDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  bool get _canSubmit {
    if (_nameController.text.trim().isEmpty) return false;
    if (_familyNameController.text.trim().isEmpty) return false;
    if (!isValidCellPhone(_phoneController.text)) return false;
    return true;
  }

  void _listenToForm() => setState(() {});

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_listenToForm);
    _familyNameController.addListener(_listenToForm);
    _phoneController.addListener(_listenToForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_listenToForm);
    _familyNameController.removeListener(_listenToForm);
    _phoneController.removeListener(_listenToForm);
    _nameController.dispose();
    _familyNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_phoneDigits.length != 11) {
      if (!mounted) return;
      showGenericErrorSnackBar(
        context,
        message: 'Informe o telefone completo.',
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref
          .read(sessionProvider.notifier)
          .completeFirstAccess(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            familyName: _familyNameController.text.trim(),
          );
      if (!mounted) return;
      context.go('/');
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
                  Text(
                    AppStrings.firstAccessTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.firstAccessSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: AppStrings.name,
                            hintText: 'Seu nome',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppColors.mutedForeground,
                              size: 20,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe seu nome'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _familyNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: AppStrings.familyName,
                            hintText: AppStrings.familyNameHint,
                            prefixIcon: Icon(
                              Icons.group_outlined,
                              color: AppColors.mutedForeground,
                              size: 20,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Informe o nome da família'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            PhoneInputFormatter(),
                            LengthLimitingTextInputFormatter(16),
                          ],
                          decoration: const InputDecoration(
                            labelText: AppStrings.phone,
                            hintText: AppStrings.phoneHint,
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: AppColors.mutedForeground,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (!isValidCellPhone(v)) {
                              return 'Informe o telefone no formato (XX) XXXXX-XXXX';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (_loading || !_canSubmit)
                                ? null
                                : _handleSubmit,
                            child: _loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(AppStrings.completeRegistration),
                          ),
                        ),
                      ],
                    ),
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
