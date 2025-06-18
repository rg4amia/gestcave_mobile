import 'package:get/get.dart';
import '../models/category.dart';
import '../services/api_service.dart';

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
      Get.snackbar('Error', 'Failed to fetch categories: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      print('category : $category');
      final newCategory = await _apiService.createCategory(category);
      categories.add(newCategory);
      Get.snackbar('Success', 'Category added successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
