import 'dart:math' as math;

import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:flutter/material.dart';

class RewardClaimCelebrationComponent extends StatefulWidget {
  const RewardClaimCelebrationComponent({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  State<RewardClaimCelebrationComponent> createState() =>
      _RewardClaimCelebrationComponentState();
}

class _RewardClaimCelebrationComponentState
    extends State<RewardClaimCelebrationComponent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _partyIcons = ['🎉', '🥳', '🎊', '✨', '🎉', '🥳'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Material(
        color: Colors.black45,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                width: 280,
                height: 220,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final progress = _controller.value;
                    return Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                        for (int i = 0; i < _partyIcons.length; i++)
                          _FloatingPartyIcon(
                            emoji: _partyIcons[i],
                            index: i,
                            progress: progress,
                          ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🎉', style: TextStyle(fontSize: 44)),
                              const SizedBox(height: 10),
                              Text(
                                AppStrings.rewardCelebrationTitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.rewardCelebrationMessage,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingPartyIcon extends StatelessWidget {
  const _FloatingPartyIcon({
    required this.emoji,
    required this.index,
    required this.progress,
  });

  final String emoji;
  final int index;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final baseX = 24.0 + (index * 42.0);
    final wave = math.sin((progress * 2 * math.pi) + index) * 10;
    final rise = (1 - progress) * 70;
    final x = (baseX + wave).clamp(8.0, 248.0);
    final y = 18.0 + rise;
    final opacity = (0.25 + (1 - progress) * 0.75).clamp(0.0, 1.0);

    return Positioned(
      left: x,
      top: y,
      child: Opacity(
        opacity: opacity,
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
