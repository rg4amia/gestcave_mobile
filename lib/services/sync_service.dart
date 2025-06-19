import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  Timer? _timer;

  void start() {
    // Si déjà lancé, ne rien faire
    if (_timer != null && _timer!.isActive) return;
    // Lance la synchronisation toutes les 10 minutes
    _timer = Timer.periodic(const Duration(minutes: 10), (_) async {
      await _syncAll();
    });
    // Lancer une première fois au démarrage
    _syncAll();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _syncAll() async {
    try {
      final api = ApiService();
      // Synchronise les produits
      await api.getProducts();
      // Synchronise les catégories
      await api.getCategories();
      // Synchronise les transactions
      await api.getTransactions();
      // Tu peux ajouter d'autres synchronisations ici si besoin
      debugPrint('Synchronisation locale terminée.');
    } catch (e) {
      debugPrint('Erreur de synchronisation : $e');
    }
  }
}
