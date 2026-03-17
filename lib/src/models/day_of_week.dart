class DayOfWeek {
  const DayOfWeek({required this.id, required this.name});

  final int id;
  final String name;

  factory DayOfWeek.fromApiJson(Map<String, dynamic> json) {
    return DayOfWeek(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );
  }
}
