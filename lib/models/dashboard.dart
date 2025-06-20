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
    print('json dashboard : $json');
    return DashboardData(
      lowStockProducts: (json['lowStockProducts'] as List)
          .map((p) => Product.fromJson(p))
          .toList(),
      totalProducts: json['totalProducts'],
      totalValue: json['totalValue'] != null
          ? double.parse(json['totalValue'].toString())
          : 0.0,
      recentTransactions: (json['recentTransactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      transactionStats: TransactionStats.fromJson(json['transactionStats']),
      financialStats: FinancialStats.fromJson(json['financialStats']),
      topProducts: (json['topProducts'] as List)
          .map((p) => TopProduct.fromJson(p))
          .toList(),
      stockByCategory: (json['stockByCategory'] as List)
          .map((c) => CategoryStock.fromJson(c))
          .toList(),
      valueByCategory: (json['valueByCategory'] as List)
          .map((c) => CategoryValue.fromJson(c))
          .toList(),
      stockAlerts: StockAlerts.fromJson(json['stockAlerts']),
    );
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
      total: json['total'],
      in_: json['in'],
      out: json['out'],
      today: json['today'],
      thisWeek: json['this_week'],
      thisMonth: json['this_month'],
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
      totalPurchases: double.parse(json['total_purchases'].toString()),
      totalSales: double.parse(json['total_sales'].toString()),
      totalProfit: json['total_profit'] != null
          ? double.parse(json['total_profit'].toString())
          : 0.0,
      monthlySales: double.parse(json['monthly_sales'].toString()),
      monthlyProfit: json['monthly_profit'] != null
          ? double.parse(json['monthly_profit'].toString())
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
      productId: json['product_id'],
      totalQuantity: int.parse(json['total_quantity'].toString()),
      totalSales: json['total_sales'] != null
          ? double.parse(json['total_sales'].toString())
          : null,
      totalProfit: json['total_profit'] != null
          ? double.parse(json['total_profit'].toString())
          : null,
      product: Product.fromJson(json['product']),
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
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      productsCount: json['products_count'] != null
          ? int.parse(json['products_count'].toString())
          : null,
      productsStockQuantity: json['products_sum_stock_quantity'] != null
          ? int.parse(json['products_sum_stock_quantity'].toString())
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
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      productsSumPrice: json['products_sum_price'] != null
          ? double.parse(json['products_sum_price'].toString())
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
      total: json['total'],
      critical: json['critical'],
      warning: json['warning'],
    );
  }
}
