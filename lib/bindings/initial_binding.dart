import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/connectivity_service.dart';
import '../services/hive_cache_service.dart';
import '../services/api_service.dart';
import '../services/sync_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services de base
    Get.put<ApiService>(ApiService(), permanent: true);

    // Service de connectivité
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);

    // Services de synchronisation
    Get.put<SyncService>(SyncService(), permanent: true);
  }

  // Méthode pour initialiser les services async
  static Future<void> initializeAsyncServices() async {
    // Initialiser SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(prefs, permanent: true);

    // Service de cache Hive
    Get.put<HiveCacheService>(HiveCacheService(prefs), permanent: true);
  }
}
