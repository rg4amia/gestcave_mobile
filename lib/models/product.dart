import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'category.dart';
import 'transaction.dart';

class Product {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final int stockQuantity;
  final int minimumStock;
  final String? barcode;
  final String? imagePath;
  final double purchasePrice;
  final double salePrice;
  final Category? category;
  final List<Transaction>? transactions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.stockQuantity,
    required this.minimumStock,
    this.barcode,
    this.imagePath,
    required this.purchasePrice,
    required this.salePrice,
    this.category,
    this.transactions,
    this.createdAt,
    this.updatedAt,
  });

  bool get isLowStock => stockQuantity <= minimumStock;

  factory Product.fromJson(Map<String, dynamic> json) {
    final String baseStorageUrl = dotenv.env['BASE_STORAGE_URL'] ?? 'http://10.0.2.2:8000/storage/';
    String? imagePath = json['image_path'];
    if (imagePath != null && !imagePath.startsWith('http')) {
      imagePath = baseStorageUrl + imagePath;
    }

    return Product(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      stockQuantity: json['stock_quantity'],
      minimumStock: json['minimum_stock'],
      barcode: json['barcode'],
      imagePath: imagePath,
      purchasePrice: double.parse(json['purchase_price'].toString()),
      salePrice: double.parse(json['sale_price'].toString()),
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
                .map((t) => Transaction.fromJson(t))
                .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'minimum_stock': minimumStock,
      'barcode': barcode,
      'image_path': imagePath,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
