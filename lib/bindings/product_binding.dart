import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}
