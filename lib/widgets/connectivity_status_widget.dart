import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/connectivity_service.dart';

class ConnectivityStatusWidget extends StatelessWidget {
  const ConnectivityStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Obx(() {
      final isConnected = connectivityService.isConnected;

      if (isConnected) {
        return const SizedBox.shrink(); // Masquer si connecté
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.orange.shade100,
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange.shade800, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Mode hors ligne - Données en cache',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ConnectivityStatusWidget(),
        Expanded(child: child),
      ],
    );
  }
}
