import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../routes/app_pages.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.find<TransactionController>();
    final isTablet = MediaQuery.of(context).size.width > 600;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Color(0xFF6C4BFF),
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.ADD_TRANSACTION),
          ),
        ],
      ),
      drawer: isTablet ? null : AppDrawer(),
      body: Row(
        children: [
          if (isTablet) AppDrawer(),
          Expanded(
            child: Obx(() {
              if (transactionController.isLoading.value) {
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
                          onPressed: () => Get.toNamed(Routes.ADD_TRANSACTION),
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

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: transactionController.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactionController.transactions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: transaction.type == 'in'
                              ? colorScheme.primaryContainer
                              : colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          transaction.type == 'in'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: transaction.type == 'in'
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
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
                            '${transaction.type == 'in' ? '+' : '-'}${transaction.quantity}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: transaction.type == 'in'
                                      ? colorScheme.primary
                                      : colorScheme.error,
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
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: isTablet ? null : AppBottomNavBar(),
      floatingActionButton: Container(
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
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.ADD_TRANSACTION),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}
