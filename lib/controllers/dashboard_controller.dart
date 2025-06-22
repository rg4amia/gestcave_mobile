import 'package:get/get.dart';
import '../models/dashboard.dart';
import '../services/api_service.dart';

class DashboardController extends GetxController {
  late final ApiService _apiService;
  final Rx<DashboardData?> dashboardData = Rx<DashboardData?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      error.value = '';
      final data = await _apiService.getDashboardData();
      dashboardData.value = data;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
