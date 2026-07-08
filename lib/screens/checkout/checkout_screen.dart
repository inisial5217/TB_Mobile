import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tb_ecommerce/core/theme.dart';
import 'package:tb_ecommerce/providers/cart_provider.dart';
import 'package:tb_ecommerce/providers/order_provider.dart';
import 'package:tb_ecommerce/screens/main/main_navigation.dart';
import 'package:tb_ecommerce/widgets/primary_button.dart';
import 'package:tb_ecommerce/widgets/text_field.dart';

// halaman checkout
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _EcommerceCheckoutScreenState();
}

class _EcommerceCheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // format rupiah
  String _formatRupiah(num price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  // dialog konfirmasi checkout
  void _showConfirmDialog() {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: const Text('Apakah Anda yakin ingin membuat pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _processCheckout();
            },
            child: const Text('Ya, Buat Pesanan'),
          ),
        ],
      ),
    );
  }

  // proses checkout
  Future<void> _processCheckout() async {
    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();

    final success = await orderProvider.checkout(
      shippingAddress: _addressController.text.trim(),
      notes: _notesController.text.trim(),
    );

    if (success && mounted) {
      // refresh keranjang (sudah dikosongkan oleh API)
      await cartProvider.fetchCart();

      // tampilkan halaman sukses
      if (mounted) {
        _showSuccessDialog();
      }
    } else if (mounted && orderProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage!),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  // dialog sukses checkout
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppTheme.emeraldGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 40, color: AppTheme.emeraldGreen),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pesanan Berhasil! 🎉',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pesanan Anda sedang diproses. Cek riwayat pesanan untuk detailnya.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // arahkan ke riwayat pesanan
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigation()),
                (route) => false,
              );
            },
            child: const Text('Lihat Pesanan'),
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
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ringkasan pesanan
                  Text('Ringkasan Pesanan', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.dividerColor.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        ...cart.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.productName} x${item.quantity}',
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatRupiah(item.subtotal),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            Text(
                              _formatRupiah(cart.totalPrice),
                              style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800,
                                color: AppTheme.emeraldGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // form alamat pengiriman
                  Text('Alamat Pengiriman', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _addressController,
                    hintText: 'Masukkan alamat lengkap...',
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alamat tidak boleh kosong';
                      }
                      // validate string length
                      if (value.trim().length < 10) {
                        return 'Alamat minimal 10 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // form catatan
                  Text('Catatan (Opsional)', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _notesController,
                    hintText: 'Contoh: Packing pakai bubble wrap...',
                    maxLines: 2,
                    prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                  ),
                  const SizedBox(height: 32),

                  // tombol buat pesanan
                  Consumer<OrderProvider>(
                    builder: (context, orderProvider, _) {
                      return PrimaryButton(
                        text: 'Buat Pesanan',
                        icon: Icons.shopping_bag_rounded,
                        isLoading: orderProvider.isCheckingOut,
                        onPressed: _showConfirmDialog,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
