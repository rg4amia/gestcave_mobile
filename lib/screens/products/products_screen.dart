import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../routes/app_pages.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final productController = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      productController.fetchProducts(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Text('Products (${productController.totalProducts})')),
        backgroundColor: Color(0xFF6C4BFF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/add_product'),
          ),
        ],
      ),
      drawer: isTablet ? null : AppDrawer(),
      body: Row(
        children: [
          if (isTablet) AppDrawer(),
          Expanded(
            child: Obx(() {
              if (productController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C4BFF)),
                );
              }

              if (productController.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Color(0xFF6C4BFF).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun Produit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6C4BFF), Color(0xFF5A52E0)],
                          ),
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6C4BFF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter Produits'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: Color(0xFF6C4BFF),
                onRefresh: () async {
                  productController.refreshProducts();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24.0),
                  itemCount: productController.products.length + 1,
                  itemBuilder: (context, index) {
                    if (index == productController.products.length) {
                      if (productController.isLoadingMore.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF6C4BFF),
                            ),
                          ),
                        );
                      }
                      if (!productController.hasMoreData.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No more products',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final product = productController.products[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // TODO: Navigate to Product Details
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF6C4BFF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: product.imagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            product.imagePath!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.inventory_2,
                                          color: Color(0xFF6C4BFF),
                                          size: 32,
                                        ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        product.category?.name ?? 'No Category',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: product.isLowStock
                                              ? Colors.red[50]
                                              : Color(
                                                  0xFF6C4BFF,
                                                ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.inventory_2,
                                              size: 14,
                                              color: product.isLowStock
                                                  ? Colors.red
                                                  : Color(0xFF6C4BFF),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Stock: ${product.stockQuantity} (Min: ${product.minimumStock})',
                                              style: TextStyle(
                                                color: product.isLowStock
                                                    ? Colors.red
                                                    : Color(0xFF6C4BFF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF6C4BFF).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    '${product.price.toStringAsFixed(2)} F',
                                    style: TextStyle(
                                      color: Color(0xFF6C4BFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: isTablet ? null : AppBottomNavBar(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C4BFF), Color(0xFF5A52E0)],
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF6C4BFF).withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}
