import 'package:hive/hive.dart';
import 'product.dart';
import 'user.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class Transaction extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int productId;

  @HiveField(2)
  final int userId;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final double unitPrice;

  @HiveField(6)
  final double totalPrice;

  @HiveField(7)
  final double purchasePrice;

  @HiveField(8)
  final double salePrice;

  @HiveField(9)
  final String? notes;

  @HiveField(10)
  final Product? product;

  final User? user;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.productId,
    required this.userId,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.purchasePrice,
    required this.salePrice,
    this.notes,
    this.product,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  double get profit {
    if (type == 'out') {
      return (salePrice - purchasePrice) * quantity;
    }
    return 0;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price'] != null
          ? (json['unit_price'] is String
                ? double.tryParse(json['unit_price']) ?? 0.0
                : (json['unit_price'] as num).toDouble())
          : 0.0,
      totalPrice: json['total_price'] != null
          ? (json['total_price'] is String
                ? double.tryParse(json['total_price']) ?? 0.0
                : (json['total_price'] as num).toDouble())
          : 0.0,
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
      notes: json['notes']?.toString(),
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'type': type,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
