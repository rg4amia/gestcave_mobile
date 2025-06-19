import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final currencyFormat = NumberFormat.currency(symbol: 'F');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: Color(0xFF6C4BFF),
        onRefresh: () => dashboardController.fetchDashboardData(),
        child: Obx(() {
          if (dashboardController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardController.error.isNotEmpty) {
            return Center(
              child: Text(
                dashboardController.error.value,
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final data = dashboardController.dashboardData.value;
          if (data == null) {
            return const Center(child: Text('No data available'));
          }

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 5),
                      _buildSummaryCard(
                        context,
                        'Nombre total de produit',
                        data.totalProducts.toString(),
                        Icons.inventory_2,
                        () => Get.toNamed('/products'),
                        subtitle:
                            'Totale: ${currencyFormat.format(data.totalValue)}',
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        context,
                        'Stock Alerts',
                        data.stockAlerts.total.toString(),
                        Icons.warning_amber_rounded,
                        () {},
                        subtitle:
                            'Critical: ${data.stockAlerts.critical}, Warning: ${data.stockAlerts.warning}',
                        color: data.stockAlerts.total > 0 ? Colors.red : null,
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(
                        context,
                        'Monthly Sales',
                        currencyFormat.format(data.financialStats.monthlySales),
                        Icons.trending_up,
                        () => Get.toNamed('/reports'),
                        subtitle:
                            'Profit: ${currencyFormat.format(data.financialStats.monthlyProfit)}',
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final transaction = data.recentTransactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: transaction.type == 'in'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              transaction.type == 'in'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: transaction.type == 'in'
                                  ? Colors.green[500]
                                  : Colors.red,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            transaction.product?.name ?? 'Unknown Product',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            '${transaction.quantity} units - ${DateFormat('yyyy-MM-dd HH:mm').format(transaction.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: transaction.type == 'in'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${transaction.type == 'in' ? '+' : '-'}${transaction.quantity}',
                              style: TextStyle(
                                color: transaction.type == 'in'
                                    ? Colors.green[500]
                                    : Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: data.recentTransactions.length),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(24.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Text(
                        'Top Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...data.topProducts.map(
                        (product) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              product.product.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Total Quantity: ${product.totalQuantity}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            trailing: Text(
                              product.totalSales != null
                                  ? currencyFormat.format(product.totalSales)
                                  : '-',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: AppBottomNavBar(),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap, {
    String? subtitle,
    Color? color,
  }) {
    final iconColor = color ?? Color(0xFF6C4BFF);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
