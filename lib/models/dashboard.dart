import '../models/product.dart';
import '../models/transaction.dart';

class DashboardData {
  final List<Product> lowStockProducts;
  final int totalProducts;
  final double totalValue;
  final List<Transaction> recentTransactions;
  final TransactionStats transactionStats;
  final FinancialStats financialStats;
  final List<TopProduct> topProducts;
  final List<CategoryStock> stockByCategory;
  final List<CategoryValue> valueByCategory;
  final StockAlerts stockAlerts;

  DashboardData({
    required this.lowStockProducts,
    required this.totalProducts,
    required this.totalValue,
    required this.recentTransactions,
    required this.transactionStats,
    required this.financialStats,
    required this.topProducts,
    required this.stockByCategory,
    required this.valueByCategory,
    required this.stockAlerts,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    //print('json dashboard : $json');
    return DashboardData(
      lowStockProducts: (json['lowStockProducts'] as List? ?? [])
          .map((p) => Product.fromJson(p))
          .toList(),
      totalProducts: json['totalProducts'] ?? 0,
      totalValue: json['totalValue'] != null
          ? (json['totalValue'] is String
                ? double.tryParse(json['totalValue']) ?? 0.0
                : (json['totalValue'] as num).toDouble())
          : 0.0,
      recentTransactions: (json['recentTransactions'] as List? ?? [])
          .map((t) => Transaction.fromJson(t))
          .toList(),
      transactionStats: TransactionStats.fromJson(
        json['transactionStats'] ?? {},
      ),
      financialStats: FinancialStats.fromJson(json['financialStats'] ?? {}),
      topProducts: (json['topProducts'] as List? ?? [])
          .map((p) => TopProduct.fromJson(p))
          .toList(),
      stockByCategory: (json['stockByCategory'] as List? ?? [])
          .map((c) => CategoryStock.fromJson(c))
          .toList(),
      valueByCategory: (json['valueByCategory'] as List? ?? [])
          .map((c) => CategoryValue.fromJson(c))
          .toList(),
      stockAlerts: StockAlerts.fromJson(json['stockAlerts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lowStockProducts': lowStockProducts.map((p) => p.toJson()).toList(),
      'totalProducts': totalProducts,
      'totalValue': totalValue,
      'recentTransactions': recentTransactions.map((t) => t.toJson()).toList(),
      'transactionStats': {
        'total': transactionStats.total,
        'in': transactionStats.in_,
        'out': transactionStats.out,
        'today': transactionStats.today,
        'this_week': transactionStats.thisWeek,
        'this_month': transactionStats.thisMonth,
      },
      'financialStats': {
        'total_purchases': financialStats.totalPurchases,
        'total_sales': financialStats.totalSales,
        'total_profit': financialStats.totalProfit,
        'monthly_sales': financialStats.monthlySales,
        'monthly_profit': financialStats.monthlyProfit,
      },
      'topProducts': topProducts
          .map(
            (p) => {
              'product_id': p.productId,
              'total_quantity': p.totalQuantity,
              'total_sales': p.totalSales,
              'total_profit': p.totalProfit,
              'product': p.product.toJson(),
            },
          )
          .toList(),
      'stockByCategory': stockByCategory
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'slug': c.slug,
              'description': c.description,
              'created_at': c.createdAt.toIso8601String(),
              'updated_at': c.updatedAt.toIso8601String(),
              'products_count': c.productsCount,
              'products_sum_stock_quantity': c.productsStockQuantity,
            },
          )
          .toList(),
      'valueByCategory': valueByCategory
          .map(
            (c) => {
              'id': c.id,
              'name': c.name,
              'slug': c.slug,
              'description': c.description,
              'created_at': c.createdAt.toIso8601String(),
              'updated_at': c.updatedAt.toIso8601String(),
              'products_sum_price': c.productsSumPrice,
            },
          )
          .toList(),
      'stockAlerts': {
        'total': stockAlerts.total,
        'critical': stockAlerts.critical,
        'warning': stockAlerts.warning,
      },
    };
  }
}

class TransactionStats {
  final int total;
  final int in_;
  final int out;
  final int today;
  final int thisWeek;
  final int thisMonth;

  TransactionStats({
    required this.total,
    required this.in_,
    required this.out,
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
  });

