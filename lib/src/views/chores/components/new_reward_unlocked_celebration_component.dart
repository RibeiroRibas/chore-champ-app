import 'dart:math' as math;

import 'package:chore_champ_app/src/constants/app_colors.dart';
import 'package:chore_champ_app/src/constants/app_strings.dart';
import 'package:flutter/material.dart';

class NewRewardUnlockedCelebrationComponent extends StatefulWidget {
  const NewRewardUnlockedCelebrationComponent({
    super.key,
    required this.onClose,
    required this.onViewRewards,
  });

  final VoidCallback onClose;
  final VoidCallback onViewRewards;

  @override
  State<NewRewardUnlockedCelebrationComponent> createState() =>
      _NewRewardUnlockedCelebrationComponentState();
}

class _NewRewardUnlockedCelebrationComponentState
    extends State<NewRewardUnlockedCelebrationComponent>
    with TickerProviderStateMixin {
  late final AnimationController _orbit;
  late final AnimationController _popIn;
  late final Animation<double> _scale;

  static const _orbitEmojis = ['✨', '⭐', '✨', '💫', '✨'];

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
    _popIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(
      parent: _popIn,
      curve: Curves.elasticOut,
    );
    _popIn.forward();
  }

  @override
  void dispose() {
    _orbit.dispose();
    _popIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: AnimatedBuilder(
                      animation: _orbit,
                      builder: (context, _) {
                        final t = _orbit.value * 2 * math.pi;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            for (var i = 0; i < _orbitEmojis.length; i++)
                              _OrbitingEmoji(
                                emoji: _orbitEmojis[i],
                                angle: t + (i * 2 * math.pi / _orbitEmojis.length),
                                radius: 52,
                              ),
                            const Text('🎁', style: TextStyle(fontSize: 56)),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.newRewardUnlockedTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.newRewardUnlockedMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.onViewRewards,
                      child: Text(AppStrings.viewRewardsButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitingEmoji extends StatelessWidget {
  const _OrbitingEmoji({
    required this.emoji,
    required this.angle,
    required this.radius,
  });

  final String emoji;
  final double angle;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final x = math.cos(angle) * radius;
    final y = math.sin(angle) * radius;
    return Transform.translate(
      offset: Offset(x, y),
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }
}
