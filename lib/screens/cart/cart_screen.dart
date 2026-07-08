import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tb_ecommerce/core/theme.dart';
import 'package:tb_ecommerce/providers/cart_provider.dart';
import 'package:tb_ecommerce/screens/checkout/checkout_screen.dart';
import 'package:tb_ecommerce/widgets/empty_state.dart';
import 'package:tb_ecommerce/widgets/error_state.dart';
import 'package:tb_ecommerce/widgets/primary_button.dart';
import 'package:tb_ecommerce/widgets/shimmer_loading.dart';

// halaman keranjang belanja
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _EcommerceCartScreenState();
}

class _EcommerceCartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartProvider>().fetchCart();
  }

  // format rupiah
  String _formatRupiah(num price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  // dialog konfirmasi kosongkan
  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan Keranjang?'),
        content: const Text('Semua item akan dihapus dari keranjang Anda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<CartProvider>().clearCart();
            },
            child: const Text('Kosongkan', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: AppTheme.errorRed),
                onPressed: _showClearCartDialog,
                tooltip: 'Kosongkan keranjang',
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          // loading state
          if (cart.isLoading) {
            return const ShimmerLoading(type: ShimmerType.cartList);
          }

          // error state
          if (cart.errorMessage != null && cart.items.isEmpty) {
            return ErrorState(
              message: cart.errorMessage!,
              onRetry: () => cart.fetchCart(),
            );
          }

          // empty state keranjang kosong
          if (cart.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Wah, keranjangmu masih kosong nih',
              subtitle: 'Yuk mulai belanja dan temukan produk favorit kamu!',
            );
          }

          return Column(
            children: [
              // daftar item keranjang
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // gambar produk
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: item.productImage ?? '',
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 72, height: 72,
                                color: AppTheme.inputFill,
                                child: const Icon(Icons.image_outlined, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // info item
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatRupiah(item.price),
                                  style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: AppTheme.emeraldGreen,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // tombol minus
                                    _buildQtyButton(
                                      icon: Icons.remove,
                                      onTap: item.quantity > 1
                                          ? () => cart.updateItemQuantity(item.id, item.quantity - 1)
                                          : null,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    // tombol plus
                                    _buildQtyButton(
                                      icon: Icons.add,
                                      onTap: () => cart.updateItemQuantity(item.id, item.quantity + 1),
                                    ),
                                    const Spacer(),
                                    // subtotal
                                    Text(
                                      _formatRupiah(item.subtotal),
                                      style: const TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w700,
                                        color: AppTheme.slateDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // tombol hapus
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textTertiary),
                            onPressed: () => cart.removeItem(item.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // grand total dan tombol checkout
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total (${cart.itemCount} item)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _formatRupiah(cart.totalPrice),
                          style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800,
                            color: AppTheme.emeraldGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      text: 'Lanjut ke Checkout',
                      icon: Icons.payment_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // build tombol qty
  Widget _buildQtyButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: onTap != null ? AppTheme.inputFill : AppTheme.dividerColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: onTap != null ? AppTheme.slateDark : AppTheme.textTertiary),
      ),
    );
  }
}
