import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF6C4BFF);
    const unselectedColor = Color(0xFF8B8B8B); // Gris doux pour non sélectionné
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = _getSelectedIndex(Get.currentRoute);

    return Drawer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 16, 20),
            child: Text(
              'Beverage Inventory',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: selectedColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Obx(
              () => Text(
                Get.find<AuthController>().user.value?.name ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: unselectedColor),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _DrawerItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: () {
              Get.toNamed('/dashboard');
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.inventory_2_outlined,
            selectedIcon: Icons.inventory_2,
            label: 'Products',
            selected: selectedIndex == 1,
            onTap: () {
              Get.toNamed('/products');
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.swap_horiz_outlined,
            selectedIcon: Icons.swap_horiz,
            label: 'Transactions',
            selected: selectedIndex == 2,
            onTap: () {
              Get.toNamed('/transactions');
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.category_outlined,
            selectedIcon: Icons.category,
            label: 'Categories',
            selected: selectedIndex == 3,
            onTap: () {
              Get.toNamed('/categories');
              Get.back();
            },
          ),
          _DrawerItem(
            icon: Icons.analytics_outlined,
            selectedIcon: Icons.analytics,
            label: 'Reports',
            selected: selectedIndex == 4,
            onTap: () {
              Get.toNamed('/reports');
              Get.back();
            },
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
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            ),
          ),
        ],
      ),
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF6C4BFF);
    const unselectedColor = Color(0xFF8B8B8B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? selectedColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 5,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? selectedColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              selected ? selectedIcon : icon,
              color: selected ? selectedColor : unselectedColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: selected ? selectedColor : unselectedColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
