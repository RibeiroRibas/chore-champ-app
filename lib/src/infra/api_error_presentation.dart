import 'package:flutter/material.dart';

import 'api_exception.dart';

const Map<int, String> _apiErrorCodeMessages = <int, String>{
  // Bad Request (400xxx)
  400300: 'Envio de código por e-mail está desativado.',
  400301: 'Este e-mail já está em uso. Escolha outro.',
  400302: 'Usuário já cadastrado para este acesso.',

  // Not Found (404xxx)
  404300: 'Código de verificação não encontrado.',
  404301: 'Membro não encontrado.',
  404302: 'Conta de acesso não encontrada.',
  404303: 'Perfil de acesso não encontrado.',
  404304: 'Família não encontrada.',

  // Unauthorized (401xxx)
  401300: 'Erro na validação do código.',
  401301: 'Código expirado.',
  401302: 'Código bloqueado.',
  401303: 'Código inválido.',
  401304: 'E-mail ou senha inválidos.',
};

const String defaultApiErrorMessage =
    'Algo deu errado. Tente novamente em instantes.';

String messageForApiCode(int code) {
  return _apiErrorCodeMessages[code] ?? defaultApiErrorMessage;
}

String userMessageFrom(ApiException exception) {
  final fromBody = exception.message;
  if (fromBody != null && fromBody.trim().isNotEmpty) {
    return fromBody.trim();
  }
  return messageForApiCode(exception.code);
}

void showApiErrorSnackBar(BuildContext context, ApiException exception) {
  if (!context.mounted) return;
  final theme = Theme.of(context);
  final message = userMessageFrom(exception);
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
