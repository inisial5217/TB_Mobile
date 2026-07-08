import 'package:dio/dio.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';

// service dashboard admin api
class DashboardService {
  final Dio _dio = DioEcommerceClient().dio;

  // fetch statistik utama dashboard
  Future<Response> getStats() async {
    return await _dio.get('/dashboard/stats');
  }

  // fetch produk terlaris
  Future<Response> getTopProducts({int limit = 5}) async {
    return await _dio.get('/dashboard/top-products', queryParameters: {
      'limit': limit,
    });
  }

  // fetch pesanan terbaru
  Future<Response> getRecentOrders({int limit = 5}) async {
    return await _dio.get('/dashboard/recent-orders', queryParameters: {
      'limit': limit,
    });
  }

  // fetch produk stok menipis
  Future<Response> getLowStockProducts({int threshold = 5, int limit = 10}) async {
    return await _dio.get('/dashboard/low-stock', queryParameters: {
      'threshold': threshold,
      'limit': limit,
    });
  }
}
