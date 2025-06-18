import '../models/category.dart';

class PaginatedCategoryResponse {
  final List<Category> categories;
  final int total;
  final int currentPage;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;
  final int perPage;
  final int from;
  final int to;

  PaginatedCategoryResponse({
    required this.categories,
    required this.total,
    required this.currentPage,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
    required this.perPage,
    required this.from,
    required this.to,
  });

  factory PaginatedCategoryResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedCategoryResponse(
      categories: (json['data'] as List)
          .map((c) => Category.fromJson(c))
          .toList(),
      total: json['total'] as int,
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
      perPage: json['per_page'] as int,
      from: json['from'] as int,
      to: json['to'] as int,
    );
  }
}
