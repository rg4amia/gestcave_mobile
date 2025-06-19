import 'package:get/get.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';

enum StockFilter { all, outOfStock, critical, lowStock }

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

  // Filtres de stock
  var selectedStockFilter = StockFilter.all.obs;
  var searchSuggestions = <String>[].obs;
  var showSearchSuggestions = false.obs;
  var selectedCategory = Rxn<String>(); // null = toutes catégories

  List<String> get categories {
    final set = <String>{};
    for (final p in products) {
      if (p.category?.name != null) set.add(p.category!.name);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<Product> get filteredProducts {
    List<Product> filtered = products;

    // Filtre par recherche
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ) ||
                (p.category?.name.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    // Filtre par catégorie
    if (selectedCategory.value != null) {
      filtered = filtered
          .where((p) => p.category?.name == selectedCategory.value)
          .toList();
    }

    // Filtre par stock
    switch (selectedStockFilter.value) {
      case StockFilter.outOfStock:
        filtered = filtered.where((p) => p.stockQuantity == 0).toList();
        break;
      case StockFilter.critical:
        filtered = filtered
            .where(
              (p) => p.stockQuantity > 0 && p.stockQuantity <= p.minimumStock,
            )
            .toList();
        break;
      case StockFilter.lowStock:
        filtered = filtered.where((p) => p.isLowStock).toList();
        break;
      case StockFilter.all:
      default:
        // Pas de filtre supplémentaire
        break;
    }

    return filtered;
  }

  // Getters pour les statistiques
  int get outOfStockCount => products.where((p) => p.stockQuantity == 0).length;
  int get criticalStockCount => products
      .where((p) => p.stockQuantity > 0 && p.stockQuantity <= p.minimumStock)
      .length;
  int get lowStockCount => products.where((p) => p.isLowStock).length;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    _generateSearchSuggestions();
  }

  void _generateSearchSuggestions() {
    final suggestions = <String>{};

    // Ajouter les noms de produits
    for (final product in products) {
      suggestions.add(product.name);
    }

    // Ajouter les noms de catégories
    for (final product in products) {
      if (product.category?.name != null) {
        suggestions.add(product.category!.name);
      }
    }

    searchSuggestions.value = suggestions.toList()..sort();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    showSearchSuggestions.value = query.isNotEmpty;

    if (query.isEmpty) {
      showSearchSuggestions.value = false;
    }
  }

  void selectSearchSuggestion(String suggestion) {
    searchQuery.value = suggestion;
    showSearchSuggestions.value = false;
  }

  void clearSearch() {
    searchQuery.value = '';
    showSearchSuggestions.value = false;
  }

  void setStockFilter(StockFilter filter) {
    selectedStockFilter.value = filter;
  }

  String getStockFilterLabel(StockFilter filter) {
    switch (filter) {
      case StockFilter.all:
        return 'Tous';
      case StockFilter.outOfStock:
        return 'Épuisé ($outOfStockCount)';
      case StockFilter.critical:
        return 'Critique ($criticalStockCount)';
      case StockFilter.lowStock:
        return 'Faible ($lowStockCount)';
    }
  }

  Color getStockFilterColor(StockFilter filter) {
    switch (filter) {
      case StockFilter.all:
        return Color(0xFF6C4BFF);
      case StockFilter.outOfStock:
        return Colors.red;
      case StockFilter.critical:
        return Colors.orange;
      case StockFilter.lowStock:
        return Colors.yellow[700]!;
    }
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

      // Mettre à jour les suggestions de recherche
      _generateSearchSuggestions();
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

  Future<bool> addProduct(Product product, {File? image}) async {
    try {
      final newProduct = await _apiService.createProduct(product, image: image);
      products.add(newProduct);
      if (newProduct.isLowStock) lowStockProducts.add(newProduct);
      totalProducts.value++;
      _generateSearchSuggestions();
      return true;
    } catch (e) {
      return false;
    }
  }

  void refreshProducts() {
    currentPage.value = 1;
    hasMoreData.value = true;
    fetchProducts();
  }

  void setCategory(String? category) {
    selectedCategory.value = category;
  }
}
