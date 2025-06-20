import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.find<TransactionController>();
    final isTablet = MediaQuery.of(context).size.width > 600;
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> _navigateToAddTransaction(BuildContext context) async {
      final result = await Get.toNamed('/add-transaction');
      if (result == true) {
        Get.snackbar(
          'Succès',
          'Transaction ajoutée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        transactionController.refreshTransactions();
      }
    }

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Obx(() {
              if (transactionController.isLoading.value &&
                  transactionController.transactions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (transactionController.transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Color(0xFF6C4BFF).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune transaction',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6C4BFF), Color(0xFF5A52E0)],
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6C4BFF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToAddTransaction(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter Transaction'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Colors.white,
                onRefresh: () async {
                  transactionController.refreshTransactions();
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!transactionController.isLoadingMore.value &&
                        transactionController.hasMoreData.value &&
                        scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200) {
                      transactionController.loadMoreTransactions();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount:
                        transactionController.transactions.length +
                        (transactionController.hasMoreData.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == transactionController.transactions.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final transaction =
                          transactionController.transactions[index];
                      final isIn = transaction.type == 'in';
                      return Card(
                        color: isIn ? Colors.green[50] : Colors.red[50],
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    transaction.product?.imagePath != null &&
                                        transaction
                                            .product!
                                            .imagePath!
                                            .isNotEmpty
                                    ? Image.network(
                                        transaction.product!.imagePath!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  'assets/images/logo.png',
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                      )
                                    : Image.asset(
                                        'assets/images/logo.png',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isIn
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isIn
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isIn ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            transaction.product?.name ?? 'Unknown Product',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${transaction.quantity} units - ${transaction.createdAt.toString().split('.')[0]}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (transaction.notes != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  transaction.notes!,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${transaction.totalPrice.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${isIn ? '+' : '-'}${transaction.quantity}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isIn ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Navigate to Transaction Details
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
