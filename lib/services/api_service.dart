import 'package:dio/dio.dart' as dio;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/sync_queue.dart';
import '../models/dashboard.dart';
import 'database_service.dart';
import '../models/paginated_response_product.dart';
import '../models/paginated_response_category.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000/api/v1';
  final dio.Dio _dio = dio.Dio();
  String? _token;
  final _storage = FlutterSecureStorage();

  ApiService() {
    _initializeToken();
    _setupInterceptors();
  }

  Future<void> _initializeToken() async {
    _token = await _storage.read(key: 'token');
  }

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

  Future<void> logout() async {
    try {
     _token = await _storage.read(key: 'token');
      await _dio.post('$baseUrl/logout',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),);
    } catch (e) {
      // Even if the server request fails, we still want to clear local tokens
    } finally {
      await _clearTokens();
    }
  }

  Future<PaginatedResponse> getProducts({int page = 1}) async {
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

      final paginatedResponse = PaginatedResponse.fromJson(response.data);

      // Save to local database
      final dbService = DatabaseService();
      for (var product in paginatedResponse.products) {
        await dbService.saveProduct(product);
      }
      return paginatedResponse;
    } catch (e) {
      print('error: $e');
      // Load from local database
      final dbService = DatabaseService();
      final products = await dbService.getProducts();
      return PaginatedResponse(
        products: products,
        total: products.length,
        currentPage: 1,
        lastPage: 1,
      );
    }
  }

  Future<List<Product>> getLowStockProducts() async {
    try {
       _token = await _storage.read(key: 'token');
      final response = await _dio.get('$baseUrl/products/low-stock',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),);
      return (response.data as List).map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      final dbService = DatabaseService();
      final products = await dbService.getProducts();
      return products.where((p) => p.isLowStock).toList();
    }
  }

  Future<Product> createProduct(Product product, {File? image}) async {
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
      final response = await _dio.post('$baseUrl/products', data: formData,
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),);
      final newProduct = Product.fromJson(response.data);
      await DatabaseService().saveProduct(newProduct);
      return newProduct;
    } catch (e) {
      // Queue for offline sync
      await DatabaseService().addToSyncQueue(
        SyncQueue(
          id: DateTime.now().millisecondsSinceEpoch,
          action: 'create',
          entity: 'product',
          data: product.toJson(),
        ),
      );
      throw Exception('Failed to create product: $e');
    }
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get('$baseUrl/transactions',
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),);
      final transactions = (response.data as List)
          .map((t) => Transaction.fromJson(t))
          .toList();
      final dbService = DatabaseService();
      for (var transaction in transactions) {
        await dbService.saveTransaction(transaction);
      }
      return transactions;
    } catch (e) {
      final dbService = DatabaseService();
      return await dbService.getTransactions();
    }
  }

  Future<Transaction> createTransaction(Transaction transaction) async {
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
      final newTransaction = Transaction.fromJson(response.data);
      await DatabaseService().saveTransaction(newTransaction);
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
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.get(
        '$baseUrl/categories',
        queryParameters: {'page': page},
      );
      final paginatedResponse = PaginatedCategoryResponse.fromJson(
        response.data,
      );
      await DatabaseService().saveCategories(paginatedResponse.categories);
      return paginatedResponse;
    } catch (e) {
      final categories = await DatabaseService().getCategories();
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

  Future<Category> createCategory(Category category) async {
    try {
      _token = await _storage.read(key: 'token');
      final response = await _dio.post(
        '$baseUrl/categories',
        data: category.toJson(),
      );
      final newCategory = Category.fromJson(response.data);
      await DatabaseService().saveCategory(newCategory);
      return newCategory;
    } catch (e) {
      await DatabaseService().addToSyncQueue(
        SyncQueue(
          id: DateTime.now().millisecondsSinceEpoch,
          action: 'create',
          entity: 'category',
          data: category.toJson(),
        ),
      );
      throw Exception('Failed to create category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      _token = await _storage.read(key: 'token');
      await _dio.delete('$baseUrl/categories/$id');
      await DatabaseService().deleteCategory(id);
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
    try {
     _token = await _storage.read(key: 'token');
      await _dio.delete('$baseUrl/products/$id');
      await DatabaseService().deleteProduct(id);
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
    try {
      _token = await _storage.read(key: 'token');
      await _dio.delete('$baseUrl/transactions/$id');
      await DatabaseService().deleteTransaction(id);
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
                await _dio.post('$baseUrl/products', data: item.data,
                options: dio.Options(
                  headers: {
                    'Authorization': _token != null ? 'Bearer $_token' : null,
                    'Content-Type': 'application/json',
                  },
                ),);
                break;
              case 'transaction':
                await _dio.post('$baseUrl/transactions', data: item.data,
                options: dio.Options(
                  headers: {
                    'Authorization': _token != null ? 'Bearer $_token' : null,
                    'Content-Type': 'application/json',
                  },
                ),);
                break;
              case 'category':
                await _dio.post('$baseUrl/categories', data: item.data, 
                options: dio.Options(
                  headers: {
                    'Authorization': _token != null ? 'Bearer $_token' : null,
                    'Content-Type': 'application/json',
                  },
                ),);
                break;
            }
            break;
          case 'delete':
            switch (item.entity) {
              case 'product':
                await _dio.delete('$baseUrl/products/${item.data['id']}',
                options: dio.Options(
                  headers: {
                    'Authorization': _token != null ? 'Bearer $_token' : null,
                    'Content-Type': 'application/json',
                  },
                ),);
                break;
              case 'transaction':
                await _dio.delete('$baseUrl/transactions/${item.data['id']}',
                options: dio.Options(
                  headers: {
                    'Authorization': _token != null ? 'Bearer $_token' : null,
                    'Content-Type': 'application/json',
                  },
                ),);
                break;
              case 'category':
                await _dio.delete('$baseUrl/categories/${item.data['id']}',
                options: dio.Options(
                  headers: {
                    'Authorization': _token != null ? 'Bearer $_token' : null,
                    'Content-Type': 'application/json',
                  },
                ),);
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
    try {
      _token = await _storage.read(key: 'token');
      print('token : $_token');
      var url = '$baseUrl/dashboard';
      print('url get dashboard : $url');
      final response = await _dio.get(url,
        options: dio.Options(
          headers: {
            'Authorization': _token != null ? 'Bearer $_token' : null,
            'Content-Type': 'application/json',
          },
        ),);
      print('response dashboard : ${response.data}');
      return DashboardData.fromJson(response.data);
    } catch (e) {
      print('error get dashboard data : $e');
      throw Exception('Failed to get dashboard data: $e');
    }
  }
}
