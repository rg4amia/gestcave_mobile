import 'package:get/get.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../models/paginated_response_transaction.dart';
import '../models/api_response.dart';

class TransactionController extends GetxController {
  final ApiService _apiService = ApiService();
  var transactions = <Transaction>[].obs;
  var statistics = {}.obs;
  var isLoading = false.obs;
  var filterType = 'all'.obs;
  var filterDate = Rxn<DateTime>();

  // Pagination state
  var currentPage = 1.obs;
  var totalTransactions = 0.obs;
  var lastPage = 1.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;

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

  Future<void> fetchTransactions({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreData.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
      transactions.clear();
    }
    try {
      final response = await _apiService.getTransactions(
        page: currentPage.value,
      );
      if (loadMore) {
        transactions.addAll(response.transactions);
      } else {
        transactions.value = response.transactions;
      }
      totalTransactions.value = response.total;
      lastPage.value = response.lastPage;
      hasMoreData.value = currentPage.value < response.lastPage;
      if (hasMoreData.value) {
        currentPage.value++;
      }
      statistics.value = await _apiService.getStatistics();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch transactions: $e',
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

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      final newTransaction = await _apiService.createTransaction(transaction);
      transactions.insert(0, newTransaction);
      totalTransactions.value++;
      return true;
    } catch (e) {
      print('Failed to add transaction: $e');
      return false;
    }
  }

  Future<ApiResponse<Transaction>> addTransactionWithResponse(
    Transaction transaction,
  ) async {
    final response = await _apiService.createTransactionWithResponse(
      transaction,
    );
    if (response.success && response.data != null) {
      transactions.insert(0, response.data!);
      totalTransactions.value++;
    }
    return response;
  }

  void refreshTransactions() {
    currentPage.value = 1;
    hasMoreData.value = true;
    fetchTransactions();
  }

  void loadMoreTransactions() {
    fetchTransactions(loadMore: true);
  }
}
