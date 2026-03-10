import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../widgets/card_playful.dart';

class AddChoreFormComponent extends StatelessWidget {
  const AddChoreFormComponent({
    super.key,
    required this.emojiController,
    required this.titleController,
    required this.pointsController,
    required this.categoryController,
    required this.onSubmit,
  });

  final TextEditingController emojiController;
  final TextEditingController titleController;
  final TextEditingController pointsController;
  final TextEditingController categoryController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return CardPlayful(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 48,
                child: TextField(
                  controller: emojiController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                  maxLength: 2,
                  decoration: const InputDecoration(counterText: ''),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: AppStrings.choreName),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 72,
                child: TextField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(hintText: AppStrings.category),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(AppStrings.addChore),
            ),
          ),
        ],
      ),
    );
  }
}
