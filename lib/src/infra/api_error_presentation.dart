import 'package:flutter/material.dart';

import 'api_exception.dart';

const Map<int, String> _apiErrorCodeMessages = <int, String>{
  // Bad Request (400xxx)
  400300: 'Envio de código por e-mail está desativado.',
  400301: 'Este e-mail já está em uso. Escolha outro.',
  400302: 'Usuário já cadastrado para este acesso.',
  400303: 'O telefone informado não está no formato adequado',

  // Not Found (404xxx)
  404300: 'Código de verificação não encontrado.',
  404301: 'Membro não encontrado.',
  404302: 'Conta de acesso não encontrada.',
  404303: 'Perfil de acesso não encontrado.',
  404304: 'Família não encontrada.',

  // Unauthorized (401xxx)
  401300: 'Esse código já foi usado. Por favor, envie um novo código.',
  401301: 'Código expirado. Por favor, envie um novo código.',
  401302: 'Código bloqueado. Por favor, envie um novo código.',
  401303: 'Código inválido.',
  401304: 'E-mail ou senha inválidos.',
  401305: 'Você não tem os privilégios necessários para realizar essa operação. Contate o administrador.',

  422000: 'Um ou mais campos estão em um formato inválido. Por favor, verifique'
};

const String defaultApiErrorMessage =
    'Algo deu errado. Tente novamente em instantes.';

String messageForApiCode(int code) {
  return _apiErrorCodeMessages[code] ?? defaultApiErrorMessage;
}

void showApiErrorSnackBar(BuildContext context, ApiException exception) {
  if (!context.mounted) return;
  final theme = Theme.of(context);
  final message = messageForApiCode(exception.code);
  final code = exception.code;
  final onError = theme.colorScheme.onError;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: theme.snackBarTheme.contentTextStyle ??
                theme.textTheme.bodyMedium?.copyWith(color: onError),
          ),
          const SizedBox(height: 6),
          Text(
            'Código: $code',
            style: (theme.snackBarTheme.contentTextStyle ??
                    theme.textTheme.bodyMedium)
                ?.copyWith(
              fontSize: 12,
              color: onError.withOpacity(0.85),
            ),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.error,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void showGenericErrorSnackBar(
  BuildContext context, {
  String? message,
  int? code,
}) {
  if (!context.mounted) return;
  final theme = Theme.of(context);
  final displayMessage = message ?? defaultApiErrorMessage;
  final onError = theme.colorScheme.onError;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: code != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayMessage,
                  style: theme.snackBarTheme.contentTextStyle ??
                      theme.textTheme.bodyMedium?.copyWith(color: onError),
                ),
                const SizedBox(height: 6),
                Text(
                  'Código: $code',
                  style: (theme.snackBarTheme.contentTextStyle ??
                          theme.textTheme.bodyMedium)
                      ?.copyWith(
                    fontSize: 12,
                    color: onError.withOpacity(0.85),
                  ),
                ),
              ],
            )
          : Text(
              displayMessage,
              style: theme.snackBarTheme.contentTextStyle ??
                  theme.textTheme.bodyMedium?.copyWith(color: onError),
            ),
      backgroundColor: theme.colorScheme.error,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
