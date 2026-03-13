import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/chore.dart';
import '../../widgets/card_playful.dart';

class ChorePreviewCardComponent extends StatelessWidget {
  const ChorePreviewCardComponent({
    super.key,
    required this.chore,
  });

  final Chore chore;

  @override
  Widget build(BuildContext context) {
    return CardPlayful(
      child: Row(
        children: [
          Text(chore.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chore.title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
          Text(
            '+${chore.points} pts',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
