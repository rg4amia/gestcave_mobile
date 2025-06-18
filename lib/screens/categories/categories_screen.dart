import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../routes/app_pages.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.ADD_CATEGORY),
          ),
        ],
      ),
      drawer: isTablet ? null : AppDrawer(),
      body: Row(
        children: [
          if (isTablet) AppDrawer(),
          Expanded(
            child: Obx(() {
              if (categoryController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (categoryController.categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Color(0xFF6C63FF).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No categories found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6C63FF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed(Routes.ADD_CATEGORY),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: categoryController.categories.length,
                itemBuilder: (context, index) {
                  final category = categoryController.categories[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category,
                          color: Color(0xFF6C63FF),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        category.description ?? 'No description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${category.totalProducts ?? 0} produits',
                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () {
                        // TODO: Navigate to Category Details
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: isTablet ? null : AppBottomNavBar(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6C63FF).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.ADD_CATEGORY),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}
