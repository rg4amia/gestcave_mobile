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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      productController.updateSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
        title: Obx(
          () => Text('Products (${productController.filteredProducts.length})'),
        ),
        backgroundColor: Color(0xFF6C4BFF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Champ de recherche
                Stack(
                  children: [
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Rechercher un produit ou catégorie...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF6C4BFF),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  productController.clearSearch();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF6C4BFF),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    // Suggestions de recherche
                    Obx(() {
                      if (!productController.showSearchSuggestions.value) {
                        return SizedBox.shrink();
                      }

                      final suggestions = productController.searchSuggestions
                          .where(
                            (suggestion) => suggestion.toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            ),
                          )
                          .take(5)
                          .toList();

                      if (suggestions.isEmpty) {
                        return SizedBox.shrink();
                      }

                      return Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Icon(
                                  Icons.search,
                                  color: Color(0xFF6C4BFF),
                                  size: 20,
                                ),
                                title: Text(suggestions[index]),
                                onTap: () {
                                  productController.selectSearchSuggestion(
                                    suggestions[index],
                                  );
                                  _searchController.text = suggestions[index];
                                  _searchFocusNode.unfocus();
                                },
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                SizedBox(height: 12),
                // Filtres de stock + catégorie sur la même ligne
                Obx(() {
                  final categories = productController.categories;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Dropdown catégorie stylisé
                        Container(
                          margin: EdgeInsets.only(right: 12),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Color(0xFF6C4BFF),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: productController.selectedCategory.value,
                              hint: Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    color: Color(0xFF6C4BFF),
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Catégorie',
                                    style: TextStyle(
                                      color: Color(0xFF6C4BFF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF6C4BFF),
                              ),
                              style: TextStyle(
                                color: Color(0xFF6C4BFF),
                                fontWeight: FontWeight.w500,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              dropdownColor: Colors.white,
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(
                                    'Toutes',
                                    style: TextStyle(color: Color(0xFF6C4BFF)),
                                  ),
                                ),
                                ...categories.map(
                                  (cat) => DropdownMenuItem<String>(
                                    value: cat,
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: Color(0xFF6C4BFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                productController.setCategory(value);
                              },
                            ),
                          ),
                        ),
                        // Filtres d'alerte (FilterChips)
                        for (final filter in [
                          StockFilter.all,
                          StockFilter.outOfStock,
                          StockFilter.critical,
                          StockFilter.lowStock,
                        ])
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                productController.getStockFilterLabel(filter),
                                style: TextStyle(
                                  color:
                                      productController
                                              .selectedStockFilter
                                              .value ==
                                          filter
                                      ? Colors.white
                                      : productController.getStockFilterColor(
                                          filter,
                                        ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected:
                                  productController.selectedStockFilter.value ==
                                  filter,
                              selectedColor: productController
                                  .getStockFilterColor(filter),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: productController.getStockFilterColor(
                                  filter,
                                ),
                                width: 1,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  productController.setStockFilter(filter);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          // Liste des produits
          Expanded(
            child: Obx(() {
              if (productController.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C4BFF)),
                );
              }

              if (productController.filteredProducts.isEmpty) {
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
                        productController.searchQuery.isNotEmpty ||
                                productController.selectedStockFilter.value !=
                                    StockFilter.all
                            ? 'Aucun produit trouvé'
                            : 'Aucun Produit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (productController.searchQuery.isNotEmpty ||
                          productController.selectedStockFilter.value !=
                              StockFilter.all) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Essayez de modifier vos critères de recherche',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            productController.clearSearch();
                            productController.setStockFilter(StockFilter.all);
                            _searchController.clear();
                          },
                          child: Text('Effacer les filtres'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6C4BFF),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ] else ...[
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
                  itemCount: productController.filteredProducts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == productController.filteredProducts.length) {
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

                    final product = productController.filteredProducts[index];
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
