import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';

class AdminRequiredMessageComponent extends StatelessWidget {
  const AdminRequiredMessageComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔒', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              AppStrings.adminAccessRequired,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}
