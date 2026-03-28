import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:chore_champ_app/src/views/components/card_playful.dart';
import 'package:flutter/material.dart';

class EmptyChoresCardComponent extends StatelessWidget {
  const EmptyChoresCardComponent({
    super.key,
    this.title = AppStrings.allCaughtUp,
    this.subtitle,
    this.showActionButton = true,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? subtitle;
  final bool showActionButton;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return CardPlayful(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.points.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🎉', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle ??
                  'Aproveite para organizar a proxima tarefa e manter o ritmo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: const [
                _HintChip(icon: Icons.bolt_rounded, label: 'Continue assim'),
                _HintChip(icon: Icons.stars_rounded, label: 'Ganhe pontos'),
                _HintChip(icon: Icons.task_alt_rounded, label: 'Dia produtivo'),
              ],
            ),
            if (showActionButton &&
                actionLabel != null &&
                onActionPressed != null) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add_task_rounded),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
