import 'package:flutter/material.dart';

import 'package:chore_champ_app/src/constants/app_colors.dart';

/// Exibe um snackbar de sucesso genérico, reutilizável.
/// Contém mensagem, ícone (ou emoji) e ícone de fechar.
/// Fecha automaticamente após [duration] (padrão 3 segundos).
void showSuccessSnackBar(
  BuildContext context, {
  required String message,
  Widget? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  final theme = Theme.of(context);
  final leading =
      icon ?? Icon(Icons.check_circle, color: AppColors.success, size: 22);

  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style:
                  theme.snackBarTheme.contentTextStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.foreground,
                  ),
            ),
          ),
          IconButton(
            onPressed: () => messenger.hideCurrentSnackBar(),
            icon: const Icon(
              Icons.close,
              size: 20,
              color: AppColors.mutedForeground,
            ),
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.card,
      behavior: SnackBarBehavior.floating,
      duration: duration,
    ),
  );
}
