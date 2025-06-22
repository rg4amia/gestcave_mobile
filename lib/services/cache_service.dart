import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'connectivity_service.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/dashboard.dart';

class CacheService extends GetxService {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  final SharedPreferences _prefs;

  // Cache en mémoire pour les performances
  final Map<String, dynamic> _memoryCache = {};

  // Timestamps pour la gestion du cache
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _cacheExpiryKey = 'cache_expiry_hours';
  static const int _defaultCacheExpiryHours = 24;

  CacheService(this._prefs);

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

  // Méthodes génériques pour le cache
  Future<T?> _getFromCache<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // Vérifier d'abord le cache mémoire
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] as T;
    }

    // Vérifier le cache persistant
    final cachedData = _prefs.getString(key);
    if (cachedData != null) {
      try {
        final data = jsonDecode(cachedData);
        final result = fromJson(data);
        _memoryCache[key] = result; // Mettre en cache mémoire
        return result;
      } catch (e) {
        print('Erreur lors du décodage du cache pour $key: $e');
        await _prefs.remove(key);
      }
    }
    return null;
  }

  Future<void> _saveToCache<T>(String key, T data) async {
    try {
      final jsonData = jsonEncode(data);
      await _prefs.setString(key, jsonData);
      _memoryCache[key] = data; // Mettre en cache mémoire
    } catch (e) {
      print('Erreur lors de la sauvegarde en cache pour $key: $e');
    }
  }

  // Gestion du cache des produits
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && shouldUseCache) {
      final cached = await _getFromCache<List<Product>>(
        'cached_products',
        (data) =>
            (data['products'] as List).map((p) => Product.fromJson(p)).toList(),
      );
      return cached ?? [];
    }

    if (!_connectivityService.isConnected && !isCacheValid) {
      final cached = await _getFromCache<List<Product>>(
        'cached_products',
        (data) =>
            (data['products'] as List).map((p) => Product.fromJson(p)).toList(),
      );
      return cached ?? [];
    }

    return [];
  }

  Future<void> cacheProducts(List<Product> products) async {
    await _saveToCache('cached_products', {
      'products': products.map((p) => p.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await updateLastSyncTime();
  }

  // Gestion du cache des transactions
  Future<List<Transaction>> getTransactions({bool forceRefresh = false}) async {
    if (!forceRefresh && shouldUseCache) {
      final cached = await _getFromCache<List<Transaction>>(
        'cached_transactions',
        (data) => (data['transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList(),
      );
      return cached ?? [];
    }

    if (!_connectivityService.isConnected && !isCacheValid) {
      final cached = await _getFromCache<List<Transaction>>(
        'cached_transactions',
        (data) => (data['transactions'] as List)
            .map((t) => Transaction.fromJson(t))
            .toList(),
      );
      return cached ?? [];
    }

    return [];
  }

  Future<void> cacheTransactions(List<Transaction> transactions) async {
    await _saveToCache('cached_transactions', {
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await updateLastSyncTime();
  }

  // Gestion du cache des catégories
  Future<List<Category>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && shouldUseCache) {
      final cached = await _getFromCache<List<Category>>(
        'cached_categories',
        (data) => (data['categories'] as List)
            .map((c) => Category.fromJson(c))
            .toList(),
      );
      return cached ?? [];
    }

    if (!_connectivityService.isConnected && !isCacheValid) {
      final cached = await _getFromCache<List<Category>>(
        'cached_categories',
        (data) => (data['categories'] as List)
            .map((c) => Category.fromJson(c))
            .toList(),
      );
      return cached ?? [];
    }

    return [];
  }

  Future<void> cacheCategories(List<Category> categories) async {
    await _saveToCache('cached_categories', {
      'categories': categories.map((c) => c.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    await updateLastSyncTime();
  }

  // Gestion du cache du dashboard
  Future<DashboardData?> getDashboard({bool forceRefresh = false}) async {
    if (!forceRefresh && shouldUseCache) {
      return await _getFromCache<DashboardData>(
        'cached_dashboard',
        (data) => DashboardData.fromJson(data),
      );
    }

    if (!_connectivityService.isConnected && !isCacheValid) {
      return await _getFromCache<DashboardData>(
        'cached_dashboard',
        (data) => DashboardData.fromJson(data),
      );
    }

    return null;
  }

  Future<void> cacheDashboard(DashboardData dashboard) async {
    await _saveToCache('cached_dashboard', dashboard.toJson());
    await updateLastSyncTime();
  }

  // Gestion des statistiques de cache
  Future<Map<String, dynamic>> getCacheStats() async {
    final products = await getProducts();
    final transactions = await getTransactions();
    final categories = await getCategories();

    return {
      'products_count': products.length,
      'transactions_count': transactions.length,
      'categories_count': categories.length,
      'last_sync': lastSyncTime?.toIso8601String(),
      'cache_valid': isCacheValid,
      'is_connected': _connectivityService.isConnected,
      'should_use_cache': shouldUseCache,
      'memory_cache_size': _memoryCache.length,
    };
  }

  // Nettoyage du cache
  Future<void> clearCache() async {
    // Vider le cache mémoire
    _memoryCache.clear();

    // Vider le cache persistant
    await _prefs.remove('cached_products');
    await _prefs.remove('cached_transactions');
    await _prefs.remove('cached_categories');
    await _prefs.remove('cached_dashboard');
    await _prefs.remove(_lastSyncKey);
  }

  // Vérification de l'espace disque utilisé par le cache
  Future<int> getCacheSize() async {
    final products = await getProducts();
    final transactions = await getTransactions();
    final categories = await getCategories();

    int totalSize = 0;

    // Calculer la taille approximative des données
    for (var product in products) {
      totalSize += jsonEncode(product.toJson()).length;
    }

    for (var transaction in transactions) {
      totalSize += jsonEncode(transaction.toJson()).length;
    }

    for (var category in categories) {
      totalSize += jsonEncode(category.toJson()).length;
    }

    return totalSize;
  }

  // Optimisation du cache
  Future<void> optimizeCache() async {
    // Nettoyer le cache mémoire si trop volumineux
    if (_memoryCache.length > 100) {
      _memoryCache.clear();
    }

    print('Cache optimisé');
  }

  // Méthodes pour gérer des éléments individuels
  Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    await cacheProducts(products);
  }

  Future<void> updateProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      await cacheProducts(products);
    }
  }

  Future<void> removeProduct(int productId) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == productId);
    await cacheProducts(products);
  }

  Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await cacheTransactions(transactions);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await cacheTransactions(transactions);
    }
  }

  Future<void> removeTransaction(int transactionId) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == transactionId);
    await cacheTransactions(transactions);
  }

  // Méthodes pour les catégories
  Future<void> addCategory(Category category) async {
    final categories = await getCategories();
    categories.add(category);
    await cacheCategories(categories);
  }

  Future<void> updateCategory(Category category) async {
    final categories = await getCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await cacheCategories(categories);
    }
  }

  Future<void> removeCategory(int categoryId) async {
    final categories = await getCategories();
    categories.removeWhere((c) => c.id == categoryId);
    await cacheCategories(categories);
  }
}
