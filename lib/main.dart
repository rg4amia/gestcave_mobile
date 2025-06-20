import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'config/theme.dart';
import 'routes/app_pages.dart';
import 'bindings/initial_binding.dart';
import 'services/sync_service.dart';
import 'services/background_sync.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for French locale
  await initializeDateFormatting('fr_FR');

  // Charger les variables d'environnement
  await dotenv.load(fileName: ".env");

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

  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');

  runApp(MyApp(initialRoute: token != null ? Routes.DASHBOARD : Routes.LOGIN));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GestCave',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
        child: child!,
      ),
      initialBinding: InitialBinding(),
    );
  }
}

// Extension for String capitalization
extension StringExtension on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}
