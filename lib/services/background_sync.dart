import 'package:workmanager/workmanager.dart';
import 'api_service.dart';

const String syncTaskName = 'backgroundSyncTask';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final api = ApiService();
    try {
      await api.getProducts();
      await api.getCategories();
      await api.getTransactions();
      // Tu peux ajouter d'autres synchronisations ici
      // Retourne true si tout s'est bien passé
      return Future.value(true);
    } catch (e) {
      // Retourne false en cas d'erreur
      return Future.value(false);
    }
  });
}
