import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store_data.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_bottom_sheet.dart';
import '../widgets/checkout_dialog.dart';
import '../widgets/filter_panel.dart';
import '../widgets/product_card.dart';
import '../widgets/special_offers_carousel.dart';

enum SortOption { nameAsc, nameDesc, priceLowHigh, priceHighLow }

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _specialsOnly = false;
  String _selectedCategoryId = 'all';
  SortOption _sortOption = SortOption.nameAsc;

  bool get _filtersActive =>
      _specialsOnly || _selectedCategoryId != 'all' || _searchController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valley Farm Secrets Store'),
        leading: isWide
            ? null
            : Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    tooltip: 'Filters',
                  );
                },
              ),
        actions: <Widget>[
          Consumer<CartProvider>(
            builder: (BuildContext context, CartProvider cart, _) {
              return IconButton(
                onPressed: _openCart,
                tooltip: 'View cart',
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    const Icon(Icons.shopping_cart_outlined),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            cart.itemCount.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Theme.of(context).colorScheme.onSecondary),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: isWide
          ? null
          : Drawer(
              child: SafeArea(
                child: FilterPanel(
                  categories: storeCategories,
                  searchController: _searchController,
                  specialsOnly: _specialsOnly,
                  selectedCategoryId: _selectedCategoryId,
                  onSearchChanged: (String value) => setState(() {}),
                  onSpecialsChanged: (bool value) => setState(() => _specialsOnly = value),
                  onCategoryChanged: (String value) => setState(() => _selectedCategoryId = value),
                ),
              ),
            ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget mainContent = _buildMainContent();
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FilterPanel(
                  categories: storeCategories,
                  searchController: _searchController,
                  specialsOnly: _specialsOnly,
                  selectedCategoryId: _selectedCategoryId,
                  onSearchChanged: (String value) => setState(() {}),
                  onSpecialsChanged: (bool value) => setState(() => _specialsOnly = value),
                  onCategoryChanged: (String value) => setState(() => _selectedCategoryId = value),
                ),
                Expanded(child: mainContent),
              ],
            );
          }
          return mainContent;
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<CartProvider>(
        builder: (BuildContext context, CartProvider cart, _) {
          return FloatingActionButton.extended(
            onPressed: _openCart,
            icon: const Icon(Icons.shopping_basket_outlined),
            label: Text('Cart (${cart.itemCount})'),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    final List<Product> filteredProducts = _applyFilters();
    final List<Product> specials = filteredProducts
        .where((Product product) => product.onSpecial)
        .toList(growable: false);
    final List<Product> specialShowcase = _specialsOnly ? filteredProducts : specials;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      children: <Widget>[
        SpecialOffersCarousel(products: specialShowcase),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _filtersActive ? 'Filtered Products' : 'Shop by Category',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _filtersActive
                        ? 'Tailor your basket with the filters and sort options below.'
                        : 'Browse the full Valley Farm Secrets range grouped by category.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildSortDropdown(),
          ],
        ),
        const SizedBox(height: 16),
        if (_filtersActive)
          if (filteredProducts.isEmpty)
            _buildEmptyState()
          else
            _buildProductGrid(filteredProducts)
        else
          _buildGroupedGrid(),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<SortOption>(
          value: _sortOption,
          onChanged: (SortOption? value) {
            if (value != null) {
              setState(() => _sortOption = value);
            }
          },
          underline: const SizedBox.shrink(),
          items: const <DropdownMenuItem<SortOption>>[
            DropdownMenuItem<SortOption>(
              value: SortOption.nameAsc,
              child: Text('Name A–Z'),
            ),
            DropdownMenuItem<SortOption>(
              value: SortOption.nameDesc,
              child: Text('Name Z–A'),
            ),
            DropdownMenuItem<SortOption>(
              value: SortOption.priceLowHigh,
              child: Text('Price Low–High'),
            ),
            DropdownMenuItem<SortOption>(
              value: SortOption.priceHighLow,
              child: Text('Price High–Low'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.sentiment_dissatisfied_outlined, size: 48),
          const SizedBox(height: 16),
          Text(
            'No products match your filters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or toggling off the special-only filter to see more items.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = _calculateCrossAxisCount(width);
        final double aspectRatio = width >= 900
            ? 0.78
            : width >= 600
                ? 0.74
                : 0.68;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: aspectRatio,
          ),
          itemCount: products.length,
          itemBuilder: (BuildContext context, int index) {
            return ProductCard(product: products[index]);
          },
        );
      },
    );
  }

  Widget _buildGroupedGrid() {
    final List<Widget> sections = <Widget>[];
    for (final Category category in storeCategories) {
      final List<Product> categoryProducts = storeProducts
          .where((Product product) => product.categoryId == category.id)
          .toList(growable: false);
      if (categoryProducts.isEmpty) {
        continue;
      }
      final List<Product> sortedCategoryProducts = _sortProducts(categoryProducts);
      sections
        ..add(const SizedBox(height: 12))
        ..add(Text(
          category.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ))
        ..add(Text(category.description, style: Theme.of(context).textTheme.bodyMedium))
        ..add(const SizedBox(height: 12))
        ..add(_buildProductGrid(sortedCategoryProducts))
        ..add(const SizedBox(height: 24));
    }
    return Column(children: sections);
  }

  List<Product> _applyFilters() {
    Iterable<Product> products = storeProducts;
    if (_selectedCategoryId != 'all') {
      products = products.where((Product product) => product.categoryId == _selectedCategoryId);
    }
    if (_specialsOnly) {
      products = products.where((Product product) => product.onSpecial);
    }
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      products = products.where(
        (Product product) =>
            product.name.toLowerCase().contains(query) ||
            product.unit.toLowerCase().contains(query) ||
            (product.description?.toLowerCase().contains(query) ?? false),
      );
    }
    final List<Product> result = products.toList(growable: false);
    return _sortProducts(result);
  }

  List<Product> _sortProducts(List<Product> products) {
    final List<Product> sorted = List<Product>.from(products);
    sorted.sort((Product a, Product b) {
      switch (_sortOption) {
        case SortOption.nameAsc:
          return a.name.compareTo(b.name);
        case SortOption.nameDesc:
          return b.name.compareTo(a.name);
        case SortOption.priceLowHigh:
          return a.price.compareTo(b.price);
        case SortOption.priceHighLow:
          return b.price.compareTo(a.price);
      }
    });
    return sorted;
  }

  int _calculateCrossAxisCount(double width) {
    if (width >= 1200) {
      return 4;
    }
    if (width >= 900) {
      return 3;
    }
    if (width >= 600) {
      return 2;
    }
    return width > 420 ? 2 : 1;
  }

  void _openCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CartBottomSheet(onCheckout: _handleCheckout);
      },
    );
  }

  Future<void> _handleCheckout() async {
    final CartProvider cart = context.read<CartProvider>();
    if (cart.isEmpty) {
      return;
    }
    final bool? success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CheckoutDialog(items: cart.items, subtotal: cart.subtotal);
      },
    );
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
    }
  }
}
