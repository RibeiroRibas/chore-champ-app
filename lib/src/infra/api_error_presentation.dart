import 'package:flutter/material.dart';

import 'api_exception.dart';

({Color background, Color foreground}) snackBarColorsForStatus(
  int statusCode,
  Color themeError,
  Color themeOnError,
) {
  if (statusCode >= 500) {
    return (background: themeError, foreground: themeOnError);
  }
  switch (statusCode) {
    case 400:
    case 422:
      return (background: Colors.amber.shade800, foreground: Colors.white);
    case 401:
    case 403:
      return (background: Colors.deepOrange.shade800, foreground: Colors.white);
    case 404:
      return (background: Colors.grey.shade800, foreground: Colors.white);
    default:
      return (background: themeError, foreground: themeOnError);
  }
}

const Map<int, String> _apiErrorCodeMessages = <int, String>{
  // Bad Request (400xxx)
  400300: 'Envio de código por e-mail está desativado.',
  400301: 'Este e-mail já está em uso. Escolha outro.',
  400302: 'Usuário já cadastrado para este acesso.',
  400303: 'O telefone informado não está no formato adequado',
  400304: 'Você não pode editar ou excluir uma tarefa depois de concluída',
  400305: 'Deve haver ao menos um administrador por família',
  400308: 'Não há responsável atribuído a esta tarefa.',
  400313:
      'Somente administradores da família podem remover a atribuição da tarefa.',
  400314:
      'Colaboradores só podem concluir tarefas que aparecem na lista do dia atual.',
  400315:
      'Colaboradores só podem criar tarefas atribuídas a si mesmos.',

  // Not Found (404xxx)
  404300: 'Código de verificação não encontrado.',
  404301: 'Membro removido ou não encontrado.',
  404302: 'Conta de acesso removida ou não encontrada.',
  404303: 'Perfil de acesso removido não encontrado.',
  404304: 'Família removida ou não encontrada.',
  404305: 'Tarefa removida ou não encontrada.',
  404306: 'Seu perfil de acesso foi removido ou não foi encontrado.',

  // Unauthorized (401xxx)
  401300: 'Esse código já foi usado. Por favor, envie um novo código.',
  401301: 'Código expirado. Por favor, envie um novo código.',
  401302: 'Código bloqueado. Por favor, envie um novo código.',
  401303: 'Código inválido.',
  401304: 'E-mail ou senha inválidos.',
  401305:
      'Você não tem os privilégios necessários para realizar essa operação. Contate o administrador.',
  401306:
      'Você não tem permissão para atualizar a tarefa de outro membro da família',
  401307:
      'Você não tem permissão de excluir a tarefa de outro membro da família',

  422000:
      'Um ou mais campos estão em um formato inválido. Por favor, verifique',
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
  final colors = snackBarColorsForStatus(
    exception.statusCode,
    theme.colorScheme.error,
    theme.colorScheme.onError,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style:
                theme.snackBarTheme.contentTextStyle ??
                theme.textTheme.bodyMedium?.copyWith(color: colors.foreground),
          ),
          const SizedBox(height: 6),
          Text(
            'Código: $code',
            style:
                (theme.snackBarTheme.contentTextStyle ??
                        theme.textTheme.bodyMedium)
                    ?.copyWith(
                      fontSize: 12,
                      color: colors.foreground.withValues(alpha: 0.85),
                    ),
          ),
        ],
      ),
      backgroundColor: colors.background,
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
  final statusCode = code != null ? code ~/ 1000 : 500;
  final colors = snackBarColorsForStatus(
    statusCode,
    theme.colorScheme.error,
    theme.colorScheme.onError,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: code != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayMessage,
                  style:
                      theme.snackBarTheme.contentTextStyle ??
                      theme.textTheme.bodyMedium?.copyWith(
                        color: colors.foreground,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Código: $code',
                  style:
                      (theme.snackBarTheme.contentTextStyle ??
                              theme.textTheme.bodyMedium)
                          ?.copyWith(
                            fontSize: 12,
                            color: colors.foreground.withValues(alpha: 0.85),
                          ),
                ),
              ],
            )
          : Text(
              displayMessage,
              style:
                  theme.snackBarTheme.contentTextStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    color: colors.foreground,
                  ),
            ),
      backgroundColor: colors.background,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
