import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/dashboard_controller.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'package:intl/intl.dart';
import '../products/products_screen.dart';
import '../transactions/transactions_screen.dart';
import '../categories/categories_screen.dart';
import '../reports/reports_screen.dart';
import '../../routes/app_pages.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardMainView(),
    ProductsScreen(),
    TransactionsScreen(),
    CategoriesScreen(),
    ReportsScreen(),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
      print('index: $_selectedIndex');
    });
  }

  AppBar _appBar(int index) {
    switch (index) {
      case 0:
        return AppBar(
          title: Text('Dashbord'),
          backgroundColor: Color(0xFF6C4BFF),
          foregroundColor: Colors.white,
          elevation: 0,
        );
      case 1:
        return AppBar(
          title: Text('Produits'),
          backgroundColor: Color(0xFF6C4BFF),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
            ),
          ],
        );
      case 2:
        return AppBar(
          title: Text('Transactions'),
          backgroundColor: Color(0xFF6C4BFF),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed(Routes.ADD_TRANSACTION),
            ),
          ],
        );
      case 3:
        return AppBar(
          title: Text('Catégories'),
          backgroundColor: Color(0xFF6C4BFF),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.toNamed(Routes.ADD_CATEGORY),
            ),
          ],
        );
      case 4:
        return AppBar(
          title: Text('Rapports'),
          backgroundColor: Color(0xFF6C4BFF),
          foregroundColor: Colors.white,
          elevation: 0,
        );
      default:
        return AppBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(_selectedIndex),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}

class DashboardMainView extends StatelessWidget {
  const DashboardMainView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final currencyFormat = NumberFormat.currency(symbol: 'F');

    return RefreshIndicator(
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
                padding: const EdgeInsets.all(12.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 2),
                    _buildSummaryCard(
                      context,
                      'Nombre total de produits',
                      Text(
                        data.totalProducts.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Icons.inventory_2,
                      () {},
                      subtitle: Row(
                        children: [
                          Icon(
                            Icons.currency_franc_rounded,
                            size: 16,
                            color: Colors.black,
                          ),
                          SizedBox(width: 4),
                          Text(
                            currencyFormat
                                .format(data.totalValue)
                                .replaceAll('F', ''),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryCard(
                      context,
                      'Alertes de stock',
                      Text(
                        data.stockAlerts.total.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Icons.warning_amber_rounded,
                      () {},
                      subtitle: Text(
                        'Critique : ${data.stockAlerts.critical}, Alerte : ${data.stockAlerts.warning}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      color: data.stockAlerts.total > 0 ? Colors.red : null,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryCard(
                      context,
                      'Ventes mensuelles',
                      Row(
                        children: [
                          Icon(
                            Icons.currency_franc_rounded,
                            size: 16,
                            color: Color(0xFF4CAF50),
                          ),
                          SizedBox(width: 4),
                          Text(
                            currencyFormat
                                .format(data.financialStats.monthlySales)
                                .replaceAll('F', ''),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      Icons.trending_up,
                      () {},
                      subtitle: Row(
                        children: [
                          Icon(
                            Icons.currency_franc_rounded,
                            size: 16,
                            color: Colors.black,
                          ),
                          SizedBox(width: 4),
                          Text(
                            currencyFormat
                                .format(data.financialStats.monthlyProfit)
                                .replaceAll('F', ''),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dernières transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final transaction = data.recentTransactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: transaction.type == 'in'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            transaction.type == 'in'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: transaction.type == 'in'
                                ? Colors.green[500]
                                : Colors.red,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          transaction.product?.name ?? 'Produit inconnu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          '${transaction.quantity} unités - ${DateFormat('dd/MM/yyyy HH:mm', 'fr_FR').format(transaction.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        trailing: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: transaction.type == 'in'
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '${transaction.type == 'in' ? '+' : '-'}${transaction.quantity}',
                            style: TextStyle(
                              color: transaction.type == 'in'
                                  ? Colors.green[500]
                                  : Colors.red,
                              fontSize: 12,
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
                padding: const EdgeInsets.all(12.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Meilleurs produits',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...data.topProducts.map(
                      (product) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          title: Text(
                            product.product.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            'Quantité totale : ${product.totalQuantity}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          trailing: product.totalSales != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.currency_franc_rounded,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      currencyFormat
                                          .format(product.totalSales)
                                          .replaceAll('F', ''),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 14,
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
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    Widget value,
    IconData icon,
    VoidCallback onTap, {
    Widget? subtitle,
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
                      value,
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        subtitle,
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
