import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tb_ecommerce/core/theme.dart';
import 'package:tb_ecommerce/providers/order_provider.dart';
import 'package:tb_ecommerce/screens/orders/order_detail_screen.dart';
import 'package:tb_ecommerce/widgets/empty_state.dart';
import 'package:tb_ecommerce/widgets/error_state.dart';
import 'package:tb_ecommerce/widgets/order_status_badge.dart';
import 'package:tb_ecommerce/widgets/shimmer_loading.dart';

// halaman manajemen pesanan admin
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() =>
      _EcommerceAdminOrdersScreenState();
}

class _EcommerceAdminOrdersScreenState
    extends State<AdminOrdersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<OrderProvider>().fetchAdminOrders(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<OrderProvider>().loadMoreAdminOrders();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatRupiah(num price) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(price);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date.toLocal());
    } catch (e) {
      return dateStr;
    }
  }

  // dialog ubah status pesanan
  void _showChangeStatusDialog(String orderId, String currentStatus) {
    // validasi transisi status yang diperbolehkan
    final allowedTransitions = <String, List<String>>{
      'pending': ['processing', 'cancelled'],
      'processing': ['shipped', 'cancelled'],
      'shipped': ['delivered'],
      'delivered': [],
      'cancelled': [],
    };

    final transitions = allowedTransitions[currentStatus.toLowerCase()] ?? [];

    if (transitions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Status "$currentStatus" tidak bisa diubah lagi.'),
          backgroundColor: AppTheme.textSecondary,
        ),
      );
      return;
    }

    final statusLabels = {
      'processing': 'Proses',
      'shipped': 'Kirim',
      'delivered': 'Selesai',
      'cancelled': 'Batalkan',
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ubah Status Pesanan',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Status saat ini: $currentStatus',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              ...transitions.map((status) {
                final color = AppTheme.getOrderStatusColor(status);
                final icon = AppTheme.getOrderStatusIcon(status);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () async {
                      Navigator.pop(ctx);
                      // konfirmasi sebelum ubah status
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          title: const Text('Konfirmasi'),
                          content: Text(
                            'Ubah status pesanan menjadi "${statusLabels[status] ?? status}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx, false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dialogCtx, true),
                              child: const Text('Ya, Ubah'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && mounted) {
                        final success = await context
                            .read<OrderProvider>()
                            .updateOrderStatus(orderId, status);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Status berhasil diubah ke "${statusLabels[status] ?? status}"'),
                              backgroundColor: AppTheme.emeraldGreen,
                            ),
                          );
                        } else if (mounted) {
                          final errorMsg = context
                              .read<OrderProvider>()
                              .errorMessage;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMsg ??
                                  'Gagal mengubah status pesanan.'),
                              backgroundColor: AppTheme.errorRed,
                            ),
                          );
                        }
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: color.withValues(alpha: 0.08),
                    leading: Icon(icon, color: color, size: 22),
                    title: Text(
                      statusLabels[status] ?? status,
                      style: TextStyle(
                        fontWeight: FontWeight.w600, color: color,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: color),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Manajemen Pesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // filter status
          _buildStatusFilter(),
          // daftar pesanan
          Expanded(child: _buildOrderList()),
        ],
      ),
    );
  }

  // filter status tabs
  Widget _buildStatusFilter() {
    final statuses = [null, 'pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    final labels = ['Semua', 'Pending', 'Proses', 'Dikirim', 'Selesai', 'Batal'];

    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: statuses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = provider.adminStatusFilter == statuses[index];
              return ChoiceChip(
                label: Text(labels[index]),
                selected: isSelected,
                onSelected: (_) =>
                    provider.setAdminStatusFilter(statuses[index]),
                selectedColor:
                    AppTheme.emeraldGreen.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppTheme.emeraldGreen
                      : AppTheme.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // daftar pesanan admin
  Widget _buildOrderList() {
    return Consumer<OrderProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.adminOrders.isEmpty) {
          return const ShimmerLoading(type: ShimmerType.orderList);
        }

        if (provider.errorMessage != null && provider.adminOrders.isEmpty) {
          return ErrorState(
            message: provider.errorMessage!,
            onRetry: () => provider.fetchAdminOrders(refresh: true),
          );
        }

        if (provider.adminOrders.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Tidak Ada Pesanan',
            subtitle: 'Belum ada pesanan dengan filter ini.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchAdminOrders(refresh: true),
          color: AppTheme.emeraldGreen,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: provider.adminOrders.length +
                (provider.adminHasMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index >= provider.adminOrders.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.emeraldGreen),
                  ),
                );
              }

              final order = provider.adminOrders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                          orderId: order.id),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${order.shortOrderId}',
                            style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700,
                            ),
                          ),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (order.profile != null)
                        Text(
                          '👤 ${order.profile!.fullName ?? order.profile!.email ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      Text(
                        _formatDate(order.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatRupiah(order.totalAmount),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.emeraldGreen,
                            ),
                          ),
                          // tombol ubah status
                          SizedBox(
                            height: 32,
                            child: OutlinedButton.icon(
                              onPressed: () => _showChangeStatusDialog(
                                  order.id, order.status),
                              icon: const Icon(Icons.edit_rounded, size: 14),
                              label: const Text('Ubah Status',
                                  style: TextStyle(fontSize: 11)),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                foregroundColor: AppTheme.slateDark,
                                side: BorderSide(
                                    color: AppTheme.dividerColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
