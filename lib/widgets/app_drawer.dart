import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationDrawer(
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            Get.toNamed('/dashboard');
            break;
          case 1:
            Get.toNamed('/products');
            break;
          case 2:
            Get.toNamed('/transactions');
            break;
          case 3:
            Get.toNamed('/categories');
            break;
          case 4:
            Get.toNamed('/reports');
            break;
        }
        Get.back();
      },
      selectedIndex: _getSelectedIndex(Get.currentRoute),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 20),
          child: Text(
            'Beverage Inventory',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Obx(() => Text(
                Get.find<AuthController>().user.value?.name ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              )),
        ),
        const SizedBox(height: 8),
        NavigationDrawerDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: const Text('Dashboard'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.inventory_2_outlined),
          selectedIcon: const Icon(Icons.inventory_2),
          label: const Text('Products'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.swap_horiz_outlined),
          selectedIcon: const Icon(Icons.swap_horiz),
          label: const Text('Transactions'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.category_outlined),
          selectedIcon: const Icon(Icons.category),
          label: const Text('Categories'),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.analytics_outlined),
          selectedIcon: const Icon(Icons.analytics),
          label: const Text('Reports'),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 16, 28, 16),
          child: Divider(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextButton.icon(
            onPressed: () async {
              await Get.find<AuthController>().logout();
              Get.offAllNamed('/');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  int _getSelectedIndex(String route) {
    switch (route) {
      case '/dashboard':
        return 0;
      case '/products':
        return 1;
      case '/transactions':
        return 2;
      case '/categories':
        return 3;
      case '/reports':
        return 4;
      default:
        return 0;
    }
  }
}
