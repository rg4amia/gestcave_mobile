import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'category.dart';
import 'transaction.dart';
import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int categoryId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String slug;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final double price;

  @HiveField(6)
  final int stockQuantity;

  @HiveField(7)
  final int minimumStock;

  @HiveField(8)
  final String? barcode;

  @HiveField(9)
  final String? imagePath;

  @HiveField(10)
  final double purchasePrice;

  @HiveField(11)
  final double salePrice;

  @HiveField(12)
  final Category? category;

  @HiveField(13)
  final List<Transaction>? transactions;

  @HiveField(14)
  final DateTime? createdAt;

  @HiveField(15)
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
    final String baseStorageUrl =
        dotenv.env['BASE_STORAGE_URL'] ?? 'http://10.0.2.2:8000/storage/';
    String? imagePath = json['image_path']?.toString();
    if (imagePath != null && !imagePath.startsWith('http')) {
      imagePath = '$baseStorageUrl/$imagePath';
    }

    return Product(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      price: json['price'] != null
          ? (json['price'] is String
                ? double.tryParse(json['price']) ?? 0.0
                : (json['price'] as num).toDouble())
          : 0.0,
      stockQuantity: json['stock_quantity'] ?? 0,
      minimumStock: json['minimum_stock'] ?? 0,
      barcode: json['barcode']?.toString(),
      imagePath: imagePath,
      purchasePrice: json['purchase_price'] != null
          ? (json['purchase_price'] is String
                ? double.tryParse(json['purchase_price']) ?? 0.0
                : (json['purchase_price'] as num).toDouble())
          : 0.0,
      salePrice: json['sale_price'] != null
          ? (json['sale_price'] is String
                ? double.tryParse(json['sale_price']) ?? 0.0
                : (json['sale_price'] as num).toDouble())
          : 0.0,
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
