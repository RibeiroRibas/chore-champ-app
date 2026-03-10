import '../models/chore.dart';

/// Repositório de tarefas (mock). Substituir por chamadas HTTP quando a API existir.
class ChoreRepository {
  ChoreRepository() : _chores = List.from(_initialChores);

  static final List<Chore> _initialChores = [
    const Chore(id: 'c1', title: 'Lavar a louça', emoji: '🍽️', points: 10, assignedTo: '3', createdBy: '1', completed: false, category: 'Cozinha'),
    const Chore(id: 'c2', title: 'Aspirar a sala', emoji: '🧹', points: 15, assignedTo: '4', createdBy: '1', completed: false, category: 'Sala'),
    const Chore(id: 'c3', title: 'Tirar o lixo', emoji: '🗑️', points: 5, assignedTo: null, createdBy: '2', completed: false, category: 'Geral'),
    const Chore(id: 'c4', title: 'Lavar roupa', emoji: '👕', points: 20, assignedTo: '3', createdBy: '1', completed: true, category: 'Roupa'),
    const Chore(id: 'c5', title: 'Passear com o cachorro', emoji: '🐕', points: 15, assignedTo: '4', createdBy: '2', completed: true, category: 'Animais'),
    const Chore(id: 'c6', title: 'Regar as plantas', emoji: '🌱', points: 5, assignedTo: null, createdBy: '1', completed: false, category: 'Jardim'),
    const Chore(id: 'c7', title: 'Limpar o banheiro', emoji: '🛁', points: 25, assignedTo: '3', createdBy: '1', completed: false, category: 'Banheiro'),
    const Chore(id: 'c8', title: 'Organizar a garagem', emoji: '🔧', points: 30, assignedTo: null, createdBy: '2', completed: false, category: 'Garagem'),
  ];

  final List<Chore> _chores;

  Future<List<Chore>> fetchChores() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_chores);
  }

  Future<Chore> addChore(Chore chore) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final id = 'c${DateTime.now().millisecondsSinceEpoch}';
    final created = chore.copyWith(id: id);
    _chores.add(created);
    return created;
  }

  Future<void> updateChore(Chore chore) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final i = _chores.indexWhere((c) => c.id == chore.id);
    if (i >= 0) _chores[i] = chore;
  }

  Future<void> deleteChore(String choreId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _chores.removeWhere((c) => c.id == choreId);
  }

  List<Chore> get chores => _chores;
}
