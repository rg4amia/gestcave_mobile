import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBar(
      selectedIndex: _getSelectedIndex(Get.currentRoute),
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
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Products',
        ),
        NavigationDestination(
          icon: Icon(Icons.swap_horiz_outlined),
          selectedIcon: Icon(Icons.swap_horiz),
          label: 'Transactions',
        ),
        NavigationDestination(
          icon: Icon(Icons.category_outlined),
          selectedIcon: Icon(Icons.category),
          label: 'Categories',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Reports',
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
