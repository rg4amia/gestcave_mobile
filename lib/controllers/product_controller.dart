import 'package:get/get.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductController extends GetxController {
  final ApiService _apiService = ApiService();
  var products = <Product>[].obs;
  var lowStockProducts = <Product>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var currentPage = 1.obs;
  var totalProducts = 0.obs;
  var hasMoreData = true.obs;
  var isLoadingMore = false.obs;

  List<Product> get filteredProducts => searchQuery.isEmpty
      ? products
      : products
            .where(
              (p) => p.name.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
            )
            .toList();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreData.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
      products.clear();
    }

    try {
      final response = await _apiService.getProducts(page: currentPage.value);

      if (loadMore) {
        products.addAll(response.products);
      } else {
        products.value = response.products;
      }

      totalProducts.value = response.total;
      hasMoreData.value = currentPage.value < response.lastPage;

      if (hasMoreData.value) {
        currentPage.value++;
      }

      // Fetch low stock products separately
      if (!loadMore) {
        lowStockProducts.value = await _apiService.getLowStockProducts();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch products: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> addProduct(Product product, {File? image}) async {
    try {
      final newProduct = await _apiService.createProduct(product, image: image);
      products.add(newProduct);
      if (newProduct.isLowStock) lowStockProducts.add(newProduct);
      totalProducts.value++;
      Get.snackbar(
        'Success',
        'Product added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void refreshProducts() {
    currentPage.value = 1;
    hasMoreData.value = true;
    fetchProducts();
  }
}
