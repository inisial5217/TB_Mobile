import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tb_ecommerce/core/theme.dart';
import 'package:tb_ecommerce/providers/order_provider.dart';
import 'package:tb_ecommerce/widgets/error_state.dart';
import 'package:tb_ecommerce/widgets/order_status_badge.dart';
import 'package:tb_ecommerce/widgets/shimmer_loading.dart';

// halaman detail pesanan
class OrderDetailScreen extends StatefulWidget {
  final String orderId; // param order id

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _EcommerceOrderDetailScreenState();
}

class _EcommerceOrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderProvider>().fetchOrderDetail(widget.orderId);
  }

  String _formatRupiah(num price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date.toLocal());
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const ShimmerLoading(type: ShimmerType.detail);
          }

          if (provider.detailError != null) {
            return ErrorState(
              message: provider.detailError!,
              onRetry: () => provider.fetchOrderDetail(widget.orderId),
            );
          }

          final order = provider.selectedOrder;
          if (order == null) {
            return const ErrorState(message: 'Pesanan tidak ditemukan.');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header pesanan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('#${order.shortOrderId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      OrderStatusBadge(status: order.status),
                      const SizedBox(height: 8),
                      Text(_formatDate(order.createdAt), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // alamat pengiriman
                _buildInfoCard(
                  'Alamat Pengiriman',
                  Icons.location_on_rounded,
                  order.shippingAddress ?? '-',
                ),
                const SizedBox(height: 12),

                // catatan
                if (order.notes != null && order.notes!.isNotEmpty)
                  _buildInfoCard(
                    'Catatan',
                    Icons.note_alt_rounded,
                    order.notes!,
                  ),
                if (order.notes != null && order.notes!.isNotEmpty)
                  const SizedBox(height: 12),

                // daftar item
                Text('Daftar Item', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  Text(
                                    '${_formatRupiah(item.price)} x ${item.quantity}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatRupiah(item.subtotal),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      )),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Keseluruhan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          Text(
                            _formatRupiah(order.totalAmount),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.emeraldGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, IconData icon, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.emeraldGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
