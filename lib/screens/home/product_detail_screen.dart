import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tb_ecommerce/core/theme.dart';
import 'package:tb_ecommerce/models/review_model.dart';
import 'package:tb_ecommerce/providers/cart_provider.dart';
import 'package:tb_ecommerce/providers/product_provider.dart';
import 'package:tb_ecommerce/services/review_service.dart';
import 'package:tb_ecommerce/widgets/error_state.dart';
import 'package:tb_ecommerce/widgets/primary_button.dart';
import 'package:tb_ecommerce/widgets/shimmer_loading.dart';

// halaman detail produk
class ProductDetailScreen extends StatefulWidget {
  final String productId; // param produk id

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() =>
      _EcommerceProductDetailScreenState();
}

class _EcommerceProductDetailScreenState
    extends State<ProductDetailScreen> {
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = false;
  bool _isAddingToCart = false;

  // form review
  final _reviewCommentController = TextEditingController();
  double _reviewRating = 5;
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProductDetail(widget.productId);
      _fetchReviews();
    });
  }

  @override
  void dispose() {
    _reviewCommentController.dispose();
    super.dispose();
  }

  // fetch ulasan produk
  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final response = await _reviewService.getProductReviews(widget.productId);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dataList = response.data['data'] as List? ?? [];
        setState(() {
          _reviews = dataList.map((e) => ReviewModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Gagal fetch reviews: $e');
    }
    setState(() => _isLoadingReviews = false);
  }

  // tambah ke keranjang
  Future<void> _addToCart() async {
    setState(() => _isAddingToCart = true);
    final cartProvider = context.read<CartProvider>();
    final success = await cartProvider.addToCart(widget.productId);
    setState(() => _isAddingToCart = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil ditambahkan ke keranjang! 🛒'),
          backgroundColor: AppTheme.emeraldGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted && cartProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cartProvider.errorMessage!),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  // submit ulasan baru
  Future<void> _submitReview() async {
    setState(() => _isSubmittingReview = true);
    try {
      await _reviewService.addReview(
        productId: widget.productId,
        rating: _reviewRating.toInt(),
        comment: _reviewCommentController.text.trim(),
      );
      _reviewCommentController.clear();
      await _fetchReviews();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ulasan berhasil ditambahkan!'),
            backgroundColor: AppTheme.emeraldGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan ulasan. Mungkin Anda sudah pernah mengulas.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
    setState(() => _isSubmittingReview = false);
  }

  // format harga ke rupiah
  String _formatRupiah(num price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.slateDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Details', style: TextStyle(color: AppTheme.slateDark, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.slateDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          // loading state
          if (provider.isLoadingDetail) {
            return const ShimmerLoading(type: ShimmerType.detail);
          }

          // error state
          if (provider.detailError != null) {
            return ErrorState(
              message: provider.detailError!,
              onRetry: () => provider.fetchProductDetail(widget.productId),
            );
          }

          final product = provider.selectedProduct;
          if (product == null) {
            return const ErrorState(message: 'Produk tidak ditemukan.');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image container with pastel background
                Container(
                  width: double.infinity,
                  height: 320,
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Hero(
                    tag: 'product_image_${product.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl ?? '',
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, size: 48, color: AppTheme.textTertiary)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Name and stock Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.slateDark),
                      ),
                    ),
                    Text(
                      product.stock > 0 ? 'Available in Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: product.stock > 0 ? AppTheme.emeraldGreen : AppTheme.errorRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Price
                Text(
                  _formatRupiah(product.price),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.pendingAmber, // using amber/orange for price like the reference
                  ),
                ),
                const SizedBox(height: 16),

                // description
                Text(
                  product.description.isNotEmpty ? product.description : 'Tidak ada deskripsi.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // rating & reviews overview
                Text('Ulasan Produk', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildReviewForm(),
                const SizedBox(height: 16),
                if (_isLoadingReviews)
                  const Center(child: CircularProgressIndicator())
                else if (_reviews.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada ulasan untuk produk ini.', style: TextStyle(color: AppTheme.textTertiary))))
                else
                  ..._reviews.map((review) => _buildReviewItem(review)),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final product = provider.selectedProduct;
          if (product == null) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: PrimaryButton(
              text: product.stock > 0 ? 'Add to Cart' : 'Stok Habis',
              isLoading: _isAddingToCart,
              onPressed: product.stock > 0 ? _addToCart : null,
              backgroundColor: product.stock > 0 ? AppTheme.errorRed : AppTheme.textTertiary,
            ),
          );
        },
      ),
    );
  }

  // form ulasan
  Widget _buildReviewForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tulis Ulasan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.slateDark),
          ),
          const SizedBox(height: 10),
          RatingBar.builder(
            initialRating: _reviewRating,
            minRating: 1,
            maxRating: 5,
            itemSize: 28,
            itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppTheme.pendingAmber),
            onRatingUpdate: (rating) => _reviewRating = rating,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reviewCommentController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Tulis komentar...',
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _isSubmittingReview ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: _isSubmittingReview
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Kirim Ulasan', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // item ulasan
  Widget _buildReviewItem(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.emeraldGreen.withValues(alpha: 0.1),
                child: Text(
                  (review.reviewer?.fullName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.emeraldGreen,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer?.fullName ?? 'Anonim',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    RatingBarIndicator(
                      rating: review.rating.toDouble(),
                      itemSize: 14,
                      itemBuilder: (_, __) => const Icon(Icons.star_rounded, color: AppTheme.pendingAmber),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
