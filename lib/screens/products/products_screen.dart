import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
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
    Future<void> _navigateToAddProduct(BuildContext context) async {
      final result = await Get.toNamed(Routes.ADD_PRODUCT);
      if (result == true) {
        Get.snackbar(
          'Succès',
          'Produit ajouté avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      productController.refreshProducts();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Champ de recherche
                Stack(
                  children: [
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un produit ou catégorie...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF6C4BFF),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  productController.clearSearch();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Color(0xFF6C4BFF),
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
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
                        top: 44,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.search,
                                  color: Color(0xFF6C4BFF),
                                  size: 18,
                                ),
                                title: Text(
                                  suggestions[index],
                                  style: TextStyle(fontSize: 14),
                                ),
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
                SizedBox(height: 8),
                // Filtres de stock + catégorie sur la même ligne
                Obx(() {
                  final categories = productController.categories;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Dropdown catégorie stylisé
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 0,
                          ),
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(18),
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
                                    size: 18,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'Catégorie',
                                    style: TextStyle(
                                      color: Color(0xFF6C4BFF),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF6C4BFF),
                                size: 18,
                              ),
                              style: TextStyle(
                                color: Color(0xFF6C4BFF),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              dropdownColor: Colors.white,
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(
                                    'Toutes',
                                    style: TextStyle(
                                      color: Color(0xFF6C4BFF),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                ...categories.map(
                                  (cat) => DropdownMenuItem<String>(
                                    value: cat,
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: Color(0xFF6C4BFF),
                                        fontSize: 13,
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
                            margin: EdgeInsets.only(right: 4),
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
                                  fontSize: 13,
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
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
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
                            : 'Aucun produit trouvé',
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
                            onPressed: () => _navigateToAddProduct(context),
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
                  physics: const AlwaysScrollableScrollPhysics(),
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
                              'Aucun produit trouvé',
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
                                            width: 64,
                                            height: 64,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.broken_image,
                                                      color: Color(0xFF6C4BFF),
                                                      size: 32,
                                                    ),
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child: SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                        : null,
                                                    color: Color(0xFF6C4BFF),
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              );
                                            },
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
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.currency_franc_rounded,
                                        size: 16,
                                        color: Color(0xFF6C4BFF),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        product.price.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: Color(0xFF6C4BFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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
    );
  }
}
