import 'package:dio/dio.dart' as dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/sync_queue.dart';
import '../models/dashboard.dart';
import 'database_service.dart';
import 'hive_cache_service.dart';
import '../models/paginated_response_product.dart';
import '../models/paginated_response_category.dart';
import '../models/paginated_response_transaction.dart';
import '../models/api_response.dart';
import 'sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api/v1';
  final dio.Dio _dio = dio.Dio();
  String? _token;
  final _storage = FlutterSecureStorage();
  HiveCacheService? _cacheService;

  ApiService() {
    _initializeToken();
    _setupInterceptors();
  }

  Future<void> _ensureCacheServiceInitialized() async {
    if (_cacheService == null) {
      try {
        _cacheService = Get.find<HiveCacheService>();
      } catch (e) {
        // If HiveCacheService is not found, initialize it with SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        Get.lazyPut<HiveCacheService>(() => HiveCacheService(prefs));
        _cacheService = Get.find<HiveCacheService>();
      }
    }
  }

  Future<void> _initializeToken() async {
    _token = await _storage.read(key: 'token');
  }

  /// Sets up Dio interceptors to handle request headers and errors.
  ///
  /// An interceptor is added to include the Authorization header in requests
  /// if a token is available. It also handles 401 Unauthorized errors by
  /// attempting to refresh the token using a stored refresh token. If token
  /// refresh is successful, the original request is retried. In case of
  /// connection or receive timeouts, a network error exception is thrown.
  ///
  /// Throws an exception if there is no refresh token or if session expiration
  /// occurs after a failed token refresh.

  void _setupInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (dio.DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            try {
              final refreshToken = await _storage.read(key: 'refresh_token');
              if (refreshToken == null) {
                throw Exception('No refresh token available');
              }

              final response = await _dio.post(
                '$baseUrl/refresh',
                data: {'refresh_token': refreshToken},
              );

              await _saveTokens(
                token: response.data['token'],
                refreshToken: response.data['refresh_token'],
              );

              // Retry original request
              final retryRequest = await _dio.request(
                e.requestOptions.path,
                data: e.requestOptions.data,
                queryParameters: e.requestOptions.queryParameters,
                options: dio.Options(
                  headers: {'Authorization': 'Bearer $_token'},
                ),
              );
              return handler.resolve(retryRequest);
            } catch (error) {
              await _clearTokens();
              throw Exception('Session expired. Please log in again.');
            }
          }
          if (e.type == dio.DioExceptionType.connectionTimeout ||
              e.type == dio.DioExceptionType.receiveTimeout) {
            throw Exception('Network error: Please check your connection');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> _saveTokens({
    required String token,
    String? refreshToken,
  }) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  Future<void> _clearTokens() async {
    _token = null;
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
      );

      await _saveTokens(
        token: response.data['token'],
        refreshToken: response.data['refresh_token'],
      );

      return response.data;
    } catch (e) {
      print('Login failed: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      await _saveTokens(
        token: response.data['token'],
        refreshToken: response.data['refresh_token'],
      );

      return response.data;
    } catch (e) {
      print('Registration failed: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      _token = await _storage.read(key: 'token');
      await _dio.post(
        '$baseUrl/logout',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      // Even if the server request fails, we still want to clear local tokens
    } finally {
      await _clearTokens();
    }
  }

  Future<PaginatedResponse> getProducts({int page = 1}) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '$baseUrl/products',
        queryParameters: {'page': page},
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
      );

      print('response produit : $response.data');

      final paginatedResponse = PaginatedResponse.fromJson(response.data);

      // Save to cache
      await _cacheService!.cacheProducts(paginatedResponse.products);
      return paginatedResponse;
    } catch (e) {
      print('error: $e');
      // Load from cache
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
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '$baseUrl/products/low-stock',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
      );
      return (response.data as List).map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      final products = await _cacheService!.getProducts();
      return products.where((p) => p.isLowStock).toList();
    }
  }

  Future<ApiResponse<Product>> createProductWithResponse(
    Product product, {
    File? image,
  }) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      dio.FormData formData = dio.FormData.fromMap(product.toJson());
      if (image != null) {
        final compressedImage = await _compressImage(image);
        formData.files.add(
          MapEntry(
            'image',
            dio.MultipartFile.fromBytes(
              compressedImage,
              filename: 'product_image.jpg',
            ),
          ),
        );
      }
      final response = await _dio.post(
        '$baseUrl/products',
        data: formData,
        options: dio.Options(
          headers: {'Authorization': _token != null ? 'Bearer $_token' : null},
        ),
      );
      // Laravel peut renvoyer {data, message, success} ou {errors}
      if (response.data['errors'] != null) {
        return ApiResponse<Product>(
          data: null,
          errors: Map<String, List<String>>.from(
            response.data['errors'].map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            ),
          ),
          message: response.data['message'],
          success: false,
        );
      }
      final newProduct = Product.fromJson(
        response.data['data'] ?? response.data,
      );
      await _cacheService!.addProduct(newProduct);
      return ApiResponse<Product>(
        data: newProduct,
        errors: null,
        message: response.data['message'] ?? 'Produit ajouté avec succès',
        success: true,
      );
    } catch (e) {
      // Gestion d'erreur réseau ou autre
      return ApiResponse<Product>(
        data: null,
        errors: {
          'error': [e.toString()],
        },
        message: 'Erreur lors de la création du produit',
        success: false,
      );
    }
  }

  Future<PaginatedTransactionResponse> getTransactions({int page = 1}) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '$baseUrl/transactions',
        queryParameters: {'page': page},
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
      );
      final paginatedResponse = PaginatedTransactionResponse.fromJson(
        response.data,
      );

      await _cacheService!.cacheTransactions(paginatedResponse.transactions);
      return paginatedResponse;
    } catch (e) {
      print('error transaction : $e');
      final transactions = await _cacheService!.getTransactions();
      return PaginatedTransactionResponse(
        transactions: transactions,
        total: transactions.length,
        currentPage: 1,
        lastPage: 1,
        perPage: transactions.length,
        from: 1,
        to: transactions.length,
      );
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.post(
        '$baseUrl/transactions',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
        data: transaction.toJson(),
      );
      print('response : ${response.data}');
      final newTransaction = Transaction.fromJson(response.data);
      await _cacheService!.addTransaction(newTransaction);
      return newTransaction;
    } catch (e) {
      await DatabaseService().addToSyncQueue(
        SyncQueue(
          id: DateTime.now().millisecondsSinceEpoch,
          action: 'create',
          entity: 'transaction',
          data: transaction.toJson(),
        ),
      );
      throw Exception('Failed to create transaction: $e');
    }
  }

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '$baseUrl/transactions/statistics',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }

  Future<PaginatedCategoryResponse> getCategories({int page = 1}) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '$baseUrl/categories',
        queryParameters: {'page': page},
      );
      final paginatedResponse = PaginatedCategoryResponse.fromJson(
        response.data,
      );
      await _cacheService!.cacheCategories(paginatedResponse.categories);
      return paginatedResponse;
    } catch (e) {
      final categories = await _cacheService!.getCategories();
      return PaginatedCategoryResponse(
        categories: categories,
        total: categories.length,
        currentPage: 1,
        lastPage: 1,
        perPage: categories.length,
        from: 1,
        to: categories.length,
      );
    }
  }

  Future<ApiResponse<Category>> createCategoryWithResponse(
    Category category,
  ) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.post(
        '$baseUrl/categories',
        data: category.toJson(),
      );
      if (response.data['errors'] != null) {
        return ApiResponse<Category>(
          data: null,
          errors: Map<String, List<String>>.from(
            response.data['errors'].map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            ),
          ),
          message: response.data['message'],
          success: false,
        );
      }
      final newCategory = Category.fromJson(
        response.data['data'] ?? response.data,
      );
      await _cacheService!.addCategory(newCategory);
      return ApiResponse<Category>(
        data: newCategory,
        errors: null,
        message: response.data['message'] ?? 'Catégorie ajoutée avec succès',
        success: true,
      );
    } catch (e) {
      return ApiResponse<Category>(
        data: null,
        errors: {
          'error': [e.toString()],
        },
        message: 'Erreur lors de la création de la catégorie',
        success: false,
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      await _dio.delete('$baseUrl/categories/$id');
      await _cacheService!.removeCategory(id);
    } catch (e) {
      await DatabaseService().addToSyncQueue(
        SyncQueue(
          id: DateTime.now().millisecondsSinceEpoch,
          action: 'delete',
          entity: 'category',
          data: {'id': id},
        ),
      );
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      await _dio.delete('$baseUrl/products/$id');
      await _cacheService!.removeProduct(id);
    } catch (e) {
      await DatabaseService().addToSyncQueue(
        SyncQueue(
          id: DateTime.now().millisecondsSinceEpoch,
          action: 'delete',
          entity: 'product',
          data: {'id': id},
        ),
      );
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      await _dio.delete('$baseUrl/transactions/$id');
      await _cacheService!.removeTransaction(id);
    } catch (e) {
      await DatabaseService().addToSyncQueue(
        SyncQueue(
          id: DateTime.now().millisecondsSinceEpoch,
          action: 'delete',
          entity: 'transaction',
          data: {'id': id},
        ),
      );
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<Map<String, dynamic>> getReports() async {
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '$baseUrl/reports',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  Future<Uint8List> exportReports() async {
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '$baseUrl/reports/export',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
      );
      // TODO: Process response data into PDF (e.g., using pdf package)
      return response.data as Uint8List;
    } catch (e) {
      throw Exception('Failed to export reports: $e');
    }
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
    final dbService = DatabaseService();
    final syncQueue = await dbService.getSyncQueue();
    _token = await _storage.read(key: 'token');

    for (var item in syncQueue) {
      try {
        switch (item.action) {
          case 'create':
            switch (item.entity) {
              case 'product':
                await _dio.post(
                  '$baseUrl/products',
                  data: item.data,
                  options: dio.Options(
                    headers: {
                      'Authorization': _token != null ? 'Bearer $_token' : null,
                    },
                  ),
                );
                break;
              case 'transaction':
                await _dio.post(
                  '$baseUrl/transactions',
                  data: item.data,
                  options: dio.Options(
                    headers: {
                      'Authorization': _token != null ? 'Bearer $_token' : null,
                    },
                  ),
                );
                break;
              case 'category':
                await _dio.post(
                  '$baseUrl/categories',
                  data: item.data,
                  options: dio.Options(
                    headers: {
                      'Authorization': _token != null ? 'Bearer $_token' : null,
                    },
                  ),
                );
                break;
            }
            break;
          case 'delete':
            switch (item.entity) {
              case 'product':
                await _dio.delete(
                  '$baseUrl/products/${item.data['id']}',
                  options: dio.Options(
                    headers: {
                      'Authorization': _token != null ? 'Bearer $_token' : null,
                    },
                  ),
                );
                break;
              case 'transaction':
                await _dio.delete(
                  '$baseUrl/transactions/${item.data['id']}',
                  options: dio.Options(
                    headers: {
                      'Authorization': _token != null ? 'Bearer $_token' : null,
                    },
                  ),
                );
                break;
              case 'category':
                await _dio.delete(
                  '$baseUrl/categories/${item.data['id']}',
                  options: dio.Options(
                    headers: {
                      'Authorization': _token != null ? 'Bearer $_token' : null,
                    },
                  ),
                );
                break;
            }
            break;
        }
        await dbService.removeSyncQueueItem(item.id);
      } catch (e) {
        print('Failed to sync item ${item.id}: $e');
        continue;
      }
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '$baseUrl/user',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<DashboardData> getDashboardData() async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      var url = '$baseUrl/dashboard';
      final response = await _dio.get(
        url,
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
      );
      //print('verif data $response.data');
      final dashboardData = DashboardData.fromJson(response.data);
      //print('verif data $dashboardData.totalValue');
      await _cacheService!.cacheDashboard(dashboardData);
      return dashboardData;
    } catch (e) {
      print('error get dashboard data : $e');
      // Essayer de récupérer depuis le cache
      final cachedDashboard = await _cacheService!.getDashboard();
      if (cachedDashboard != null) {
        return cachedDashboard;
      }
      throw Exception('Failed to get dashboard data: $e');
    }
  }

  Future<ApiResponse<Transaction>> createTransactionWithResponse(
    Transaction transaction,
  ) async {
    await _ensureCacheServiceInitialized();
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.post(
        '$baseUrl/transactions',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),
        data: transaction.toJson(),
      );
      if (response.data['errors'] != null) {
        return ApiResponse<Transaction>(
          data: null,
          errors: Map<String, List<String>>.from(
            response.data['errors'].map(
              (k, v) => MapEntry(k, List<String>.from(v)),
            ),
          ),
          message: response.data['message'],
          success: false,
        );
      }
      final newTransaction = Transaction.fromJson(
        response.data['data'] ?? response.data,
      );
      await _cacheService!.addTransaction(newTransaction);
      return ApiResponse<Transaction>(
        data: newTransaction,
        errors: null,
        message: response.data['message'] ?? 'Transaction ajoutée avec succès',
        success: true,
      );
    } catch (e) {
      return ApiResponse<Transaction>(
        data: null,
        errors: {
          'error': [e.toString()],
        },
        message: 'Erreur lors de la création de la transaction',
        success: false,
      );
    }
  }

  /// Vide le token d'authentification
  Future<void> clearAuthToken() async {
    await _clearTokens();
  }

  /// Vide toutes les données de la base de données locale
  Future<void> clearAllData() async {
    await _ensureCacheServiceInitialized();
    await _cacheService!.clearCache();
  }

  /// Arrête la synchronisation en arrière-plan
  Future<void> stopBackgroundSync() async {
    final syncService = SyncService();
    syncService.stop();
  }
}
