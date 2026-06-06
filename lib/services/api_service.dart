import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/api_response.dart';
import '../models/category.dart';
import '../models/dashboard.dart';
import '../models/paginated_response_category.dart';
import '../models/paginated_response_product.dart';
import '../models/paginated_response_transaction.dart';
import '../models/product.dart';
import '../models/sync_queue.dart';
import '../models/transaction.dart';
import 'database_service.dart';
import 'hive_cache_service.dart';
import 'sync_service.dart';

class ApiService {
  static const int _productsPerPage = 20;
  static const int _categoriesPerPage = 10;
  static const int _transactionsPerPage = 20;

  static bool _supabaseInitialized = false;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  HiveCacheService? _cacheService;

  static Future<void> initializeSupabase() async {
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: '.env');
    }

    if (_supabaseInitialized) {
      return;
    }

    final url = dotenv.env['SUPABASE_URL'];
    final publishableKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

    if (url == null ||
        url.isEmpty ||
        publishableKey == null ||
        publishableKey.isEmpty) {
      throw Exception(
        'SUPABASE_URL ou SUPABASE_PUBLISHABLE_KEY manquant dans le fichier .env',
      );
    }

    await supabase.Supabase.initialize(
      url: url,
      publishableKey: publishableKey,
    );

    _supabaseInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    await initializeSupabase();
  }

  supabase.SupabaseClient get _client => supabase.Supabase.instance.client;

  String get _storageBucket =>
      dotenv.env['SUPABASE_STORAGE_BUCKET'] ?? 'product-images';

  Future<void> _ensureCacheServiceInitialized() async {
    if (_cacheService == null) {
      try {
        _cacheService = Get.find<HiveCacheService>();
      } catch (_) {
        final prefs = await SharedPreferences.getInstance();
        Get.lazyPut<HiveCacheService>(() => HiveCacheService(prefs));
        _cacheService = Get.find<HiveCacheService>();
      }
    }
  }

  Future<void> _persistSession(supabase.Session? session) async {
    if (session == null) {
      return;
    }

    await _storage.write(key: 'token', value: session.accessToken);
    await _storage.write(key: 'refresh_token', value: session.refreshToken);
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refresh_token');
  }

  String _slugify(String value) {
    final slug = value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'item' : slug;
  }

  String? _nullIfEmpty(String? value) {
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int _lastPageFromTotal(int total, int perPage) {
    if (total <= 0) {
      return 1;
    }

    return (total / perPage).ceil();
  }

  String _displayError(Object error, String fallbackMessage) {
    if (error is supabase.AuthException) {
      return error.message;
    }

    if (error is supabase.PostgrestException) {
      return error.message;
    }

    return '$fallbackMessage: $error';
  }

  Map<String, List<String>> _fieldErrorsFromException(
    Object error, {
    String fallbackKey = 'error',
  }) {
    final message = error is supabase.AuthException
        ? error.message
        : error is supabase.PostgrestException
        ? error.message
        : error.toString();

    return {
      fallbackKey: [message],
    };
  }

  Future<supabase.User> _requireAuthUser() async {
    await _ensureInitialized();

    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      throw Exception('Aucune session active. Veuillez vous reconnecter.');
    }

    return authUser;
  }

  Future<Map<String, dynamic>> _ensurePublicUserFromAuthUser({
    String? fallbackName,
    String? fallbackEmail,
  }) async {
    final authUser = await _requireAuthUser();

    final existing = await _client
        .from('users')
        .select('id, auth_user_id, name, email, role')
        .eq('auth_user_id', authUser.id)
        .maybeSingle();

    if (existing != null) {
      return Map<String, dynamic>.from(existing);
    }

    final inserted = await _client
        .from('users')
        .insert({
          'auth_user_id': authUser.id,
          'name':
              fallbackName ??
              authUser.userMetadata?['name']?.toString() ??
              authUser.email?.split('@').first ??
              'Utilisateur',
          'email': fallbackEmail ?? authUser.email,
          'role': 'user',
        })
        .select('id, auth_user_id, name, email, role')
        .single();

    return Map<String, dynamic>.from(inserted);
  }

  String _productSelectColumns() {
    return '''
      id,
      category_id,
      name,
      slug,
      description,
      price,
      stock_quantity,
      minimum_stock,
      barcode,
      image_path,
      purchase_price,
      sale_price,
      created_at,
      updated_at,
      category:categories (
        id,
        name,
        slug,
        description,
        created_at,
        updated_at
      )
    ''';
  }

  String _transactionSelectColumns() {
    return '''
      id,
      product_id,
      user_id,
      type,
      quantity,
      unit_price,
      total_price,
      purchase_price,
      sale_price,
      notes,
      created_at,
      updated_at,
      product:products (
        id,
        category_id,
        name,
        slug,
        description,
        price,
        stock_quantity,
        minimum_stock,
        barcode,
        image_path,
        purchase_price,
        sale_price,
        created_at,
        updated_at,
        category:categories (
          id,
          name,
          slug,
          description,
          created_at,
          updated_at
        )
      ),
      user:users (
        id,
        name,
        email,
        role
      )
    ''';
  }

  Future<String?> _uploadProductImage(File image, String productName) async {
    final compressedImage = await _compressImage(image);
    final safeName = _slugify(productName);
    final filePath =
        'products/${DateTime.now().millisecondsSinceEpoch}_$safeName.jpg';

    await _client.storage
        .from(_storageBucket)
        .uploadBinary(
          filePath,
          compressedImage,
          fileOptions: const supabase.FileOptions(
            cacheControl: '3600',
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return _client.storage.from(_storageBucket).getPublicUrl(filePath);
  }

  Future<Map<String, dynamic>> _createProductRecord(
    Map<String, dynamic> payload,
  ) async {
    final inserted = await _client
        .from('products')
        .insert(payload)
        .select(_productSelectColumns())
        .single();

    return Map<String, dynamic>.from(inserted);
  }

  Future<Map<String, dynamic>> _createCategoryRecord(
    Map<String, dynamic> payload,
  ) async {
    final inserted = await _client
        .from('categories')
        .insert(payload)
        .select('id, name, slug, description, created_at, updated_at')
        .single();

    return Map<String, dynamic>.from(inserted);
  }

  Future<void> _deleteRecord(String table, int id) async {
    await _client.from(table).delete().eq('id', id);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    await _ensureInitialized();

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await _persistSession(response.session);
      final user = await _ensurePublicUserFromAuthUser(fallbackEmail: email);

      return {
        'token': response.session?.accessToken,
        'refresh_token': response.session?.refreshToken,
        'user': user,
      };
    } catch (error) {
      throw Exception(_displayError(error, 'Échec de connexion'));
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    await _ensureInitialized();

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.session == null) {
        throw Exception(
          "L'utilisateur a été créé sans session active. Désactivez la confirmation email dans Supabase Auth pour garder le même flux que Laravel.",
        );
      }

      await _persistSession(response.session);
      final user = await _ensurePublicUserFromAuthUser(
        fallbackName: name,
        fallbackEmail: email,
      );

      return {
        'token': response.session?.accessToken,
        'refresh_token': response.session?.refreshToken,
        'user': user,
      };
    } catch (error) {
      throw Exception(_displayError(error, 'Échec de création du compte'));
    }
  }

  Future<void> logout() async {
    await _ensureInitialized();

    try {
      await _client.auth.signOut();
    } catch (_) {
      // La session locale doit être nettoyée même si la requête distante échoue.
    } finally {
      await _clearTokens();
    }
  }

  Future<PaginatedResponse> getProducts({int page = 1}) async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      final from = (page - 1) * _productsPerPage;
      final to = from + _productsPerPage - 1;

      final response = await _client
          .from('products')
          .select(_productSelectColumns())
          .order('created_at', ascending: false)
          .range(from, to)
          .count();

      final rows = List<Map<String, dynamic>>.from(response.data);
      final products = rows.map(Product.fromJson).toList();
      final total = response.count ?? products.length;

      await _cacheService!.cacheProducts(products);

      return PaginatedResponse(
        products: products,
        total: total,
        currentPage: page,
        lastPage: _lastPageFromTotal(total, _productsPerPage),
      );
    } catch (error) {
      final products = await _cacheService!.getProducts();
      return PaginatedResponse(
        products: products,
        total: products.length,
        currentPage: 1,
        lastPage: 1,
      );
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      final response = await _client.rpc('get_low_stock_products');
      final rows = List<Map<String, dynamic>>.from(response as List);
      return rows.map(Product.fromJson).toList();
    } catch (_) {
      try {
        final response = await _client
            .from('products')
            .select(_productSelectColumns())
            .order('created_at', ascending: false);

        final rows = List<Map<String, dynamic>>.from(response);
        return rows
            .map(Product.fromJson)
            .where((product) => product.isLowStock)
            .toList();
      } catch (_) {
        final products = await _cacheService!.getProducts();
        return products.where((product) => product.isLowStock).toList();
      }
    }
  }

  Future<ApiResponse<Product>> createProductWithResponse(
    Product product, {
    File? image,
  }) async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      final imagePath = image != null
          ? await _uploadProductImage(image, product.name)
          : _nullIfEmpty(product.imagePath);

      final payload = <String, dynamic>{
        'category_id': product.categoryId,
        'name': product.name.trim(),
        'slug': _slugify(product.name),
        'description': _nullIfEmpty(product.description),
        'price': product.price,
        'purchase_price': product.purchasePrice,
        'sale_price': product.salePrice,
        'stock_quantity': product.stockQuantity,
        'minimum_stock': product.minimumStock,
        'barcode': _nullIfEmpty(product.barcode),
        'image_path': imagePath,
      };

      final inserted = await _createProductRecord(payload);
      final newProduct = Product.fromJson(inserted);

      await _cacheService!.addProduct(newProduct);

      return ApiResponse<Product>(
        data: newProduct,
        errors: null,
        message: 'Produit ajouté avec succès',
        success: true,
      );
    } catch (error) {
      return ApiResponse<Product>(
        data: null,
        errors: _fieldErrorsFromException(error),
        message: 'Erreur lors de la création du produit',
        success: false,
      );
    }
  }

  Future<PaginatedTransactionResponse> getTransactions({int page = 1}) async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      final from = (page - 1) * _transactionsPerPage;
      final to = from + _transactionsPerPage - 1;

      final response = await _client
          .from('transactions')
          .select(_transactionSelectColumns())
          .order('created_at', ascending: false)
          .range(from, to)
          .count();

      final rows = List<Map<String, dynamic>>.from(response.data);
      final transactions = rows.map(Transaction.fromJson).toList();
      final total = response.count ?? transactions.length;

      await _cacheService!.cacheTransactions(transactions);

      return PaginatedTransactionResponse(
        transactions: transactions,
        total: total,
        currentPage: page,
        lastPage: _lastPageFromTotal(total, _transactionsPerPage),
        perPage: _transactionsPerPage,
        from: total == 0 ? 0 : from + 1,
        to: total == 0 ? 0 : from + transactions.length,
      );
    } catch (error) {
      final transactions = await _cacheService!.getTransactions();
      return PaginatedTransactionResponse(
        transactions: transactions,
        total: transactions.length,
        currentPage: 1,
        lastPage: 1,
        perPage: transactions.length,
        from: transactions.isEmpty ? 0 : 1,
        to: transactions.length,
      );
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    final response = await createTransactionWithResponse(transaction);
    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message);
  }

  Future<Map<String, dynamic>> getStatistics() async {
    await _ensureInitialized();

    try {
      final response = await _client.rpc('get_transaction_statistics');
      return Map<String, dynamic>.from(response as Map);
    } catch (_) {
      final transactionResponse = await _client
          .from('transactions')
          .select(_transactionSelectColumns())
          .order('created_at', ascending: false);

      final transactions = List<Map<String, dynamic>>.from(
        transactionResponse,
      ).map(Transaction.fromJson).toList();

      final recentTransactions = transactions
          .take(5)
          .map((item) => item.toJson());

      return {
        'total_in': transactions
            .where((item) => item.type == 'in')
            .fold<double>(0, (sum, item) => sum + item.totalPrice),
        'total_out': transactions
            .where((item) => item.type == 'out')
            .fold<double>(0, (sum, item) => sum + item.totalPrice),
        'total_transactions': transactions.length,
        'recent_transactions': recentTransactions.toList(),
      };
    }
  }

  Future<PaginatedCategoryResponse> getCategories({int page = 1}) async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      final from = (page - 1) * _categoriesPerPage;
      final to = from + _categoriesPerPage - 1;

      final response = await _client
          .from('categories')
          .select('id, name, slug, description, created_at, updated_at')
          .order('created_at', ascending: false)
          .range(from, to)
          .count();

      final rows = List<Map<String, dynamic>>.from(response.data);
      final total = response.count ?? rows.length;

      final productRows = List<Map<String, dynamic>>.from(
        await _client.from('products').select('category_id'),
      );

      final counts = <int, int>{};
      for (final row in productRows) {
        final categoryId = row['category_id'] as int?;
        if (categoryId != null) {
          counts[categoryId] = (counts[categoryId] ?? 0) + 1;
        }
      }

      final categories = rows
          .map(
            (row) => Category.fromJson({
              ...row,
              'products_count': counts[row['id']] ?? 0,
            }),
          )
          .toList();

      await _cacheService!.cacheCategories(categories);

      return PaginatedCategoryResponse(
        categories: categories,
        total: total,
        currentPage: page,
        lastPage: _lastPageFromTotal(total, _categoriesPerPage),
        nextPageUrl: null,
        prevPageUrl: null,
        perPage: _categoriesPerPage,
        from: total == 0 ? 0 : from + 1,
        to: total == 0 ? 0 : from + categories.length,
      );
    } catch (error) {
      final categories = await _cacheService!.getCategories();
      return PaginatedCategoryResponse(
        categories: categories,
        total: categories.length,
        currentPage: 1,
        lastPage: 1,
        perPage: categories.length,
        from: categories.isEmpty ? 0 : 1,
        to: categories.length,
      );
    }
  }

  Future<ApiResponse<Category>> createCategoryWithResponse(
    Category category,
  ) async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      final payload = <String, dynamic>{
        'name': category.name.trim(),
        'slug': _slugify(category.name),
        'description': _nullIfEmpty(category.description),
      };

      final inserted = await _createCategoryRecord(payload);
      final newCategory = Category.fromJson({...inserted, 'products_count': 0});

      await _cacheService!.addCategory(newCategory);

      return ApiResponse<Category>(
        data: newCategory,
        errors: null,
        message: 'Catégorie ajoutée avec succès',
        success: true,
      );
    } catch (error) {
      return ApiResponse<Category>(
        data: null,
        errors: _fieldErrorsFromException(error),
        message: 'Erreur lors de la création de la catégorie',
        success: false,
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      await _deleteRecord('categories', id);
      await _cacheService!.removeCategory(id);
    } catch (error) {
      await DatabaseService().addToSyncQueue(
        SyncQueue(
          id: DateTime.now().millisecondsSinceEpoch,
          action: 'delete',
          entity: 'category',
          data: {'id': id},
        ),
      );
      throw Exception('Failed to delete category: $error');
    }
  }

  Future<void> deleteProduct(int id) async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      await _deleteRecord('products', id);
      await _cacheService!.removeProduct(id);
    } catch (error) {
      await DatabaseService().addToSyncQueue(
        SyncQueue(
          id: DateTime.now().millisecondsSinceEpoch,
          action: 'delete',
          entity: 'product',
          data: {'id': id},
        ),
      );
      throw Exception('Failed to delete product: $error');
    }
  }

  Future<void> deleteTransaction(int id) async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      await _deleteRecord('transactions', id);
      await _cacheService!.removeTransaction(id);
    } catch (error) {
      await DatabaseService().addToSyncQueue(
        SyncQueue(
          id: DateTime.now().millisecondsSinceEpoch,
          action: 'delete',
          entity: 'transaction',
          data: {'id': id},
        ),
      );
      throw Exception('Failed to delete transaction: $error');
    }
  }

  Future<Map<String, dynamic>> getReports() async {
    return getStatistics();
  }

  Future<Uint8List> exportReports() async {
    throw Exception(
      "L'export des rapports n'est pas encore migré vers Supabase.",
    );
  }

  Future<Uint8List> _compressImage(File image) async {
    final result = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      minWidth: 800,
      minHeight: 800,
      quality: 85,
    );
    return result!;
  }

  Future<void> syncOfflineData() async {
    await _ensureInitialized();

    final dbService = DatabaseService();
    final syncQueue = await dbService.getSyncQueue();

    for (final item in syncQueue) {
      try {
        switch (item.action) {
          case 'create':
            if (item.entity == 'product') {
              await _createProductRecord(Map<String, dynamic>.from(item.data));
            } else if (item.entity == 'transaction') {
              await _client.rpc(
                'create_transaction_with_stock',
                params: {
                  'p_product_id': item.data['product_id'],
                  'p_type': item.data['type'],
                  'p_quantity': item.data['quantity'],
                  'p_unit_price': item.data['unit_price'],
                  'p_notes': item.data['notes'],
                },
              );
            } else if (item.entity == 'category') {
              await _createCategoryRecord(Map<String, dynamic>.from(item.data));
            }
            break;
          case 'delete':
            if (item.entity == 'product') {
              await _deleteRecord('products', item.data['id'] as int);
            } else if (item.entity == 'transaction') {
              await _deleteRecord('transactions', item.data['id'] as int);
            } else if (item.entity == 'category') {
              await _deleteRecord('categories', item.data['id'] as int);
            }
            break;
        }

        await dbService.removeSyncQueueItem(item.id);
      } catch (_) {
        continue;
      }
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    await _ensureInitialized();
    final user = await _ensurePublicUserFromAuthUser();
    return {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'role': user['role'] ?? 'user',
    };
  }

  Future<DashboardData> getDashboardData() async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      final response = await _client.rpc('get_dashboard_data');
      final dashboardData = DashboardData.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
      await _cacheService!.cacheDashboard(dashboardData);
      return dashboardData;
    } catch (error) {
      final cachedDashboard = await _cacheService!.getDashboard();
      if (cachedDashboard != null) {
        return cachedDashboard;
      }
      throw Exception('Failed to get dashboard data: $error');
    }
  }

  Future<ApiResponse<Transaction>> createTransactionWithResponse(
    Transaction transaction,
  ) async {
    await _ensureInitialized();
    await _ensureCacheServiceInitialized();

    try {
      final response = await _client.rpc(
        'create_transaction_with_stock',
        params: {
          'p_product_id': transaction.productId,
          'p_type': transaction.type,
          'p_quantity': transaction.quantity,
          'p_unit_price': transaction.unitPrice,
          'p_notes': transaction.notes,
        },
      );

      final newTransaction = Transaction.fromJson(
        Map<String, dynamic>.from(response as Map),
      );

      await _cacheService!.addTransaction(newTransaction);

      return ApiResponse<Transaction>(
        data: newTransaction,
        errors: null,
        message: 'Transaction ajoutée avec succès',
        success: true,
      );
    } catch (error) {
      return ApiResponse<Transaction>(
        data: null,
        errors: _fieldErrorsFromException(error),
        message: 'Erreur lors de la création de la transaction',
        success: false,
      );
    }
  }

  Future<void> clearAuthToken() async {
    await logout();
  }

  Future<void> clearAllData() async {
    await _ensureCacheServiceInitialized();
    await _cacheService!.clearCache();
  }

  Future<void> stopBackgroundSync() async {
    SyncService().stop();
  }
}
