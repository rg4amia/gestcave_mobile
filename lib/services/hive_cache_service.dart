import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/dashboard.dart';

class HiveCacheService extends GetxService {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final SharedPreferences _prefs;

  // Boxes Hive
  late Box<Product> _productsBox;
  late Box<Transaction> _transactionsBox;
  late Box<Category> _categoriesBox;
  late Box<Map> _dashboardBox;

  // Timestamps pour la gestion du cache
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _cacheExpiryKey = 'cache_expiry_hours';
  static const int _defaultCacheExpiryHours = 24;

  HiveCacheService(this._prefs);

  @override
  void onInit() async {
    super.onInit();
    await _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();

    // Enregistrer les adaptateurs
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionAdapter());
    }

    // Ouvrir les boxes
    _productsBox = await Hive.openBox<Product>('products');
    _transactionsBox = await Hive.openBox<Transaction>('transactions');
    _categoriesBox = await Hive.openBox<Category>('categories');
    _dashboardBox = await Hive.openBox<Map>('dashboard');
  }

  // Gestion des timestamps
  DateTime? get lastSyncTime {
    final timestamp = _prefs.getInt(_lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> updateLastSyncTime() async {
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  int get cacheExpiryHours =>
      _prefs.getInt(_cacheExpiryKey) ?? _defaultCacheExpiryHours;

  Future<void> setCacheExpiryHours(int hours) async {
    await _prefs.setInt(_cacheExpiryKey, hours);
  }

  bool get isCacheValid {
    final lastSync = lastSyncTime;
    if (lastSync == null) return false;

    final expiryTime = lastSync.add(Duration(hours: cacheExpiryHours));
    return DateTime.now().isBefore(expiryTime);
  }

  bool get shouldUseCache {
    return !_connectivityService.isConnected || isCacheValid;
  }

  // Gestion du cache des produits
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && shouldUseCache) {
      return _productsBox.values.toList();
    }

    if (!_connectivityService.isConnected && !isCacheValid) {
      return _productsBox.values.toList();
    }

    return [];
  }

  Future<void> cacheProducts(List<Product> products) async {
    await _productsBox.clear();
    await _productsBox.addAll(products);
    await updateLastSyncTime();
  }

  Future<void> addProduct(Product product) async {
    await _productsBox.put(product.id, product);
    await updateLastSyncTime();
  }

  Future<void> updateProduct(Product product) async {
    await _productsBox.put(product.id, product);
    await updateLastSyncTime();
  }

  Future<void> removeProduct(int productId) async {
    await _productsBox.delete(productId);
    await updateLastSyncTime();
  }

  // Gestion du cache des transactions
  Future<List<Transaction>> getTransactions({bool forceRefresh = false}) async {
    if (!forceRefresh && shouldUseCache) {
      return _transactionsBox.values.toList();
    }

    if (!_connectivityService.isConnected && !isCacheValid) {
      return _transactionsBox.values.toList();
    }

    return [];
  }

  Future<void> cacheTransactions(List<Transaction> transactions) async {
    await _transactionsBox.clear();
    await _transactionsBox.addAll(transactions);
    await updateLastSyncTime();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
    await updateLastSyncTime();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
    await updateLastSyncTime();
  }

  Future<void> removeTransaction(int transactionId) async {
    await _transactionsBox.delete(transactionId);
    await updateLastSyncTime();
  }

  // Gestion du cache des catégories
  Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && shouldUseCache) {
      return _categoriesBox.values.toList();
    }

    if (!_connectivityService.isConnected && !isCacheValid) {
      return _categoriesBox.values.toList();
    }

    return [];
  }

  Future<void> cacheCategories(List<Category> categories) async {
    await _categoriesBox.clear();
    await _categoriesBox.addAll(categories);
    await updateLastSyncTime();
  }

  Future<void> addCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
    await updateLastSyncTime();
  }

  Future<void> updateCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
    await updateLastSyncTime();
  }

  Future<void> removeCategory(int categoryId) async {
    await _categoriesBox.delete(categoryId);
    await updateLastSyncTime();
  }

  // Gestion du cache du dashboard
  Future<DashboardData?> getDashboard({bool forceRefresh = false}) async {
    if (!forceRefresh && shouldUseCache) {
      final cachedData = _dashboardBox.get('dashboard_data');
      if (cachedData != null) {
        try {
          return DashboardData.fromJson(Map<String, dynamic>.from(cachedData));
        } catch (e) {
          print('Erreur lors du décodage du dashboard en cache: $e');
        }
      }
    }

    if (!_connectivityService.isConnected && !isCacheValid) {
      final cachedData = _dashboardBox.get('dashboard_data');
      if (cachedData != null) {
        try {
          return DashboardData.fromJson(Map<String, dynamic>.from(cachedData));
        } catch (e) {
          print('Erreur lors du décodage du dashboard en cache: $e');
        }
      }
    }

    return null;
  }

  Future<void> cacheDashboard(DashboardData dashboard) async {
    await _dashboardBox.put('dashboard_data', dashboard.toJson());
    await updateLastSyncTime();
  }

  // Gestion des statistiques de cache
  Future<Map<String, dynamic>> getCacheStats() async {
    return {
      'products_count': _productsBox.length,
      'transactions_count': _transactionsBox.length,
      'categories_count': _categoriesBox.length,
      'last_sync': lastSyncTime?.toIso8601String(),
      'cache_valid': isCacheValid,
      'is_connected': _connectivityService.isConnected,
      'should_use_cache': shouldUseCache,
      'hive_boxes_count': 4, // Nombre fixe de boxes utilisées
    };
  }

  // Nettoyage du cache
  Future<void> clearCache() async {
    await _productsBox.clear();
    await _transactionsBox.clear();
    await _categoriesBox.clear();
    await _dashboardBox.clear();
    await _prefs.remove(_lastSyncKey);
  }

  // Vérification de l'espace disque utilisé par le cache
  Future<int> getCacheSize() async {
    int totalSize = 0;

    // Calculer la taille approximative des données
    for (var product in _productsBox.values) {
      totalSize += product.toJson().toString().length;
    }

    for (var transaction in _transactionsBox.values) {
      totalSize += transaction.toJson().toString().length;
    }

    for (var category in _categoriesBox.values) {
      totalSize += category.toJson().toString().length;
    }

    return totalSize;
  }

  // Optimisation du cache
  Future<void> optimizeCache() async {
    // Hive gère automatiquement l'optimisation
    await _productsBox.compact();
    await _transactionsBox.compact();
    await _categoriesBox.compact();
    await _dashboardBox.compact();

    print('Cache Hive optimisé');
  }

  @override
  void onClose() {
    _productsBox.close();
    _transactionsBox.close();
    _categoriesBox.close();
    _dashboardBox.close();
    super.onClose();
  }
}
