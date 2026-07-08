import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tb_ecommerce/core/theme.dart';
import 'package:tb_ecommerce/providers/product_provider.dart';
import 'package:tb_ecommerce/screens/home/product_detail_screen.dart';
import 'package:tb_ecommerce/widgets/empty_state.dart';
import 'package:tb_ecommerce/widgets/error_state.dart';
import 'package:tb_ecommerce/widgets/product_card.dart';
import 'package:tb_ecommerce/widgets/shimmer_loading.dart';

// halaman utama katalog produk
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProductProvider>();
    provider.fetchProducts(refresh: true);
    provider.fetchCategories();

    // infinite scroll listener
    _scrollController.addListener(_onScroll);
  }

  // deteksi scroll ke bawah untuk pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // header dan search bar
            _buildHeader(),
            // filter kategori
            _buildCategoryFilter(),
            // sorting
            _buildSortingBar(),
            // grid produk
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  // build header dengan search
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TBPrak Shop',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.slateDark,
                    ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close_rounded : Icons.search_rounded,
                      color: AppTheme.slateDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                          context.read<ProductProvider>().setSearchQuery(null);
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          if (_isSearching) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onSubmitted: (value) {
                context.read<ProductProvider>().setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                filled: true,
                fillColor: AppTheme.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommendation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slateDark,
                ),
              ),
              const Icon(Icons.grid_view_rounded, color: AppTheme.textTertiary, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  // build filter kategori dengan chip
  Widget _buildCategoryFilter() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: provider.categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                // chip "Semua"
                final isSelected = provider.selectedCategoryId == null;
                return ChoiceChip(
                  label: const Text('Semua'),
                  selected: isSelected,
                  onSelected: (_) => provider.setCategoryFilter(null),
                  selectedColor:
                      AppTheme.emeraldGreen.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppTheme.emeraldGreen
                        : AppTheme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                );
              }
              final cat = provider.categories[index - 1];
              final isSelected = provider.selectedCategoryId == cat.id;
              return ChoiceChip(
                label: Text(cat.name),
                selected: isSelected,
                onSelected: (_) => provider.setCategoryFilter(cat.id),
                selectedColor:
                    AppTheme.emeraldGreen.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.emeraldGreen
                      : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // build sorting bar
  Widget _buildSortingBar() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Text(
                'Urutkan:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              _buildSortChip(provider, 'Terbaru', 'newest'),
              const SizedBox(width: 6),
              _buildSortChip(provider, 'Termurah', 'price_asc'),
              const SizedBox(width: 6),
              _buildSortChip(provider, 'Termahal', 'price_desc'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortChip(
      ProductProvider provider, String label, String value) {
    final isActive = provider.selectedSort == value;
    return GestureDetector(
      onTap: () => provider.setSortOrder(isActive ? null : value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.slateDark
              : AppTheme.inputFill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  // build grid produk
  Widget _buildProductGrid() {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        // loading state
        if (provider.isLoading) {
          return const ShimmerLoading(type: ShimmerType.productGrid);
        }

        // error state
        if (provider.errorMessage != null) {
          return ErrorState(
            message: provider.errorMessage!,
            onRetry: () => provider.fetchProducts(refresh: true),
          );
        }

        // check empty list
        if (provider.products.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Produk Tidak Ditemukan',
            subtitle: 'Coba kata kunci atau filter lain.',
            actionText: 'Reset Filter',
            onAction: () => provider.resetFilters(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchProducts(refresh: true),
          color: AppTheme.emeraldGreen,
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // loading more indicator
              if (index >= provider.products.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.emeraldGreen,
                    ),
                  ),
                );
              }

              final product = provider.products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        productId: product.id,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
