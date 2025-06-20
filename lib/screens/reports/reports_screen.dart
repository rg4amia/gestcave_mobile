import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/product_controller.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionController = Get.find<TransactionController>();
    final productController = Get.find<ProductController>();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        'Reports',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSummaryCards(context, transactionController),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    TransactionController controller,
  ) {
    return Obx(() {
      final transactions = controller.transactions;
      final totalSales = transactions
          .where((t) => t.type == 'out')
          .fold(0.0, (sum, t) => sum + t.totalPrice);
      final totalPurchases = transactions
          .where((t) => t.type == 'in')
          .fold(0.0, (sum, t) => sum + t.totalPrice);
      final totalProfit = transactions
          .where((t) => t.type == 'out')
          .fold(0.0, (sum, t) => sum + t.profit);

      return Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'Total Sales',
              '\$${totalSales.toStringAsFixed(2)}',
              Icons.trending_up,
              Color(0xFF6C4BFF),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Total Purchases',
              '\$${totalPurchases.toStringAsFixed(2)}',
              Icons.trending_down,
              Color(0xFF5A52E0),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Total Profit',
              '\$${totalProfit.toStringAsFixed(2)}',
              Icons.attach_money,
              Color(0xFF4B46C2),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
