import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put(ApiService(), permanent: true);
    Get.put(DatabaseService(), permanent: true);
  }
}
