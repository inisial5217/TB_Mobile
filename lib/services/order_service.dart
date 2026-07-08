import 'package:dio/dio.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';

// service pesanan api
class OrderService {
  final Dio _dio = DioEcommerceClient().dio;

  // post new order (checkout)
  Future<Response> checkout({
    required String shippingAddress,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'shipping_address': shippingAddress,
    };
    if (notes != null && notes.isNotEmpty) data['notes'] = notes;
    return await _dio.post('/orders', data: data);
  }

  // fetch riwayat pesanan user
  Future<Response> getMyOrders({int page = 1, int limit = 10}) async {
    return await _dio.get('/orders', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  // fetch detail pesanan by id
  Future<Response> getOrderDetail(String orderId) async {
    return await _dio.get('/orders/$orderId');
  }

  // fetch semua pesanan (admin only)
  Future<Response> getAllOrders({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    return await _dio.get('/orders/admin/all', queryParameters: params);
  }

  // update status pesanan (admin only)
  Future<Response> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    return await _dio.put('/orders/$orderId/status', data: {
      'status': status,
    });
  }
}
