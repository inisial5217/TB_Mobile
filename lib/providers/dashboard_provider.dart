import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';
import 'package:tb_ecommerce/models/dashboard_stats_model.dart';
import 'package:tb_ecommerce/models/order_model.dart';
import 'package:tb_ecommerce/services/dashboard_service.dart';

// provider state management dashboard admin
class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService =
      DashboardService();

  DashboardStatsModel? _stats; // statistik utama
  List<DashboardTopProductModel> _topProducts = []; // produk terlaris
  List<OrderModel> _recentOrders = []; // pesanan terbaru
  bool _isLoading = false; // status loading
  String? _errorMessage; // pesan error

  // getter
  DashboardStatsModel? get stats => _stats;
  List<DashboardTopProductModel> get topProducts => _topProducts;
  List<OrderModel> get recentOrders => _recentOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // fetch semua data dashboard sekaligus
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // panggil semua endpoint secara paralel
      final results = await Future.wait([
        _dashboardService.getStats(),
        _dashboardService.getTopProducts(),
        _dashboardService.getRecentOrders(),
      ]);

      // parse stats
      final statsResponse = results[0];
      if (statsResponse.statusCode == 200 &&
          statsResponse.data['success'] == true) {
        _stats = DashboardStatsModel.fromJson(statsResponse.data['data']);
      }

      // parse top products
      final topResponse = results[1];
      if (topResponse.statusCode == 200 &&
          topResponse.data['success'] == true) {
        final dataList = topResponse.data['data'] as List? ?? [];
        _topProducts = dataList
            .map((json) => DashboardTopProductModel.fromJson(json))
            .toList();
      }

      // parse recent orders
      final recentResponse = results[2];
      if (recentResponse.statusCode == 200 &&
          recentResponse.data['success'] == true) {
        final dataList = recentResponse.data['data'] as List? ?? [];
        _recentOrders = dataList
            .map((json) => OrderModel.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      _errorMessage = DioEcommerceClient.parseErrorMessage(e);
    } catch (e) {
      _errorMessage = 'Gagal memuat data dashboard.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
