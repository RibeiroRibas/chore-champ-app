import 'package:chore_champ_app/src/models/achievement.dart';

/// Repositório de conquistas (mock). Substituir por chamadas HTTP quando a API existir.
class AchievementRepository {
  Future<List<Achievement>> fetchAchievements() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_initialAchievements);
  }

  static const List<Achievement> _initialAchievements = [
    Achievement(
      id: 'a1',
      title: 'Primeiros passos',
      description: 'Conclua sua primeira tarefa',
      emoji: '⭐',
      requiredPoints: 5,
      unlockedBy: ['1', '2', '3', '4'],
    ),
    Achievement(
      id: 'a2',
      title: 'Mão amiga',
      description: 'Conquiste 50 pontos',
      emoji: '🤝',
      requiredPoints: 50,
      unlockedBy: ['1', '2', '3', '4'],
    ),
    Achievement(
      id: 'a3',
      title: 'Super ajudante',
      description: 'Conquiste 150 pontos',
      emoji: '🦸',
      requiredPoints: 150,
      unlockedBy: ['1', '2', '3'],
    ),
    Achievement(
      id: 'a4',
      title: 'Herói da casa',
      description: 'Conquiste 300 pontos',
      emoji: '🏆',
      requiredPoints: 300,
      unlockedBy: ['1'],
    ),
    Achievement(
      id: 'a5',
      title: 'Lenda',
      description: 'Conquiste 500 pontos',
      emoji: '👑',
      requiredPoints: 500,
      unlockedBy: [],
    ),
  ];
}
