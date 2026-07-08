import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tb_ecommerce/core/theme.dart';

// custom widget shimmer loading skeleton
class ShimmerLoading extends StatelessWidget {
  final ShimmerType type; // param tipe shimmer

  // constructor init
  const ShimmerLoading({
    super.key,
    this.type = ShimmerType.productGrid,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ShimmerType.productGrid:
        return _buildProductGridShimmer();
      case ShimmerType.cartList:
        return _buildListShimmer(itemCount: 3, height: 100);
      case ShimmerType.orderList:
        return _buildListShimmer(itemCount: 4, height: 90);
      case ShimmerType.detail:
        return _buildDetailShimmer();
      case ShimmerType.dashboard:
        return _buildDashboardShimmer();
    }
  }

  // shimmer skeleton produk grid
  Widget _buildProductGridShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.dividerColor,
      highlightColor: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // shimmer skeleton daftar (keranjang/pesanan)
  Widget _buildListShimmer({int itemCount = 3, double height = 80}) {
    return Shimmer.fromColors(
      baseColor: AppTheme.dividerColor,
      highlightColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // shimmer skeleton detail produk
  Widget _buildDetailShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.dividerColor,
      highlightColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            Container(height: 24, width: 200, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 18, width: 120, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 60, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // shimmer skeleton dashboard
  Widget _buildDashboardShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.dividerColor,
      highlightColor: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // stat cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// enum tipe shimmer
enum ShimmerType { productGrid, cartList, orderList, detail, dashboard }
