import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../routes/app_pages.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final _storage = FlutterSecureStorage();
  var user = Rxn<User>();
  var token = RxnString();
  var refreshToken = RxnString();
  var isLoading = false.obs;

  bool get isAuthenticated => token.value != null;
  bool get isAdmin => user.value?.role == 'admin';

  @override
  void onInit() {
    super.onInit();
    loadTokens();
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await _apiService.login(email, password);
      user.value = User.fromJson(response['user']);
      token.value = response['token'];
      refreshToken.value = response['refresh_token'];

      // Save tokens to secure storage
      await _storage.write(key: 'token', value: token.value);
      if (refreshToken.value != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken.value);
      }

      print('token: ${await _storage.read(key: 'token')}');
      print('refreshToken: ${await _storage.read(key: 'refresh_token')}');

      await _apiService.syncOfflineData(); // Sync offline data on login
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text('Login Failed'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } finally {
      await _clearTokens();
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refresh_token');
    user.value = null;
    token.value = null;
    refreshToken.value = null;
  }

  Future<void> loadTokens() async {
    token.value = await _storage.read(key: 'token');
    refreshToken.value = await _storage.read(key: 'refresh_token');

    if (token.value != null) {
      try {
        final userData = await _apiService.getUserData();
        user.value = User.fromJson(userData);
        print('user: ${user.value?.email}');
        if (user.value?.email != null) {
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
      } catch (e) {
        print('Failed to load user data: $e');
        await _clearTokens();
      }
    }
  }
}
