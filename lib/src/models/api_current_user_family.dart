class ApiCurrentUserFamily {
  const ApiCurrentUserFamily({required this.id, required this.name});

  final int id;
  final String name;

  factory ApiCurrentUserFamily.fromJson(Map<String, dynamic> json) {
    return ApiCurrentUserFamily(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}