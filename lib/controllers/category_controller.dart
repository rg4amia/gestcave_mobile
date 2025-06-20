import 'package:get/get.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../models/api_response.dart';

class CategoryController extends GetxController {
  final ApiService _apiService = ApiService();
  var categories = <Category>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getCategories();
      categories.value = response.categories;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch categories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<Category>> addCategoryWithResponse(
    Category category,
  ) async {
    final response = await _apiService.createCategoryWithResponse(category);
    if (response.success && response.data != null) {
      categories.add(response.data!);
    }
    return response;
  }
}
