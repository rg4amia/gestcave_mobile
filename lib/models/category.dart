import 'product.dart';

class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int? totalProducts;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.totalProducts,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      totalProducts: json['products_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
    };
  }
}
