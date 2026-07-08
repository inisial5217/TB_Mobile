import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tb_ecommerce/core/theme.dart';
import 'package:tb_ecommerce/providers/auth_provider.dart';
import 'package:tb_ecommerce/providers/dashboard_provider.dart';
import 'package:tb_ecommerce/screens/admin/admin_orders_screen.dart';
import 'package:tb_ecommerce/screens/auth/login_screen.dart';
import 'package:tb_ecommerce/widgets/error_state.dart';
import 'package:tb_ecommerce/widgets/order_status_badge.dart';
import 'package:tb_ecommerce/widgets/shimmer_loading.dart';

// halaman dashboard admin
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _EcommerceAdminDashboardScreenState();
}

class _EcommerceAdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  String _formatRupiah(num price) {
    return NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
    ).format(price);
  }

  String _formatShortRupiah(num price) {
    if (price >= 1000000000) {
      return 'Rp ${(price / 1000000000).toStringAsFixed(1)}M';
    } else if (price >= 1000000) {
      return 'Rp ${(price / 1000000).toStringAsFixed(1)}Jt';
    } else if (price >= 1000) {
      return 'Rp ${(price / 1000).toStringAsFixed(0)}Rb';
    }
    return _formatRupiah(price);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, HH:mm').format(date.toLocal());
    } catch (e) {
      return dateStr;
    }
  }

  // logout admin
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout Admin'),
        content: const Text('Apakah Anda yakin ingin keluar dari dashboard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Keluar Aplikasi?'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Keluar')),
            ],
          ),
        );
        if (shouldExit == true) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              onPressed: () =>
                  context.read<DashboardProvider>().fetchDashboardData(),
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded,
                  size: 20, color: AppTheme.errorRed),
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: Consumer<DashboardProvider>(
          builder: (context, dashboard, _) {
            // loading state
            if (dashboard.isLoading) {
              return const ShimmerLoading(type: ShimmerType.dashboard);
            }

            // error state
            if (dashboard.errorMessage != null) {
              return ErrorState(
                message: dashboard.errorMessage!,
                onRetry: () => dashboard.fetchDashboardData(),
              );
            }

            final stats = dashboard.stats;
            if (stats == null) {
              return const ErrorState(
                  message: 'Gagal memuat data dashboard.');
            }

            return RefreshIndicator(
              onRefresh: () => dashboard.fetchDashboardData(),
              color: AppTheme.emeraldGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // greeting
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return Text(
                          'Halo, ${auth.currentUser?.fullName ?? 'Admin'} 👋',
                          style: Theme.of(context).textTheme.headlineMedium,
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Berikut ringkasan toko Anda hari ini.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),

                    // stat cards 2x2
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Produk',
                            '${stats.totalProducts}',
                            Icons.inventory_2_rounded,
                            AppTheme.processingBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Total Pesanan',
                            '${stats.totalOrders}',
                            Icons.receipt_long_rounded,
                            AppTheme.shippedPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Pendapatan',
                            _formatShortRupiah(stats.totalRevenue),
                            Icons.account_balance_wallet_rounded,
                            AppTheme.emeraldGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Pelanggan',
                            '${stats.totalUsers}',
                            Icons.people_rounded,
                            AppTheme.pendingAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // pending orders alert
                    if (stats.pendingOrders > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.pendingAmber
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.pendingAmber
                                  .withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppTheme.pendingAmber, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${stats.pendingOrders} pesanan menunggu diproses',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.slateDark,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminOrdersScreen(),
                                  ),
                                );
                              },
                              child: const Text('Lihat',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // produk terlaris - bar chart
                    Text('🏆 Produk Terlaris',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _buildTopProductsChart(dashboard),
                    const SizedBox(height: 24),

                    // pesanan terbaru
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('📦 Pesanan Terbaru',
                            style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AdminOrdersScreen(),
                              ),
                            );
                          },
                          child: const Text('Lihat Semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRecentOrders(dashboard),
                    const SizedBox(height: 24),

                    // rekap status pesanan
                    Text('📊 Rekap Status Pesanan',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _buildOrderStatusSummary(stats.ordersByStatus),
                    const SizedBox(height: 32),

                    // tombol manajemen pesanan
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AdminOrdersScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_rounded, size: 20),
                        label: const Text('Manajemen Pesanan'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // stat card widget
  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // bar chart produk terlaris
  Widget _buildTopProductsChart(DashboardProvider dashboard) {
    if (dashboard.topProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('Belum ada data produk terlaris.',
              style: TextStyle(color: AppTheme.textTertiary)),
        ),
      );
    }

    final maxSold = dashboard.topProducts
        .fold<int>(0, (max, p) => p.totalSold > max ? p.totalSold : max);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxSold.toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final product = dashboard.topProducts[group.x.toInt()];
                      return BarTooltipItem(
                        '${product.productName}\n${product.totalSold} terjual',
                        const TextStyle(
                          color: Colors.white, fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= dashboard.topProducts.length) {
                          return const SizedBox.shrink();
                        }
                        final name = dashboard.topProducts[idx].productName;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            name.length > 8
                                ? '${name.substring(0, 8)}...'
                                : name,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxSold > 0 ? (maxSold / 4).ceilToDouble() : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.dividerColor.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  dashboard.topProducts.length,
                  (index) {
                    final colors = [
                      AppTheme.emeraldGreen,
                      AppTheme.processingBlue,
                      AppTheme.shippedPurple,
                      AppTheme.pendingAmber,
                      AppTheme.errorRed,
                    ];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: dashboard.topProducts[index].totalSold
                              .toDouble(),
                          color: colors[index % colors.length],
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6)),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ranked list di bawah chart
          ...dashboard.topProducts.asMap().entries.map((entry) {
            final idx = entry.key;
            final product = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '#${idx + 1}',
                        style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppTheme.emeraldGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      product.productName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${product.totalSold} terjual',
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppTheme.emeraldGreen,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // recent orders widget
  Widget _buildRecentOrders(DashboardProvider dashboard) {
    if (dashboard.recentOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('Belum ada pesanan.',
              style: TextStyle(color: AppTheme.textTertiary)),
        ),
      );
    }

    return Column(
      children: dashboard.recentOrders.map((order) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.getOrderStatusColor(order.status)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  AppTheme.getOrderStatusIcon(order.status),
                  size: 18,
                  color: AppTheme.getOrderStatusColor(order.status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.shortOrderId}',
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(
                        fontSize: 11, color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatRupiah(order.totalAmount),
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  OrderStatusBadge(status: order.status),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // order status summary
  Widget _buildOrderStatusSummary(Map<String, int> ordersByStatus) {
    final statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
    final labels = ['Menunggu', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(statuses.length, (index) {
          final count = ordersByStatus[statuses[index]] ?? 0;
          final color = AppTheme.getOrderStatusColor(statuses[index]);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    labels[index],
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: color,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
