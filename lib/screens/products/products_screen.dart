import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../controllers/product_controller.dart';
import '../../routes/app_pages.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with TickerProviderStateMixin {
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
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }

      productController.refreshProducts();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // Barre de recherche et filtres avec design moderne
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Champ de recherche moderne
                Stack(
                  children: [
                    Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C4BFF).withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Rechercher un produit ou catégorie...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6C4BFF,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.search,
                                  color: const Color(0xFF6C4BFF),
                                  size: 20,
                                ),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? Container(
                                      margin: const EdgeInsets.all(8),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          onTap: () {
                                            _searchController.clear();
                                            productController.clearSearch();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.clear,
                                              color: Colors.grey[600],
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6C4BFF),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fade(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),

                    // Suggestions de recherche
                    Obx(() {
                      if (!productController.showSearchSuggestions.value) {
                        return const SizedBox.shrink();
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
                        return const SizedBox.shrink();
                      }

                      return Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child:
                            Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: suggestions.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        dense: true,
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF6C4BFF,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.search,
                                            color: const Color(0xFF6C4BFF),
                                            size: 16,
                                          ),
                                        ),
                                        title: Text(
                                          suggestions[index],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        onTap: () {
                                          productController
                                              .selectSearchSuggestion(
                                                suggestions[index],
                                              );
                                          _searchController.text =
                                              suggestions[index];
                                          _searchFocusNode.unfocus();
                                        },
                                      );
                                    },
                                  ),
                                )
                                .animate()
                                .fade(duration: 300.ms)
                                .slideY(begin: -0.1, end: 0),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),

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
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 0,
                              ),
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF6C4BFF).withOpacity(0.1),
                                    const Color(0xFF5A52E0).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF6C4BFF),
                                  width: 1.5,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value:
                                      productController.selectedCategory.value,
                                  hint: Row(
                                    children: [
                                      Icon(
                                        Icons.category,
                                        color: const Color(0xFF6C4BFF),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Catégorie',
                                        style: TextStyle(
                                          color: const Color(0xFF6C4BFF),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: const Color(0xFF6C4BFF),
                                    size: 20,
                                  ),
                                  style: TextStyle(
                                    color: const Color(0xFF6C4BFF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: Colors.white,
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(
                                        'Toutes',
                                        style: TextStyle(
                                          color: const Color(0xFF6C4BFF),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    ...categories.map(
                                      (cat) => DropdownMenuItem<String>(
                                        value: cat,
                                        child: Text(
                                          cat,
                                          style: TextStyle(
                                            color: const Color(0xFF6C4BFF),
                                            fontSize: 14,
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
                                margin: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(
                                    productController.getStockFilterLabel(
                                      filter,
                                    ),
                                    style: TextStyle(
                                      color:
                                          productController
                                                  .selectedStockFilter
                                                  .value ==
                                              filter
                                          ? Colors.white
                                          : productController
                                                .getStockFilterColor(filter),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  selected:
                                      productController
                                          .selectedStockFilter
                                          .value ==
                                      filter,
                                  selectedColor: productController
                                      .getStockFilterColor(filter),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: productController
                                        .getStockFilterColor(filter),
                                    width: 1.5,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
                    })
                    .animate()
                    .fade(delay: 200.ms, duration: 600.ms)
                    .slideX(begin: 0.2, end: 0),
              ],
            ),
          ),

          // Liste des produits
          Expanded(
            child: Obx(() {
              if (productController.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          color: const Color(0xFF6C4BFF),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chargement des produits...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              if (productController.filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: const Color(0xFF6C4BFF).withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        productController.searchQuery.isNotEmpty ||
                                productController.selectedStockFilter.value !=
                                    StockFilter.all
                            ? 'Aucun produit trouvé'
                            : 'Aucun produit trouvé',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      if (productController.searchQuery.isNotEmpty ||
                          productController.selectedStockFilter.value !=
                              StockFilter.all) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Essayez de modifier vos critères de recherche',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            productController.clearSearch();
                            productController.setStockFilter(StockFilter.all);
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Effacer les filtres'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C4BFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 12),
                        Text(
                          'Commencez par ajouter votre premier produit',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6C4BFF),
                                const Color(0xFF5A52E0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C4BFF).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ).animate().fade(duration: 600.ms).scale(delay: 200.ms),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF6C4BFF),
                onRefresh: () async {
                  productController.refreshProducts();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
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
                            padding: const EdgeInsets.all(16.0),
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
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                // TODO: Navigate to Product Details
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    // Image du produit avec animation
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF6C4BFF,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF6C4BFF,
                                            ).withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: product.imagePath != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                product.imagePath!,
                                                fit: BoxFit.cover,
                                                width: 80,
                                                height: 80,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Icon(
                                                        Icons.broken_image,
                                                        color: const Color(
                                                          0xFF6C4BFF,
                                                        ),
                                                        size: 32,
                                                      );
                                                    },
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
                                                        color: const Color(
                                                          0xFF6C4BFF,
                                                        ),
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Icon(
                                              Icons.inventory_2,
                                              color: const Color(0xFF6C4BFF),
                                              size: 32,
                                            ),
                                    ),
                                    const SizedBox(width: 20),

                                    // Informations du produit
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF6C4BFF,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              product.category?.name ??
                                                  'Aucune catégorie',
                                              style: TextStyle(
                                                color: const Color(0xFF6C4BFF),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: product.isLowStock
                                                  ? Colors.red[50]
                                                  : const Color(
                                                      0xFF6C4BFF,
                                                    ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: product.isLowStock
                                                    ? Colors.red.withOpacity(
                                                        0.3,
                                                      )
                                                    : const Color(
                                                        0xFF6C4BFF,
                                                      ).withOpacity(0.3),
                                                width: 1,
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
                                                      : const Color(0xFF6C4BFF),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Stock: ${product.stockQuantity} (Min: ${product.minimumStock})',
                                                  style: TextStyle(
                                                    color: product.isLowStock
                                                        ? Colors.red
                                                        : const Color(
                                                            0xFF6C4BFF,
                                                          ),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Prix avec design moderne
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF6C4BFF),
                                            const Color(0xFF5A52E0),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF6C4BFF,
                                            ).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.currency_franc_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            product.price.toStringAsFixed(2),
                                            style: const TextStyle(
                                              color: Colors.white,
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
                        )
                        .animate()
                        .fade(delay: (index * 100).ms, duration: 600.ms)
                        .slideX(begin: 0.2, end: 0);
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
