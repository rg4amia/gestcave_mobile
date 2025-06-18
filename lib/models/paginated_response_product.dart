import '../models/product.dart';
class PaginatedResponse {
  final List<Product> products;
  final int total;
  final int currentPage;
  final int lastPage;

  PaginatedResponse({
    required this.products,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse(
      products: (json['data'] as List).map((p) => Product.fromJson(p)).toList(),
      total: json['total'] as int,
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
    );
  }
}
