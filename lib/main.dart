import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'config/theme.dart';
import 'routes/app_pages.dart';
import 'bindings/initial_binding.dart';
import 'services/sync_service.dart';
import 'services/background_sync.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lancer la synchro foreground (app ouverte)
  SyncService().start();

  // Initialiser Workmanager pour la synchro background
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // Passe à true pour debug
  );
  await Workmanager().registerPeriodicTask(
    'syncTaskUniqueName',
    syncTaskName,
    frequency: const Duration(minutes: 15), // 15 min est le minimum sur Android
    initialDelay: const Duration(minutes: 1),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  final _storage = FlutterSecureStorage();
  final token = await _storage.read(key: 'token');

  runApp(MyApp(initialRoute: token != null ? Routes.DASHBOARD : Routes.LOGIN));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Beverage Inventory',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
    );
  }
}

// Extension for String capitalization
extension StringExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}
