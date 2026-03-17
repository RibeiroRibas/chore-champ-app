import 'package:flutter/material.dart';

import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';

/// Diálogo genérico de confirmação de ação (ex.: excluir, remover atribuição, concluir).
/// Permite customizar título, descrição e o texto do botão de confirmação.
class ConfirmActionDialog extends StatelessWidget {
  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.onCancel,
    required this.onConfirm,
    this.description,
    this.confirmLabel,
    this.confirmButtonDestructive = true,
  });

  final String title;
  final String? description;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  /// Texto do botão de confirmação (ex.: "Excluir", "Remover atribuição", "Concluir").
  final String? confirmLabel;

  /// Se true, o botão de confirmação usa cor destrutiva (vermelho). Se false, usa primary.
  final bool confirmButtonDestructive;

  @override
  Widget build(BuildContext context) {
    final label = confirmLabel ?? AppStrings.delete;
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: const Text(AppStrings.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmButtonDestructive
                          ? AppColors.destructive
                          : AppColors.primary,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
