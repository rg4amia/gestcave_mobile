import 'product.dart';
import 'user.dart';

class Transaction {
  final int id;
  final int productId;
  final int userId;
  final String type;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double purchasePrice;
  final double salePrice;
  final String? notes;
  final Product? product;
  final User? user;
  final DateTime createdAt;

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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get profit {
    if (type == 'out') {
      return (salePrice - purchasePrice) * quantity;
    }
    return 0;
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      productId: json['product_id'],
      userId: json['user_id'],
      type: json['type'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      purchasePrice: json['purchase_price'] != null
          ? double.parse(json['purchase_price'].toString())
          : 0.0,
      salePrice: json['sale_price'] != null
          ? double.parse(json['sale_price'].toString())
          : 0.0,
      notes: json['notes'],
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
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
    };
  }
}