  factory TransactionStats.fromJson(Map<String, dynamic> json) {
    return TransactionStats(
      total: json['total'] ?? 0,
      in_: json['in'] ?? 0,
      out: json['out'] ?? 0,
      today: json['today'] ?? 0,
      thisWeek: json['this_week'] ?? 0,
      thisMonth: json['this_month'] ?? 0,
    );
  }
}

class FinancialStats {
  final double totalPurchases;
  final double totalSales;
  final double totalProfit;
  final double monthlySales;
  final double monthlyProfit;

  FinancialStats({
    required this.totalPurchases,
    required this.totalSales,
    required this.totalProfit,
    required this.monthlySales,
    required this.monthlyProfit,
  });

  factory FinancialStats.fromJson(Map<String, dynamic> json) {
    return FinancialStats(
      totalPurchases: json['total_purchases'] != null
          ? (json['total_purchases'] is String
                ? double.tryParse(json['total_purchases']) ?? 0.0
                : (json['total_purchases'] as num).toDouble())
          : 0.0,
      totalSales: json['total_sales'] != null
          ? (json['total_sales'] is String
                ? double.tryParse(json['total_sales']) ?? 0.0
                : (json['total_sales'] as num).toDouble())
          : 0.0,
      totalProfit: json['total_profit'] != null
          ? (json['total_profit'] is String
                ? double.tryParse(json['total_profit']) ?? 0.0
                : (json['total_profit'] as num).toDouble())
          : 0.0,
      monthlySales: json['monthly_sales'] != null
          ? (json['monthly_sales'] is String
                ? double.tryParse(json['monthly_sales']) ?? 0.0
                : (json['monthly_sales'] as num).toDouble())
          : 0.0,
      monthlyProfit: json['monthly_profit'] != null
          ? (json['monthly_profit'] is String
                ? double.tryParse(json['monthly_profit']) ?? 0.0
                : (json['monthly_profit'] as num).toDouble())
          : 0.0,
    );
  }
}

class TopProduct {
  final int productId;
  final int totalQuantity;
  final double? totalSales;
  final double? totalProfit;
  final Product product;

  TopProduct({
    required this.productId,
    required this.totalQuantity,
    this.totalSales,
    this.totalProfit,
    required this.product,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['product_id'] ?? 0,
      totalQuantity: json['total_quantity'] != null
          ? (json['total_quantity'] is String
                ? int.tryParse(json['total_quantity']) ?? 0
                : json['total_quantity'] as int)
          : 0,
      totalSales: json['total_sales'] != null
          ? (json['total_sales'] is String
                ? double.tryParse(json['total_sales'])
                : json['total_sales'] as double?)
          : null,
      totalProfit: json['total_profit'] != null
          ? (json['total_profit'] is String
                ? double.tryParse(json['total_profit'])
                : json['total_profit'] as double?)
          : null,
      product: Product.fromJson(json['product'] ?? {}),
    );
  }
}

class CategoryStock {
  final int id;
  final String name;
  final String slug;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? productsCount;
  final int? productsStockQuantity;

  CategoryStock({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.productsCount,
    this.productsStockQuantity,
  });

  factory CategoryStock.fromJson(Map<String, dynamic> json) {
    return CategoryStock(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      productsCount: json['products_count'] != null
          ? (json['products_count'] is String
                ? int.tryParse(json['products_count'])
                : json['products_count'] as int?)
          : null,
      productsStockQuantity: json['products_sum_stock_quantity'] != null
          ? (json['products_sum_stock_quantity'] is String
                ? int.tryParse(json['products_sum_stock_quantity'])
                : json['products_sum_stock_quantity'] as int?)
          : null,
    );
  }
}

class CategoryValue {
  final int id;
  final String name;
  final String slug;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? productsSumPrice;

  CategoryValue({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.productsSumPrice,
  });

  factory CategoryValue.fromJson(Map<String, dynamic> json) {
    return CategoryValue(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      productsSumPrice: json['products_sum_price'] != null
          ? (json['products_sum_price'] is String
                ? double.tryParse(json['products_sum_price'])
                : json['products_sum_price'] as double?)
          : null,
    );
  }
}

class StockAlerts {
  final int total;
  final int critical;
  final int warning;

  StockAlerts({
    required this.total,
    required this.critical,
    required this.warning,
  });

  factory StockAlerts.fromJson(Map<String, dynamic> json) {
    return StockAlerts(
      total: json['total'] ?? 0,
      critical: json['critical'] ?? 0,
      warning: json['warning'] ?? 0,
    );
  }
}
