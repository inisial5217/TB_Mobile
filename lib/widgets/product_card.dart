import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tb_ecommerce/core/theme.dart';
import 'package:tb_ecommerce/models/product_model.dart';

// custom widget kartu produk untuk gridview
class ProductCard extends StatelessWidget {
  final ProductModel product; // param produk model
  final VoidCallback onTap; // param aksi klik

  // constructor init
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  // format harga ke rupiah
  String _formatRupiah(num price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Hero(
                tag: 'product_image_${product.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? '',
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: Icon(Icons.image_outlined, size: 32, color: AppTheme.textTertiary),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 32, color: AppTheme.textTertiary),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // product name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.slateDark,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // price and buy button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _formatRupiah(product.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.pendingAmber, // Using pendingAmber for orange color like the reference
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.slateDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Buy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
