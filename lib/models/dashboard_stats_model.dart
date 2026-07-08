// model statistik dashboard admin
class DashboardStatsModel {
  final int totalProducts; // param total produk aktif
  final int totalOrders; // param total pesanan
  final int totalUsers; // param total pelanggan
  final num totalRevenue; // param total pendapatan
  final Map<String, int> ordersByStatus; // param rekap pesanan per status

  // constructor init
  DashboardStatsModel({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalUsers,
    required this.totalRevenue,
    required this.ordersByStatus,
  });

  // parse json stats
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final statusMap = json['orders_by_status'] as Map<String, dynamic>? ?? {};
    return DashboardStatsModel(
      totalProducts: json['total_products'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      ordersByStatus: statusMap.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }

  // jumlah pesanan pending
  int get pendingOrders => ordersByStatus['pending'] ?? 0;
}

// model produk terlaris
class DashboardTopProductModel {
  final String productId;
  final String productName;
  final String? imageUrl;
  final int totalSold; // param jumlah terjual
  final num totalRevenue; // param pendapatan dari produk ini

  DashboardTopProductModel({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.totalSold,
    required this.totalRevenue,
  });

  // parse json top product
  factory DashboardTopProductModel.fromJson(Map<String, dynamic> json) {
    return DashboardTopProductModel(
      productId: json['product_id'] ?? json['id'] ?? '',
      productName: json['product_name'] ?? json['name'] ?? 'No Name',
      imageUrl: json['image_url'],
      totalSold: json['total_sold'] ?? json['total_quantity'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
    );
  }
}
