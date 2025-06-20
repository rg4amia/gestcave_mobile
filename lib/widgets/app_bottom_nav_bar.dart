import 'package:flutter/material.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static int getSelectedIndex(String route) {
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

  @override
  Widget build(BuildContext context) {
    return TitledBottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        TitledNavigationBarItem(
          title: Text('Dashboard'),
          leading: Icon(Icons.dashboard_outlined),
        ),
        TitledNavigationBarItem(
          title: Text('Products'),
          leading: Icon(Icons.inventory_2_outlined),
        ),
        TitledNavigationBarItem(
          title: Text('Transactions'),
          leading: Icon(Icons.swap_horiz_outlined),
        ),
        TitledNavigationBarItem(
          title: Text('Categories'),
          leading: Icon(Icons.category_outlined),
        )
       /*  TitledNavigationBarItem(
          title: Text('Reports'),
          leading: Icon(Icons.analytics_outlined),
        ), */
      ],
    );
  }
}
