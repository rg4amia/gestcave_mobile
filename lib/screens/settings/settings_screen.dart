import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'user_profile_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6C4BFF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Section Informations du compte
            _buildSection(
              title: 'Informations du compte',
              icon: Icons.person_outline,
              color: primaryColor,
              children: [
                _buildSettingsItem(
                  icon: Icons.person,
                  title: 'Profil utilisateur',
                  subtitle: const Text('Voir et modifier vos informations'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: Obx(
                    () => Text(
                      Get.find<AuthController>().user.value?.email ??
                          'Non défini',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  onTap: null, // Non cliquable
                ),
                _buildSettingsItem(
                  icon: Icons.badge_outlined,
                  title: 'Nom',
                  subtitle: Obx(
                    () => Text(
                      Get.find<AuthController>().user.value?.name ??
                          'Non défini',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  onTap: null, // Non cliquable
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Sécurité
            _buildSection(
              title: 'Sécurité',
              icon: Icons.security_outlined,
              color: Colors.orange,
              children: [
                _buildSettingsItem(
                  icon: Icons.lock_outline,
                  title: 'Modifier mot de passe',
                  subtitle: const Text('Changer votre mot de passe'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Légal
            _buildSection(
              title: 'Légal',
              icon: Icons.description_outlined,
              color: Colors.green,
              children: [
                _buildSettingsItem(
                  icon: Icons.gavel_outlined,
                  title: 'Termes et conditions',
                  subtitle: const Text('Lire les termes d\'utilisation'),
                  onTap: () {
                    // TODO: Implémenter l'affichage des termes et conditions
                    Get.snackbar(
                      'Info',
                      'Fonctionnalité à venir',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Politique de confidentialité',
                  subtitle: const Text(
                    'Lire notre politique de confidentialité',
                  ),
                  onTap: () {
                    // TODO: Implémenter l'affichage de la politique de confidentialité
                    Get.snackbar(
                      'Info',
                      'Fonctionnalité à venir',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Déconnexion
            _buildSection(
              title: 'Compte',
              icon: Icons.account_circle_outlined,
              color: Colors.red,
              children: [
                _buildSettingsItem(
                  icon: Icons.logout,
                  title: 'Déconnexion',
                  subtitle: const Text('Se déconnecter de l\'application'),
                  onTap: () => _showLogoutDialog(context),
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Widget subtitle,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: onTap != null ? Colors.grey[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle,
        trailing: onTap != null
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: isDestructive ? Colors.red : Colors.grey[600],
                  size: 18,
                ),
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Déconnexion',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Êtes-vous sûr de vouloir vous déconnecter ? '
            'Toutes les données locales seront supprimées.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.red[700]!],
                ),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  // Afficher un indicateur de chargement
                  Get.dialog(
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF6C4BFF)),
                            const SizedBox(height: 16),
                            Text(
                              'Déconnexion en cours...',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                  );

                  try {
                    await Get.find<AuthController>().logout();
                  } catch (e) {
                    Get.back(); // Fermer l'indicateur de chargement
                    Get.snackbar(
                      'Erreur',
                      'Erreur lors de la déconnexion: $e',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Déconnexion',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
