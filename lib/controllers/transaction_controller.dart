import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionController extends GetxController {
  final ApiService _apiService = ApiService();
  var transactions = <Transaction>[].obs;
  var statistics = {}.obs;
  var isLoading = false.obs;
  var filterType = 'all'.obs;
  var filterDate = Rxn<DateTime>();

  List<Transaction> get filteredTransactions {
    var filtered = transactions;
    if (filterType.value != 'all') {
      filtered = filtered.where((t) => t.type == filterType.value).toList().obs;
    }
    if (filterDate.value != null) {
      filtered = filtered
          .where((t) => t.createdAt.day == filterDate.value!.day)
          .toList()
          .obs;
    }
    return filtered;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      transactions.value = await _apiService.getTransactions();
      statistics.value = await _apiService.getStatistics();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch transactions: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final newTransaction = await _apiService.createTransaction(transaction);
      transactions.add(newTransaction);
      Get.snackbar('Success', 'Transaction added successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add transaction: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
