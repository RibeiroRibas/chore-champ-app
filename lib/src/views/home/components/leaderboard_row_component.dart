import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/models/ranking_member.dart';
import 'package:chore_champ_app/src/views/components/card_playful.dart';
import 'package:flutter/material.dart';

class LeaderboardRowComponent extends StatelessWidget {
  const LeaderboardRowComponent({
    super.key,
    required this.member,
    required this.rankDisplay,
  });

  final RankingMember member;
  final String rankDisplay;

  @override
  Widget build(BuildContext context) {
    return CardPlayful(
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Center(
              child: Text(
                rankDisplay,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(member.avatar, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  member.roleName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${member.points} pts',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
