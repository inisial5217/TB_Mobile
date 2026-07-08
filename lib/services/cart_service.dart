import 'package:dio/dio.dart';
import 'package:tb_ecommerce/core/network/dio_client.dart';

// service keranjang belanja api
class CartService {
  final Dio _dio = DioEcommerceClient().dio;

  // fetch data keranjang
  Future<Response> getCart() async {
    return await _dio.get('/cart');
  }

  // tambah item ke keranjang
  Future<Response> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    return await _dio.post('/cart', data: {
      'product_id': productId,
      'quantity': quantity,
    });
  }

  // update quantity item keranjang
  Future<Response> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    return await _dio.put('/cart/$cartItemId', data: {
      'quantity': quantity,
    });
  }

  // hapus item dari keranjang
  Future<Response> removeCartItem(String cartItemId) async {
    return await _dio.delete('/cart/$cartItemId');
  }

  // kosongkan seluruh keranjang
  Future<Response> clearCart() async {
    return await _dio.delete('/cart');
  }
}
