import 'package:flutter/material.dart';

import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';

/// Diálogo genérico informativo (um botão de fechar). Útil para mensagens de sucesso ou avisos.
class InfoAlertDialog extends StatelessWidget {
  const InfoAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.confirmLabel,
  });

  final String title;
  final String message;
  final IconData? icon;

  /// Texto do botão principal (ex.: "Entendi", "OK").
  final String? confirmLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = confirmLabel ?? AppStrings.dialogGotIt;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedForeground,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Abre [InfoAlertDialog] por cima da rota atual.
Future<void> showInfoAlertDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData? icon,
  String? confirmLabel,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => InfoAlertDialog(
      title: title,
      message: message,
      icon: icon,
      confirmLabel: confirmLabel,
    ),
  );
}
