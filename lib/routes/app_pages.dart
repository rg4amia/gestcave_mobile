import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/products/add_product_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/transactions/add_transaction_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/categories/add_category_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../bindings/auth_binding.dart';
import '../bindings/product_binding.dart';
import '../bindings/transaction_binding.dart';
import '../bindings/category_binding.dart';
import '../bindings/dashboard_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardScreen(),
      bindings: [
        DashboardBinding(),
        AuthBinding(),
        ProductBinding(),
        TransactionBinding(),
        CategoryBinding(),
      ],
    ),
    GetPage(
      name: Routes.PRODUCTS,
      page: () => ProductsScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.ADD_PRODUCT,
      page: () => AddProductScreen(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.TRANSACTIONS,
      page: () => TransactionsScreen(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: Routes.ADD_TRANSACTION,
      page: () => AddTransactionScreen(),
      binding: TransactionBinding(),
    ),
    GetPage(
      name: Routes.CATEGORIES,
      page: () => CategoriesScreen(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.ADD_CATEGORY,
      page: () => AddCategoryScreen(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.REPORTS,
      page: () => ReportsScreen(),
      binding: AuthBinding(),
    ),
  ];
}
