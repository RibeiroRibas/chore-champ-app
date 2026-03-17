import 'package:chore_champ_app/src/models/chore.dart';

class PaginatedChoresResponse {
  const PaginatedChoresResponse({
    required this.items,
    required this.totalItems,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<Chore> items;
  final int totalItems;
  final int page;
  final int pageSize;
  final int totalPages;

  factory PaginatedChoresResponse.fromApiJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    return PaginatedChoresResponse(
      items: itemsJson
          .map((e) => Chore.fromApiJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['total_items'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
    );
  }
}
